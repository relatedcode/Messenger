import { USER_PHOTO_MAX_WIDTH, USER_THUMBNAIL_WIDTH } from "config";
import { createOrUpdateDetails } from "controllers/channels";
import express from "express";
import {
  CREATE_PRESENCE,
  CREATE_USER,
  UPDATE_PRESENCE,
  UPDATE_USER,
} from "graphql/mutations";
import { GET_CHANNEL, GET_DIRECT, GET_PRESENCE } from "graphql/queries";
import { createGQLUser } from "utils/auth";
import graphQLClient from "utils/graphql";
import { getFileMetadata, saveImageThumbnail } from "utils/storage";

export const createUser = async (
  req: express.Request,
  res: express.Response,
  next: express.NextFunction
) => {
  try {
    const { name, email, password } = req.body;

    const user = await createGQLUser({
      email,
      password,
    });
    const uid = user.uid;

    await graphQLClient(user.idToken).request(CREATE_USER, {
      input: {
        objectId: uid,
        fullName: name,
        displayName: name,
        email,
        phoneNumber: "",
        title: "",
        theme: "",
        photoURL: "",
        thumbnailURL: "",
        workspaces: [],
      },
    });

    await graphQLClient(user.idToken).request(CREATE_PRESENCE, {
      input: {
        objectId: uid,
      },
    });

    res.locals.data = {
      uid,
    };
    return next();
  } catch (err) {
    return next(err);
  }
};

export const updateUser = async (
  req: express.Request,
  res: express.Response,
  next: express.NextFunction
) => {
  try {
    const { photoPath, fullName, displayName, title, phoneNumber, theme } =
      req.body;
    const { id } = req.params;
    const { uid } = res.locals;

    if (id !== uid) throw new Error("Not allowed.");

    if (displayName === "") throw new Error("Display name must be provided.");
    if (fullName === "") throw new Error("Full name must be provided.");

    const path = photoPath
      ? decodeURIComponent(
          photoPath.split("/storage/b/messenger/o/")[1].split("?token=")[0]
        )
      : "";
    const metadata = await getFileMetadata(path);
    const [thumbnailURL, , photoResizedURL] = await saveImageThumbnail({
      filePath: path,
      width: USER_THUMBNAIL_WIDTH,
      height: USER_THUMBNAIL_WIDTH,
      metadata,
      resizeOriginalSize: USER_PHOTO_MAX_WIDTH,
      authToken: res.locals.token,
    });

    await graphQLClient(res.locals.token).request(UPDATE_USER, {
      input: {
        objectId: uid,
        ...(title != null && { title }),
        ...(photoPath != null && {
          photoURL: photoResizedURL || photoPath,
          thumbnailURL,
        }),
        ...(phoneNumber != null && { phoneNumber }),
        ...(displayName && { displayName }),
        ...(fullName && { fullName }),
        ...(theme && { theme }),
      },
    });

    res.locals.data = {
      success: true,
    };
    return next();
  } catch (err) {
    return next(err);
  }
};

export const updatePresence = async (
  req: express.Request,
  res: express.Response,
  next: express.NextFunction
) => {
  try {
    const { id } = req.params;
    const { uid } = res.locals;

    if (id !== uid) throw new Error("Not allowed.");

    const { getPresence: presence } = await graphQLClient(
      res.locals.token
    ).request(GET_PRESENCE, {
      objectId: id,
    });

    if (presence) {
      await graphQLClient(res.locals.token).request(UPDATE_PRESENCE, {
        input: {
          objectId: uid,
          lastPresence: new Date().toISOString(),
        },
      });
    } else {
      await graphQLClient(res.locals.token).request(CREATE_PRESENCE, {
        input: {
          objectId: uid,
        },
      });
    }

    res.locals.data = {
      success: true,
    };
    return next();
  } catch (err) {
    return next(err);
  }
};

export const read = async (
  req: express.Request,
  res: express.Response,
  next: express.NextFunction
) => {
  try {
    const { id } = req.params;
    const { uid } = res.locals;
    const { chatType, chatId } = req.body;

    if (id !== uid) throw new Error("Not allowed.");

    let chat;
    if (chatType === "Direct") {
      const { getDirect: direct } = await graphQLClient(
        res.locals.token
      ).request(GET_DIRECT, {
        objectId: chatId,
      });
      chat = direct;
    } else {
      const { getChannel: channel } = await graphQLClient(
        res.locals.token
      ).request(GET_CHANNEL, {
        objectId: chatId,
      });
      chat = channel;
    }

    await createOrUpdateDetails({ token: res.locals.token, uid, chat });

    res.locals.data = {
      success: true,
    };
    return next();
  } catch (err) {
    return next(err);
  }
};
