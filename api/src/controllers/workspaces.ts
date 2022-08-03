import { WORKSPACE_PHOTO_MAX_WIDTH, WORKSPACE_THUMBNAIL_WIDTH } from "config";
import express from "express";
import {
  CREATE_CHANNEL,
  CREATE_DETAIL,
  CREATE_DIRECT,
  CREATE_WORKSPACE,
  UPDATE_CHANNEL,
  UPDATE_DIRECT,
  UPDATE_USER,
  UPDATE_WORKSPACE,
} from "graphql/mutations";
import {
  GET_CHANNEL,
  GET_USER,
  GET_WORKSPACE,
  LIST_CHANNELS,
  LIST_DIRECTS,
  LIST_USERS,
} from "graphql/queries";
import { sha256 } from "utils";
import { arrayRemove, arrayUnion } from "utils/array-helpers";
import graphQLClient from "utils/graphql";
import { getFileMetadata, saveImageThumbnail } from "utils/storage";
import { v4 as uuidv4 } from "uuid";

export const createWorkspace = async (
  req: express.Request,
  res: express.Response,
  next: express.NextFunction
) => {
  try {
    const { name, objectId: customObjectId } = req.body;
    const { uid } = res.locals;

    const promises = [];
    const workspaceId = customObjectId || uuidv4();
    const channelId = uuidv4();
    const directMessageId = uuidv4();

    await graphQLClient(res.locals.token).request(CREATE_CHANNEL, {
      input: {
        objectId: channelId,
        name: "general",
        members: [uid],
        typing: [],
        lastTypingReset: new Date().toISOString(),
        workspaceId,
        createdBy: uid,
        isDeleted: false,
        isArchived: false,
        topic: "",
        details: "",
        lastMessageCounter: 0,
        lastMessageText: "",
      },
    });

    promises.push(
      graphQLClient(res.locals.token).request(CREATE_DIRECT, {
        input: {
          objectId: directMessageId,
          members: [uid],
          typing: [],
          lastTypingReset: new Date().toISOString(),
          active: [uid],
          workspaceId,
          lastMessageCounter: 0,
          lastMessageText: "",
        },
      })
    );

    const detailChannelId = sha256(`${uid}#${channelId}`);
    promises.push(
      graphQLClient(res.locals.token).request(CREATE_DETAIL, {
        input: {
          objectId: detailChannelId,
          chatId: channelId,
          userId: uid,
          lastRead: 0,
          workspaceId,
        },
      })
    );

    const detailDmId = sha256(`${uid}#${directMessageId}`);
    promises.push(
      graphQLClient(res.locals.token).request(CREATE_DETAIL, {
        input: {
          objectId: detailDmId,
          chatId: directMessageId,
          userId: uid,
          lastRead: 0,
          workspaceId,
        },
      })
    );

    await Promise.all(promises);

    const { getUser: user } = await graphQLClient(res.locals.token).request(
      GET_USER,
      {
        objectId: uid,
      }
    );

    await graphQLClient(res.locals.token).request(UPDATE_USER, {
      input: {
        objectId: uid,
        workspaces: arrayUnion(user.workspaces, workspaceId),
      },
    });

    await graphQLClient(res.locals.token).request(CREATE_WORKSPACE, {
      input: {
        name,
        channelId,
        objectId: workspaceId,
        members: [uid],
        ownerId: uid,
        details: "",
        photoURL: "",
        thumbnailURL: "",
        isDeleted: false,
      },
    });

    res.locals.data = {
      workspaceId,
      channelId,
    };
    return next();
  } catch (err) {
    return next(err);
  }
};

export const updateWorkspace = async (
  req: express.Request,
  res: express.Response,
  next: express.NextFunction
) => {
  try {
    const { id: workspaceId } = req.params;
    const { uid } = res.locals;
    const { photoPath, name, details } = req.body;

    if (name === "") throw new Error("Name must be provided.");

    const { getWorkspace: workspace } = await graphQLClient(
      res.locals.token
    ).request(GET_WORKSPACE, {
      objectId: workspaceId,
    });

    if (name && workspace.ownerId !== uid)
      throw new Error("The workspace name can only be renamed by the owner.");

    if (!workspace.members.includes(uid))
      throw new Error("The user is not a member of the workspace.");

    const path = photoPath
      ? decodeURIComponent(
          photoPath.split("/storage/b/messenger/o/")[1].split("?token=")[0]
        )
      : "";
    const metadata = await getFileMetadata(path);
    const [thumbnailURL, , photoResizedURL] = await saveImageThumbnail({
      filePath: path,
      width: WORKSPACE_THUMBNAIL_WIDTH,
      height: WORKSPACE_THUMBNAIL_WIDTH,
      metadata,
      resizeOriginalSize: WORKSPACE_PHOTO_MAX_WIDTH,
      authToken: res.locals.token,
    });

    await graphQLClient(res.locals.token).request(UPDATE_WORKSPACE, {
      input: {
        objectId: workspaceId,
        ...(photoPath != null && {
          photoURL: photoResizedURL || photoPath,
          thumbnailURL,
        }),
        ...(details != null && { details }),
        ...(name && { name }),
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

export const deleteWorkspace = async (
  req: express.Request,
  res: express.Response,
  next: express.NextFunction
) => {
  try {
    const { id: workspaceId } = req.params;
    const { uid } = res.locals;

    const { getWorkspace: workspace } = await graphQLClient(
      res.locals.token
    ).request(GET_WORKSPACE, {
      objectId: workspaceId,
    });

    if (!workspace.members.includes(uid))
      throw new Error("The user is not a member of the workspace.");

    await graphQLClient(res.locals.token).request(UPDATE_WORKSPACE, {
      input: {
        objectId: workspaceId,
        isDeleted: true,
        members: [],
      },
    });

    // const snapshotDetails = await firestore
    //   .collection("Detail")
    //   .where("workspaceId", "==", workspaceId)
    //   .get();
    // await Promise.all(
    //   snapshotDetails.docs.map(async (doc) => {
    //     await doc.ref.delete();
    //   })
    // );

    const { listChannels: channels } = await graphQLClient(
      res.locals.token
    ).request(LIST_CHANNELS, {
      workspaceId,
    });

    await Promise.all(
      channels.map(async (doc: any) => {
        await graphQLClient(res.locals.token).request(UPDATE_CHANNEL, {
          input: {
            objectId: doc.objectId,
            isDeleted: true,
          },
        });
      })
    );

    const { listUsers: users } = await graphQLClient(res.locals.token).request(
      LIST_USERS,
      {
        workspaceId,
      }
    );

    await Promise.all(
      users.map(async (user: any) => {
        await graphQLClient(res.locals.token).request(UPDATE_USER, {
          input: {
            objectId: user.objectId,
            workspaces: arrayRemove(user.workspaces, workspaceId),
          },
        });
      })
    );

    res.locals.data = {
      success: true,
    };
    return next();
  } catch (err) {
    return next(err);
  }
};

export const addTeammate = async (
  req: express.Request,
  res: express.Response,
  next: express.NextFunction
) => {
  try {
    const { email } = req.body;
    const { id: workspaceId } = req.params;
    const { uid } = res.locals;

    const { getUser: user } = await graphQLClient(res.locals.token).request(
      GET_USER,
      {
        email,
      }
    );

    const { objectId: teammateId } = user;

    const { getWorkspace: workspace } = await graphQLClient(
      res.locals.token
    ).request(GET_WORKSPACE, {
      objectId: workspaceId,
    });

    // if (!workspace.members.includes(uid))
    //   throw new Error("The user is not a member of the workspace.");

    if (workspace.members.includes(teammateId))
      throw new Error(
        "Email is already associated with a user in this workspace."
      );

    const { getChannel: channel } = await graphQLClient(
      res.locals.token
    ).request(GET_CHANNEL, {
      objectId: workspace.channelId,
    });

    await graphQLClient(res.locals.token).request(UPDATE_WORKSPACE, {
      input: {
        objectId: workspaceId,
        members: arrayUnion(workspace.members, teammateId),
      },
    });

    await graphQLClient(res.locals.token).request(UPDATE_USER, {
      input: {
        objectId: teammateId,
        workspaces: arrayUnion(user.workspaces, workspaceId),
      },
    });

    await graphQLClient(res.locals.token).request(UPDATE_CHANNEL, {
      input: {
        objectId: channel.objectId,
        members: arrayUnion(channel.members, teammateId),
      },
    });

    const promises = [];

    // Added by another user than me
    if (uid !== teammateId) {
      const directMessageId = uuidv4();
      promises.push(
        graphQLClient(res.locals.token).request(CREATE_DIRECT, {
          input: {
            objectId: directMessageId,
            members: [uid, teammateId],
            active: [uid],
            typing: [],
            lastTypingReset: new Date().toISOString(),
            workspaceId,
            lastMessageCounter: 0,
            lastMessageText: "",
          },
        })
      );
      // New teammate chat details with me
      const d2 = sha256(`${teammateId}#${directMessageId}`);
      promises.push(
        graphQLClient(res.locals.token).request(CREATE_DETAIL, {
          input: {
            objectId: d2,
            chatId: directMessageId,
            userId: teammateId,
            lastRead: 0,
            workspaceId,
          },
        })
      );

      // My chat detail with the new teammate
      const d3 = sha256(`${uid}#${directMessageId}`);
      promises.push(
        graphQLClient(res.locals.token).request(CREATE_DETAIL, {
          input: {
            objectId: d3,
            chatId: directMessageId,
            userId: uid,
            lastRead: 0,
            workspaceId,
          },
        })
      );
    }

    const selfDirectMessageId = uuidv4();
    promises.push(
      graphQLClient(res.locals.token).request(CREATE_DIRECT, {
        input: {
          objectId: selfDirectMessageId,
          members: [teammateId],
          active: [teammateId],
          typing: [],
          lastTypingReset: new Date().toISOString(),
          workspaceId,
          lastMessageCounter: 0,
          lastMessageText: "",
        },
      })
    );

    // New teammate chat details with default channel
    const d1 = sha256(`${teammateId}#${channel.objectId}`);
    promises.push(
      graphQLClient(res.locals.token).request(CREATE_DETAIL, {
        input: {
          objectId: d1,
          chatId: channel.objectId,
          userId: teammateId,
          lastRead: channel.lastMessageCounter,
          workspaceId,
        },
      })
    );

    // New teammate chat details with himself
    const d4 = sha256(`${teammateId}#${selfDirectMessageId}`);
    promises.push(
      graphQLClient(res.locals.token).request(CREATE_DETAIL, {
        input: {
          objectId: d4,
          chatId: selfDirectMessageId,
          userId: teammateId,
          lastRead: 0,
          workspaceId,
        },
      })
    );

    await Promise.all(promises);

    res.locals.data = {
      succes: true,
    };
    return next();
  } catch (err: any) {
    if (err.message.includes("Cannot read property 'dataValues' of null"))
      err.message = "This email is not associated with any user.";
    return next(err);
  }
};

export const deleteTeammate = async (
  req: express.Request,
  res: express.Response,
  next: express.NextFunction
) => {
  try {
    const { id: workspaceId, userId } = req.params;
    const { uid } = res.locals;

    const { getWorkspace: workspace } = await graphQLClient(
      res.locals.token
    ).request(GET_WORKSPACE, {
      objectId: workspaceId,
    });

    const { getUser: user } = await graphQLClient(res.locals.token).request(
      GET_USER,
      {
        objectId: userId,
      }
    );

    if (!workspace.members.includes(uid))
      throw new Error("The user is not a member of the workspace.");

    await graphQLClient(res.locals.token).request(UPDATE_USER, {
      input: {
        objectId: userId,
        workspaces: arrayRemove(user.workspaces, workspaceId),
      },
    });

    await graphQLClient(res.locals.token).request(UPDATE_WORKSPACE, {
      input: {
        objectId: workspaceId,
        members: arrayRemove(workspace.members, userId),
      },
    });

    // const snapshot = await firestore
    //   .collection("Detail")
    //   .where("userId", "==", userId)
    //   .where("workspaceId", "==", workspaceId)
    //   .get();
    // await Promise.all(
    //   snapshot.docs.map(async (doc) => {
    //     await doc.ref.delete();
    //   })
    // );

    const { listDirects: dms } = await graphQLClient(res.locals.token).request(
      LIST_DIRECTS,
      {
        workspaceId,
        userId,
      }
    );

    await Promise.all(
      dms.map(async (dm: any) => {
        await graphQLClient(res.locals.token).request(UPDATE_DIRECT, {
          input: {
            objectId: dm.objectId,
            members: [],
            active: [],
          },
        });
      })
    );

    const { listChannels: channels } = await graphQLClient(
      res.locals.token
    ).request(LIST_CHANNELS, {
      workspaceId,
      userId,
    });
    await Promise.all(
      channels.map(async (channel: any) => {
        await graphQLClient(res.locals.token).request(UPDATE_CHANNEL, {
          input: {
            objectId: channel.objectId,
            members: arrayRemove(channel.members, userId),
          },
        });
      })
    );

    res.locals.data = {
      succes: true,
    };
    return next();
  } catch (err) {
    return next(err);
  }
};
