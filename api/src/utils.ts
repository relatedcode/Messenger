import crypto from "crypto";
import fetch from "node-fetch";

export const removeExtraSpaces = (str: string) =>
  str.replace(/\s+/g, " ").trim();

export const postData = async (url: string, data: any, addHeaders?: any) => {
  const headers =
    addHeaders !== null
      ? {
          "Content-Type": "application/json",
          ...addHeaders,
        }
      : {};
  const res = await fetch(url, {
    method: "post",
    headers: headers,
    body: JSON.stringify(data || {}),
  });
  if (!res.ok) {
    const e = await res.json();
    const error = new Error(e.error.message);
    throw error;
  }
  const contentType = res.headers.get("content-type");
  if (contentType && contentType.indexOf("application/json") !== -1)
    return await res.json();
  return;
};

export const deleteData = async (url: string, addHeaders?: any) => {
  const headers = {
    "Content-Type": "application/json",
    ...addHeaders,
  };
  const res = await fetch(url, {
    method: "delete",
    headers: headers,
  });
  if (!res.ok) {
    const e = await res.json();
    const error = new Error(e.error.message);
    throw error;
  }
  return;
};

export const fetcher = async (url: string, addHeaders?: any) => {
  const headers = {
    "Content-Type": "application/json",
    ...addHeaders,
  };
  const res = await fetch(url, {
    method: "get",
    headers,
  });
  if (!res.ok) {
    const e = await res.json();
    const error = new Error(e.error.message);
    throw error;
  }
  return await res.json();
};

export const logTime = (date = new Date()) => {
  const year = date.getUTCFullYear();
  const month = `0${date.getUTCMonth() + 1}`.slice(-2);
  const day = `0${date.getUTCDate()}`.slice(-2);

  const hours = `0${date.getUTCHours()}`.slice(-2);
  const min = `0${date.getUTCMinutes()}`.slice(-2);
  const sec = `0${date.getUTCSeconds()}`.slice(-2);

  const ms = `00${date.getUTCMilliseconds()}`.slice(-3);

  return `[${year}-${month}-${day} ${hours}:${min}:${sec}.${ms}]`;
};

export const sleep = (ms: number) => {
  return new Promise((resolve) => setTimeout(resolve, ms));
};

export const now = () => {
  return Math.floor(Date.now() / 1000);
};

export const timeDiff = (date1: any, date2: any) => {
  return Math.abs(date1.getTime() - date2) / 1000;
};

export const sha256 = (str: string) => {
  return crypto.createHash("sha256").update(str).digest("hex");
};

const lastMessageTextFileGenerator = (fileType: string) => {
  if (fileType === "image/gif") return "GIF message";
  if (["image/png", "image/jpeg"].includes(fileType)) return "Picture message";
  if (fileType === "video/mp4") return "Video message";
  if (fileType === "audio/mpeg") return "Audio message";
  return "File message";
};

export const lastMessageTextGenerator = ({
  text,
  sticker,
  fileType,
}: {
  text?: string;
  sticker?: string;
  fileType?: string;
}) => {
  if (text) return text;
  if (sticker) return "Sticker message";
  if (fileType) return lastMessageTextFileGenerator(fileType);
  return "";
};

export const getMessageType = ({
  text,
  sticker,
  fileType,
}: {
  text?: string;
  sticker?: string;
  fileType?: string;
}) => {
  if (text) return "text";
  if (sticker) return "sticker";
  if (fileType === "image/gif") return "anim";
  if (["image/png", "image/jpeg"].includes(fileType || "")) return "photo";
  if (fileType === "video/mp4") return "video";
  if (fileType === "audio/mpeg") return "audio";
  return "file";
};
