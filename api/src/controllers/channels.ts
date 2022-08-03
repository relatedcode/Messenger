import express from "express";
import {
  CREATE_CHANNEL,
  CREATE_DETAIL,
  UPDATE_CHANNEL,
  UPDATE_DETAIL,
} from "graphql/mutations";
import {
  GET_CHANNEL,
  GET_DETAIL,
  GET_USER,
  GET_WORKSPACE,
  LIST_CHANNELS,
} from "graphql/queries";
import { sha256, timeDiff } from "utils";
import { arrayRemove, arrayUnion } from "utils/array-helpers";
import graphQLClient from "utils/graphql";
import { v4 as uuidv4 } from "uuid";

export async function createOrUpdateDetails({
  token,
  uid,
  chat,
}: {
  token: string;
  uid: string;
  chat: any;
}) {
  const detailId = sha256(`${uid}#${chat.objectId}`);
  try {
    await graphQLClient(token).request(GET_DETAIL, {
      objectId: detailId,
    });

    // chatDetails already exists, so update it
    await graphQLClient(token).request(UPDATE_DETAIL, {
      input: {
        objectId: detailId,
        lastRead: chat.lastMessageCounter,
      },
    });
  } catch (err) {
    // chatDetails does not exist, so create it
    await graphQLClient(token).request(CREATE_DETAIL, {
      input: {
        objectId: detailId,
        chatId: chat.objectId,
        userId: uid,
        workspaceId: chat.workspaceId,
        lastRead: chat.lastMessageCounter,
      },
    });
  }
}

export const createChannel = async (
  req: express.Request,
  res: express.Response,
  next: express.NextFunction
) => {
  try {
    const { name, details, workspaceId, objectId: customObjectId } = req.body;
    const { uid } = res.locals;

    const { getWorkspace: workspace } = await graphQLClient(
      res.locals.token
    ).request(GET_WORKSPACE, {
      objectId: workspaceId,
    });

    if (!workspace.members.includes(uid))
      throw new Error("The user is not in the workspace.");

    const { listChannels: channels } = await graphQLClient(
      res.locals.token
    ).request(LIST_CHANNELS, {
      workspaceId,
      name: name.replace("#", ""),
    });
    if (channels.length) throw new Error("Channel already exists.");

    const channelId = customObjectId || uuidv4();
    const promises = [];

    promises.push(
      graphQLClient(res.locals.token).request(CREATE_CHANNEL, {
        input: {
          objectId: channelId,
          name: `${name.replace("#", "")}`,
          members: [uid],
          typing: [],
          workspaceId,
          createdBy: uid,
          topic: "",
          details: details || "",
          lastMessageText: "",
        },
      })
    );

    const detailId = sha256(`${uid}#${channelId}`);
    promises.push(
      graphQLClient(res.locals.token).request(CREATE_DETAIL, {
        input: {
          objectId: detailId,
          chatId: channelId,
          userId: uid,
          workspaceId,
        },
      })
    );

    await Promise.all(promises);

    res.locals.data = {
      channelId,
    };
    return next();
  } catch (err) {
    return next(err);
  }
};

export const updateChannel = async (
  req: express.Request,
  res: express.Response,
  next: express.NextFunction
) => {
  try {
    const { id: channelId } = req.params;
    const { uid } = res.locals;
    const { topic, details, name } = req.body;

    if (name != null && (name.trim() === "" || name.trim() === "#"))
      throw new Error("Channel name must be provided.");

    const { getChannel: channel } = await graphQLClient(
      res.locals.token
    ).request(GET_CHANNEL, {
      objectId: channelId,
    });

    if (name) {
      const { listChannels: channels } = await graphQLClient(
        res.locals.token
      ).request(LIST_CHANNELS, {
        workspaceId: channel.workspaceId,
        name: name.replace("#", ""),
      });
      if (channels.length) throw new Error("Channel name is already taken.");
    }

    if (!channel.members.includes(uid))
      throw new Error("The user is not in the channel.");

    await graphQLClient(res.locals.token).request(UPDATE_CHANNEL, {
      input: {
        objectId: channelId,
        ...(topic != null && { topic }),
        ...(details != null && { details }),
        ...(name && { name: name.replace("#", "") }),
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

export const deleteChannel = async (
  req: express.Request,
  res: express.Response,
  next: express.NextFunction
) => {
  try {
    const { id: channelId } = req.params;
    const { uid } = res.locals;

    const { getChannel: channel } = await graphQLClient(
      res.locals.token
    ).request(GET_CHANNEL, {
      objectId: channelId,
    });
    if (!channel.members.includes(uid))
      throw new Error("The user is not in the channel.");

    await graphQLClient(res.locals.token).request(UPDATE_CHANNEL, {
      input: {
        objectId: channelId,
        isDeleted: true,
      },
    });

    // const snapshot = await firestore
    //   .collection("Detail")
    //   .where("chatId", "==", channelId)
    //   .get();
    // await Promise.all(
    //   snapshot.docs.map(async (doc) => {
    //     await doc.ref.delete();
    //   })
    // );

    res.locals.data = {
      success: true,
    };
    return next();
  } catch (err) {
    return next(err);
  }
};

export const archiveChannel = async (
  req: express.Request,
  res: express.Response,
  next: express.NextFunction
) => {
  try {
    const { id: channelId } = req.params;
    const { uid } = res.locals;

    const { getChannel: channel } = await graphQLClient(
      res.locals.token
    ).request(GET_CHANNEL, {
      objectId: channelId,
    });
    if (!channel.members.includes(uid))
      throw new Error("The user is not in the channel.");

    await graphQLClient(res.locals.token).request(UPDATE_CHANNEL, {
      input: {
        objectId: channelId,
        isArchived: true,
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

export const unarchiveChannel = async (
  req: express.Request,
  res: express.Response,
  next: express.NextFunction
) => {
  try {
    const { id: channelId } = req.params;
    const { uid } = res.locals;

    const { getChannel: channel } = await graphQLClient(
      res.locals.token
    ).request(GET_CHANNEL, {
      objectId: channelId,
    });
    const { getWorkspace: workspace } = await graphQLClient(
      res.locals.token
    ).request(GET_WORKSPACE, {
      objectId: channel.workspaceId,
    });
    if (!workspace.members.includes(uid))
      throw new Error("The user is not in the workspace.");

    await graphQLClient(res.locals.token).request(UPDATE_CHANNEL, {
      input: {
        objectId: channelId,
        members: arrayUnion(channel.members, uid),
        isArchived: false,
      },
    });

    if (!channel.members.includes(uid)) {
      await createOrUpdateDetails({
        token: res.locals.token,
        uid,
        chat: channel,
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

export const addMember = async (
  req: express.Request,
  res: express.Response,
  next: express.NextFunction
) => {
  try {
    const { id: channelId } = req.params;
    const { email } = req.body;
    const { uid } = res.locals;

    const { getUser: user } = await graphQLClient(res.locals.token).request(
      GET_USER,
      {
        email,
      }
    );
    const { objectId: userId } = user;

    const { getChannel: channel } = await graphQLClient(
      res.locals.token
    ).request(GET_CHANNEL, {
      objectId: channelId,
    });
    const { getWorkspace: workspace } = await graphQLClient(
      res.locals.token
    ).request(GET_WORKSPACE, {
      objectId: channel.workspaceId,
    });

    if (!workspace.members.includes(uid))
      throw new Error("The user is not in this workspace.");

    if (!workspace.members.includes(userId))
      throw new Error("The user is not in this workspace.");

    await graphQLClient(res.locals.token).request(UPDATE_CHANNEL, {
      input: {
        objectId: channelId,
        members: arrayUnion(channel.members, userId),
      },
    });

    await createOrUpdateDetails({
      token: res.locals.token,
      uid: userId,
      chat: channel,
    });

    res.locals.data = {
      success: true,
    };
    return next();
  } catch (err) {
    return next(err);
  }
};

export const deleteMember = async (
  req: express.Request,
  res: express.Response,
  next: express.NextFunction
) => {
  try {
    const { id: channelId, userId } = req.params;
    const { uid } = res.locals;

    const { getChannel: channel } = await graphQLClient(
      res.locals.token
    ).request(GET_CHANNEL, {
      objectId: channelId,
    });
    if (!channel.members.includes(uid))
      throw new Error("The user is not in the channel.");

    await graphQLClient(res.locals.token).request(UPDATE_CHANNEL, {
      input: {
        objectId: channelId,
        members: arrayRemove(channel.members, userId),
      },
    });

    // const snapshot = await firestore
    //   .collection("Detail")
    //   .where("chatId", "==", channelId)
    //   .where("userId", "==", userId)
    //   .get();
    // await Promise.all(
    //   snapshot.docs.map(async (doc) => {
    //     await doc.ref.delete();
    //   })
    // );

    res.locals.data = {
      success: true,
    };
    return next();
  } catch (err) {
    return next(err);
  }
};

export const typingIndicator = async (
  req: express.Request,
  res: express.Response,
  next: express.NextFunction
) => {
  try {
    const { id: channelId } = req.params;
    const { isTyping } = req.body;
    const { uid } = res.locals;

    const { getChannel: channel } = await graphQLClient(
      res.locals.token
    ).request(GET_CHANNEL, {
      objectId: channelId,
    });

    if (!channel.members.includes(uid))
      throw new Error("The user is not in the channel.");

    if (
      (isTyping && !channel.typing.includes(uid)) ||
      (!isTyping && channel.typing.includes(uid))
    ) {
      await graphQLClient(res.locals.token).request(UPDATE_CHANNEL, {
        input: {
          objectId: channelId,
          typing: isTyping
            ? arrayUnion(channel.typing, uid)
            : arrayRemove(channel.typing, uid),
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

export const resetTyping = async (
  req: express.Request,
  res: express.Response,
  next: express.NextFunction
) => {
  try {
    const { id: channelId } = req.params;
    const { uid } = res.locals;

    const { getChannel: channel } = await graphQLClient(
      res.locals.token
    ).request(GET_CHANNEL, {
      objectId: channelId,
    });

    if (!channel.members.includes(uid))
      throw new Error("The user is not in the channel.");

    if (
      timeDiff(new Date(channel.lastTypingReset), Date.now()) >= 30 &&
      channel.typing.length > 0
    ) {
      await graphQLClient(res.locals.token).request(UPDATE_CHANNEL, {
        input: {
          objectId: channelId,
          typing: [],
          lastTypingReset: new Date().toISOString(),
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
