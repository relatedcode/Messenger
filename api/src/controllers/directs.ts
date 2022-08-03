import express from "express";
import { CREATE_DETAIL, CREATE_DIRECT, UPDATE_DIRECT } from "graphql/mutations";
import { GET_DIRECT, GET_WORKSPACE, LIST_DIRECTS } from "graphql/queries";
import { sha256, timeDiff } from "utils";
import { arrayRemove, arrayUnion } from "utils/array-helpers";
import graphQLClient from "utils/graphql";
import { v4 as uuidv4 } from "uuid";

export const createDirect = async (
  req: express.Request,
  res: express.Response,
  next: express.NextFunction
) => {
  try {
    const { userId, workspaceId } = req.body;
    const { uid } = res.locals;

    const isMe = userId === uid;

    const { getWorkspace: workspace } = await graphQLClient(
      res.locals.token
    ).request(GET_WORKSPACE, {
      objectId: workspaceId,
    });
    if (!workspace.members.includes(uid))
      throw new Error("The user is not a member of this workspace");

    const { listDirects: dms } = await graphQLClient(res.locals.token).request(
      LIST_DIRECTS,
      {
        workspaceId,
        userId: uid,
      }
    );

    const activeArray = [uid];

    if (isMe) {
      const currentDm = dms.find((dm: any) => dm.members.length === 1);
      const directMessageId = currentDm ? currentDm.objectId : uuidv4();
      if (currentDm) {
        // Activate the existing direct (a self direct has already been created in the past)

        await graphQLClient(res.locals.token).request(UPDATE_DIRECT, {
          input: {
            objectId: currentDm.objectId,
            active: activeArray,
          },
        });
      } else {
        // Create a new direct (no self direct in this workspace before)
        await graphQLClient(res.locals.token).request(CREATE_DIRECT, {
          input: {
            objectId: directMessageId,
            members: [uid],
            typing: [],
            active: activeArray,
            workspaceId,
            lastMessageText: "",
          },
        });

        const detailDmId = sha256(`${uid}#${directMessageId}`);
        await graphQLClient(res.locals.token).request(CREATE_DETAIL, {
          input: {
            objectId: detailDmId,
            chatId: directMessageId,
            userId: uid,
            workspaceId,
          },
        });
      }
      res.locals.data = {
        directId: directMessageId,
      };
      return next();
    }

    // uid wants to send a message to another user than him
    const currentDm = dms.find((dm: any) => dm.members.includes(userId));

    // Activate the existing direct (a direct between uid and teammateId has been open in the past)
    if (currentDm) {
      await graphQLClient(res.locals.token).request(UPDATE_DIRECT, {
        input: {
          objectId: currentDm.objectId,
          active: arrayUnion(currentDm.active, uid),
        },
      });

      res.locals.data = {
        directId: currentDm.objectId,
      };
      return next();
    }

    // Create a new direct (no direct between these users in this workspace before)
    const promises = [];
    const directMessageId = uuidv4();
    promises.push(
      graphQLClient(res.locals.token).request(CREATE_DIRECT, {
        input: {
          objectId: directMessageId,
          members: [uid, userId],
          typing: [],
          active: activeArray,
          workspaceId,
        },
      })
    );

    const d1 = sha256(`${uid}#${directMessageId}`);
    promises.push(
      graphQLClient(res.locals.token).request(CREATE_DETAIL, {
        input: {
          objectId: d1,
          chatId: directMessageId,
          userId: uid,
          workspaceId,
        },
      })
    );

    const d2 = sha256(`${userId}#${directMessageId}`);
    promises.push(
      graphQLClient(res.locals.token).request(CREATE_DETAIL, {
        input: {
          objectId: d2,
          chatId: directMessageId,
          userId: userId,
          workspaceId,
        },
      })
    );

    res.locals.data = {
      directId: directMessageId,
    };
    return next();
  } catch (err) {
    return next(err);
  }
};

export const closeDirect = async (
  req: express.Request,
  res: express.Response,
  next: express.NextFunction
) => {
  try {
    const { id } = req.params;
    const { uid } = res.locals;

    const { getDirect: direct } = await graphQLClient(res.locals.token).request(
      GET_DIRECT,
      {
        objectId: id,
      }
    );
    if (!direct.members.includes(uid))
      throw new Error("The user is not a member of this Direct");

    await graphQLClient(res.locals.token).request(UPDATE_DIRECT, {
      input: {
        objectId: id,
        active: arrayRemove(direct.active, uid),
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

export const typingIndicator = async (
  req: express.Request,
  res: express.Response,
  next: express.NextFunction
) => {
  try {
    const { id: dmId } = req.params;
    const { isTyping } = req.body;
    const { uid } = res.locals;

    const { getDirect: direct } = await graphQLClient(res.locals.token).request(
      GET_DIRECT,
      {
        objectId: dmId,
      }
    );

    if (!direct.members.includes(uid))
      throw new Error("The user is not in the Direct.");

    if (
      (isTyping && !direct.typing.includes(uid)) ||
      (!isTyping && direct.typing.includes(uid))
    ) {
      await graphQLClient(res.locals.token).request(UPDATE_DIRECT, {
        input: {
          objectId: dmId,
          typing: isTyping
            ? arrayUnion(direct.typing, uid)
            : arrayRemove(direct.typing, uid),
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
    const { id: dmId } = req.params;
    const { uid } = res.locals;

    const { getDirect: direct } = await graphQLClient(res.locals.token).request(
      GET_DIRECT,
      {
        objectId: dmId,
      }
    );

    if (!direct.members.includes(uid))
      throw new Error("The user is not in the Direct.");

    if (
      timeDiff(new Date(direct.lastTypingReset), Date.now()) >= 30 &&
      direct.typing.length > 0
    ) {
      await graphQLClient(res.locals.token).request(UPDATE_DIRECT, {
        input: {
          objectId: dmId,
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
