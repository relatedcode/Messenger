import AWS from "aws-sdk";
import axios from "axios";
import { MAX_FILE_SIZE_MB } from "config";
import ffmpeg_static from "ffmpeg-static";
import ffprobe from "ffprobe-static";
import ffmpeg from "fluent-ffmpeg";
import FormData from "form-data";
import fs from "fs";
import sizeOf from "image-size";
import { GQL_SERVER_URL } from "lib/config";
import os from "os";
import path from "path";
import sharp from "sharp";

const s3 = new AWS.S3({
  accessKeyId: process.env.MINIO_ROOT_USER || "gqlserver",
  secretAccessKey: process.env.MINIO_ROOT_PASSWORD || "gqlserver",
  endpoint: "http://minio:9000",
  s3ForcePathStyle: true,
  signatureVersion: "v4",
});

const storageBucket = process.env.MINIO_BUCKET || "messenger";

const convertBytesToMegaBytes = (bytes: number) => {
  return bytes / 1024 / 1024;
};

const getMediaType = (metadata: any) => {
  return metadata.ContentType.split("/")[0];
};

const ffmpegSync = (originalFile: any, modifiedFile: any) => {
  return new Promise((resolve: any, reject) => {
    ffmpeg(originalFile)
      .setFfmpegPath(ffmpeg_static)
      .screenshot(
        {
          timemarks: [1],
          filename: modifiedFile,
        },
        os.tmpdir()
      )
      .on("end", () => {
        resolve();
      })
      .on("error", (err) => {
        reject(new Error(err));
      });
  });
};

const ffprobeSync = (originalFile: any) => {
  const ffprobePath =
    process.env.NODE_ENV === "production"
      ? ffprobe.path
      : "/app/node_modules/ffprobe-static/bin/linux/x64/ffprobe";
  return new Promise((resolve, reject) => {
    ffmpeg()
      .setFfprobePath(ffprobePath)
      .input(originalFile)
      .ffprobe((err, metadata) => {
        if (err) reject(err);
        resolve(metadata?.streams[0]);
      });
  });
};

const extractFileNameWithoutExtension = (filePath: string, ext: string) => {
  return path.basename(filePath, ext);
};

export const getFileMetadata = async (filePath: string) => {
  if (!filePath) return null;
  const data = await s3
    .headObject({
      Bucket: storageBucket,
      Key: filePath,
    })
    .promise();
  return data;
};

export const deleteFile = async (filePath: string) => {
  await s3
    .deleteObject({
      Bucket: storageBucket,
      Key: filePath,
    })
    .promise();
};

export const saveImageThumbnail = async ({
  filePath,
  width,
  height = null,
  metadata,
  allowVideo = false,
  allowAudio = false,
  resizeOriginalSize = null,
  authToken,
}: {
  filePath: string;
  width: number;
  height?: number | null;
  metadata: any;
  allowVideo?: boolean;
  allowAudio?: boolean;
  resizeOriginalSize?: number | null;
  authToken: string;
}) => {
  let fileDeleted = false;
  try {
    if (!filePath) return ["", null];
    if (convertBytesToMegaBytes(metadata.ContentLength) > MAX_FILE_SIZE_MB)
      return ["", null];

    if (getMediaType(metadata) === "video" && !allowVideo)
      throw new Error("Video file is not allowed");

    if (getMediaType(metadata) === "audio" && !allowAudio)
      throw new Error("Audio file is not allowed");

    if (!["image", "video", "audio"].includes(getMediaType(metadata)))
      return ["", null];

    const originalFile = path.join(os.tmpdir(), path.basename(filePath));
    const fileDir = path.dirname(filePath);
    const fileExtension = path.extname(filePath);
    const fileNameWithoutExtension = extractFileNameWithoutExtension(
      filePath,
      fileExtension
    )
      .replace("_photo", "")
      .replace("_file", "");

    const data = s3
      .getObject({
        Bucket: storageBucket,
        Key: filePath,
      })
      .createReadStream();
    await new Promise((resolve: any, reject) => {
      data
        .pipe(fs.createWriteStream(originalFile))
        .on("error", (err: any) => reject(err))
        .on("close", () => resolve());
    });

    const thumbnailFile = path.join(
      os.tmpdir(),
      `${fileNameWithoutExtension}_thumbnail.jpeg`
    );

    // START - Only used for original image resizing
    const originalFileResized = path.join(
      os.tmpdir(),
      `${fileNameWithoutExtension}_resized.jpeg`
    );
    let originalFileResizedURL = "";
    // END - Only used for original image resizing

    let fileMetadata;

    if (getMediaType(metadata) === "video") {
      // Video thumbnail
      try {
        fileMetadata = await ffprobeSync(originalFile);
      } catch (err: any) {
        console.error(err.message);
      }
      await ffmpegSync(
        originalFile,
        `${fileNameWithoutExtension}_thumbnail.png`
      );
      await sharp(`${os.tmpdir()}/${fileNameWithoutExtension}_thumbnail.png`)
        .resize(width, height)
        .jpeg()
        .toFile(thumbnailFile);
      fs.unlinkSync(`${os.tmpdir()}/${fileNameWithoutExtension}_thumbnail.png`);
    } else if (getMediaType(metadata) === "audio") {
      // Audio thumbnail
      try {
        fileMetadata = await ffprobeSync(originalFile);
      } catch (err: any) {
        console.error(err.message);
      }
      fs.unlinkSync(originalFile);
      return ["", fileMetadata];
    } else {
      // Image thumbnail
      fileMetadata = sizeOf(originalFile);
      if (fileMetadata.width! <= width) {
        fs.unlinkSync(originalFile);
        return ["", fileMetadata];
      }
      await sharp(originalFile)
        .resize(width, height)
        .jpeg()
        .toFile(thumbnailFile);

      // START - Only used for original image resizing
      if (resizeOriginalSize && fileMetadata.width! > resizeOriginalSize!) {
        await sharp(originalFile)
          .resize(resizeOriginalSize, resizeOriginalSize)
          .jpeg()
          .toFile(originalFileResized);
        await deleteFile(filePath);
        fileDeleted = true;
        originalFileResizedURL = await uploadFile(
          "messenger",
          `${fileDir}/${fileNameWithoutExtension}.jpeg`,
          originalFileResized,
          authToken
        );
      }
      // END - Only used for original image resizing
    }

    const thumbnailURL = await uploadFile(
      "messenger",
      `${fileDir}/${fileNameWithoutExtension}_thumbnail.jpeg`,
      thumbnailFile,
      authToken
    );

    if (fs.existsSync(originalFile)) fs.unlinkSync(originalFile);
    if (fs.existsSync(thumbnailFile)) fs.unlinkSync(thumbnailFile);
    if (fs.existsSync(originalFileResized)) fs.unlinkSync(originalFileResized);

    return [thumbnailURL, fileMetadata, originalFileResizedURL];
  } catch (err) {
    if (filePath && !fileDeleted) await deleteFile(filePath);
    throw err;
  }
};

async function uploadFile(
  bucketName: string,
  filePath: string,
  file: string,
  token: string
): Promise<string> {
  const form = new FormData();
  form.append("key", filePath);
  form.append("file", fs.createReadStream(file));

  const res = await axios.post(
    `${GQL_SERVER_URL}/storage/b/${bucketName}/upload`,
    form,
    {
      headers: {
        Authorization: `Bearer ${token}`,
        ...form.getHeaders(),
      },
    }
  );

  return res.data.url;
}
