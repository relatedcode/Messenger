import { MESSAGE_THUMBNAIL_WIDTH } from "config";
import express from "express";
import {
  CREATE_DETAIL,
  CREATE_MESSAGE,
  CREATE_REACTION,
  UPDATE_CHANNEL,
  UPDATE_DETAIL,
  UPDATE_DIRECT,
  UPDATE_MESSAGE,
  UPDATE_REACTION
} from "graphql/mutations";
import {
  GET_CHANNEL,
  GET_DETAIL,
  GET_DIRECT,
  GET_MESSAGE,
  GET_REACTION,
  LIST_MESSAGES
} from "graphql/queries";
import { getMessageType, lastMessageTextGenerator, sha256 } from "utils";
import { arrayRemove } from "utils/array-helpers";
import graphQLClient from "utils/graphql";
import { getFileMetadata, saveImageThumbnail } from "utils/storage";
import { v4 as uuidv4 } from "uuid";

export const createMessage = async (
  req: express.Request,
  res: express.Response,
  next: express.NextFunction
) => {
  try {
    const {
      text,
      chatId,
      workspaceId,
      chatType,
      filePath,
      sticker,
      fileName,
      objectId: customObjectId,
    } = req.body;
    const { uid } = res.locals;

    if (!chatId || !workspaceId || !chatType) {
      throw new Error("Arguments are missing.");
    }

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

    if (!chat.members.includes(uid))
      throw new Error("The user is not authorized to create a message.");

    const lastMessageCounter = chat.lastMessageCounter || 0;

    const detailId = sha256(`${uid}#${chatId}`);
    const { getDetail: chatDetails } = await graphQLClient(
      res.locals.token
    ).request(GET_DETAIL, {
      objectId: detailId,
    });

    const path = filePath
      ? decodeURIComponent(
          filePath.split("/storage/b/messenger/o/")[1].split("?token=")[0]
        )
      : "";

    const fileDetails = await getFileMetadata(path);

    const [thumbnailURL, fileMetadata] = (await saveImageThumbnail({
      filePath: path,
      width: MESSAGE_THUMBNAIL_WIDTH,
      metadata: fileDetails,
      allowAudio: true,
      allowVideo: true,
      authToken: res.locals.token,
    })) as any;

    const promises = [];

    const messageId = customObjectId || uuidv4();
    promises.push(
      await graphQLClient(res.locals.token).request(CREATE_MESSAGE, {
        input: {
          text: text || "",
          mediaWidth: fileMetadata?.width || null,
          mediaHeight: fileMetadata?.height || null,
          mediaDuration:
            (fileMetadata?.duration && Math.floor(fileMetadata.duration)) ||
            null,
          thumbnailURL,
          fileSize: fileDetails ? fileDetails.ContentLength : null,
          fileType: fileDetails ? fileDetails.ContentType : null,
          fileURL: filePath,
          fileName: fileName || null,
          sticker: sticker || null,
          objectId: messageId,
          senderId: uid,
          workspaceId,
          chatId,
          chatType,
          type: getMessageType({
            text,
            sticker,
            fileType: fileDetails?.ContentType,
          }),
          counter: lastMessageCounter + 1,
          isDeleted: false,
          isEdited: false,
        },
      })
    );

    const lastMessageText = lastMessageTextGenerator({
      text,
      sticker,
      fileType: fileDetails?.ContentType,
    });

    if (chatType === "Channel") {
      promises.push(
        graphQLClient(res.locals.token).request(UPDATE_CHANNEL, {
          input: {
            objectId: chatId,
            lastMessageText,
            lastMessageCounter: chat.lastMessageCounter + 1,
            typing: arrayRemove(chat.typing, uid),
          },
        })
      );
    } else {
      promises.push(
        graphQLClient(res.locals.token).request(UPDATE_DIRECT, {
          input: {
            objectId: chatId,
            lastMessageText,
            lastMessageCounter: chat.lastMessageCounter + 1,
            active: chat.members,
            typing: arrayRemove(chat.typing, uid),
          },
        })
      );
    }

    if (chatDetails) {
      promises.push(
        graphQLClient(res.locals.token).request(UPDATE_DETAIL, {
          input: {
            objectId: detailId,
            lastRead: lastMessageCounter + 1,
          },
        })
      );
    } else {
      promises.push(
        graphQLClient(res.locals.token).request(CREATE_DETAIL, {
          input: {
            objectId: detailId,
            chatId,
            userId: uid,
            workspaceId,
            lastRead: lastMessageCounter + 1,
          },
        })
      );
    }

    await Promise.all(promises);

    res.locals.data = {
      success: true,
    };
    return next();
  } catch (err) {
    return next(err);
  }
};

export const editMessage = async (
  req: express.Request,
  res: express.Response,
  next: express.NextFunction
) => {
  try {
    const { text } = req.body;
    const { id } = req.params;
    const { uid } = res.locals;

    const { getMessage: message } = await graphQLClient(
      res.locals.token
    ).request(GET_MESSAGE, {
      objectId: id,
    });

    let chat;
    if (message.chatType === "Direct") {
      const { getDirect: direct } = await graphQLClient(
        res.locals.token
      ).request(GET_DIRECT, {
        objectId: message.chatId,
      });
      chat = direct;
    } else {
      const { getChannel: channel } = await graphQLClient(
        res.locals.token
      ).request(GET_CHANNEL, {
        objectId: message.chatId,
      });
      chat = channel;
    }

    if (!chat.members.includes(uid)) {
      throw new Error("The user is not authorized to edit this message.");
    }
    if (message.senderId !== uid) {
      throw new Error("The user is not authorized to edit this message.");
    }

    const promises = [];

    promises.push(
      await graphQLClient(res.locals.token).request(UPDATE_MESSAGE, {
        input: {
          objectId: id,
          text,
          isEdited: true,
        },
      })
    );

    const { listMessages: lastMessages } = await graphQLClient(
      res.locals.token
    ).request(LIST_MESSAGES, {
      chatId: message.chatId,
    });
    const lastMessage = lastMessages[0];

    if (lastMessage.counter === message.counter) {
      if (message.chatType === "Channel") {
        promises.push(
          graphQLClient(res.locals.token).request(UPDATE_CHANNEL, {
            input: {
              objectId: message.chatId,
              lastMessageText: text,
            },
          })
        );
      } else {
        promises.push(
          graphQLClient(res.locals.token).request(UPDATE_DIRECT, {
            input: {
              objectId: message.chatId,
              lastMessageText: text,
            },
          })
        );
      }
    }

    await Promise.all(promises);

    res.locals.data = {
      success: true,
    };
    return next();
  } catch (err) {
    return next(err);
  }
};

export async function createOrUpdateReaction({
  token,
  uid,
  messageId,
  reaction,
  chat,
}: {
  token: string;
  uid: string;
  messageId: string;
  reaction: string;
  chat: any;
}) {
  const reactionId = sha256(`${uid}#${chat.objectId}#${messageId}`);
  try {
    await graphQLClient(token).request(GET_REACTION, {
      objectId: reactionId,
    });

    // reaction already exists, so update it
    await graphQLClient(token).request(UPDATE_REACTION, {
      input: {
        objectId: reactionId,
        reaction,
      },
    });
  } catch (err) {
    // reaction does not exist, so create it
    await graphQLClient(token).request(CREATE_REACTION, {
      input: {
        objectId: reactionId,
        chatId: chat.objectId,
        messageId,
        userId: uid,
        workspaceId: chat.workspaceId,
        reaction,
      },
    });
  }
}

export const editMessageReaction = async (
  req: express.Request,
  res: express.Response,
  next: express.NextFunction
) => {
  try {
    const { reaction } = req.body;
    const { id: messageId } = req.params;
    const { uid } = res.locals;

    const { getMessage: message } = await graphQLClient(
      res.locals.token
    ).request(GET_MESSAGE, {
      objectId: messageId,
    });

    let chat;
    if (message.chatType === "Direct") {
      const { getDirect: direct } = await graphQLClient(
        res.locals.token
      ).request(GET_DIRECT, {
        objectId: message.chatId,
      });
      chat = direct;
    } else {
      const { getChannel: channel } = await graphQLClient(
        res.locals.token
      ).request(GET_CHANNEL, {
        objectId: message.chatId,
      });
      chat = channel;
    }

    if (!chat.members.includes(uid)) {
      throw new Error("The user is not authorized to do this action.");
    }

    await createOrUpdateReaction({
      token: res.locals.token,
      messageId,
      reaction,
      chat,
      uid,
    });

    res.locals.data = {
      success: true,
    };
    return next();
  } catch (err) {
    return next(err);
  }
};

export const deleteMessage = async (
  req: express.Request,
  res: express.Response,
  next: express.NextFunction
) => {
  try {
    const { id } = req.params;
    const { uid } = res.locals;

    const { getMessage: message } = await graphQLClient(
      res.locals.token
    ).request(GET_MESSAGE, {
      objectId: id,
    });

    let chat;
    if (message.chatType === "Direct") {
      const { getDirect: direct } = await graphQLClient(
        res.locals.token
      ).request(GET_DIRECT, {
        objectId: message.chatId,
      });
      chat = direct;
    } else {
      const { getChannel: channel } = await graphQLClient(
        res.locals.token
      ).request(GET_CHANNEL, {
        objectId: message.chatId,
      });
      chat = channel;
    }

    if (!chat.members.includes(uid)) {
      throw new Error("The user is not authorized to delete this message.");
    }
    if (message.senderId !== uid) {
      throw new Error("The user is not authorized to delete this message.");
    }

    await graphQLClient(res.locals.token).request(UPDATE_MESSAGE, {
      input: {
        objectId: id,
        isDeleted: true,
      },
    });

    const { listMessages: lastMessages } = await graphQLClient(
      res.locals.token
    ).request(LIST_MESSAGES, {
      chatId: message.chatId,
    });
    const lastMessage = lastMessages[0];

    const lastMessageText = lastMessageTextGenerator({
      text: lastMessage?.text,
      sticker: lastMessage?.sticker,
      fileType: lastMessage?.fileType,
    });

    if (message.chatType === "Channel") {
      await graphQLClient(res.locals.token).request(UPDATE_CHANNEL, {
        input: {
          objectId: message.chatId,
          lastMessageText,
        },
      });
    } else {
      await graphQLClient(res.locals.token).request(UPDATE_DIRECT, {
        input: {
          objectId: message.chatId,
          lastMessageText,
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
