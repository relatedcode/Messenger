const MODEL_NAME_USER = "users";
module.exports.createUserResolver = function (
  database,
  Operation,
  withFilter,
  pubsub
) {
  return {
    Subscription: {
      onUpdateUser: {
        subscribe: withFilter(
          () => pubsub.asyncIterator(MODEL_NAME_USER),
          (payload, args) => {
            if (args.objectId) {
              return payload.onUpdateUser.objectId === args.objectId;
            }
            return true;
          }
        ),
      },
    },
    Query: {
      listUsers: async (root, args) => {
        let filter = {};
        if (args.updatedAt) {
          filter = {
            updatedAt: {
              [Operation.gt]: args.updatedAt,
            },
          };
        }
        if (args.workspaceId) {
          filter = {
            workspaces: {
              [Operation.contains]: [args.workspaceId],
            },
          };
        }
        return await database.models[MODEL_NAME_USER].findAll({
          where: filter,
        });
      },
      getUser: async (root, args) => {
        let filter = {};
        if (args.objectId) {
          filter = {
            objectId: {
              [Operation.eq]: args.objectId,
            },
          };
        }
        if (args.email) {
          filter = {
            email: {
              [Operation.eq]: args.email,
            },
          };
        }
        return (
          await database.models[MODEL_NAME_USER].findOne({
            where: filter,
          })
        ).dataValues;
      },
    },
    Mutation: {
      createUser: async (root, body, context, info) => {
        const { input: args } = body;
        const user = await database.models[MODEL_NAME_USER].create(args);
        pubsub.publish(MODEL_NAME_USER, {
          onUpdateUser: user.dataValues,
        });
        return user.dataValues;
      },
      updateUser: async (root, body, context, info) => {
        const { input: args } = body;
        const filter = {
          where: { objectId: args.objectId },
          returning: true,
        };
        const user = (
          await database.models[MODEL_NAME_USER].update(args, filter)
        )[1][0];
        pubsub.publish(MODEL_NAME_USER, {
          onUpdateUser: user.dataValues,
        });
        return user.dataValues;
      },
    },
  };
};

const MODEL_NAME_CHANNEL = "channels";
module.exports.createChannelResolver = function (
  database,
  Operation,
  withFilter,
  pubsub
) {
  return {
    Subscription: {
      onUpdateChannel: {
        subscribe: withFilter(
          () => pubsub.asyncIterator(MODEL_NAME_CHANNEL),
          (payload, args) => {
            if (args.objectId) {
              return payload.onUpdateChannel.objectId === args.objectId;
            }
            if (args.workspaceId) {
              return payload.onUpdateChannel.workspaceId === args.workspaceId;
            }
            return true;
          }
        ),
      },
    },
    Query: {
      listChannels: async (root, args) => {
        let filter = {};
        if (args.updatedAt) {
          filter = {
            updatedAt: {
              [Operation.gt]: args.updatedAt,
            },
          };
        }
        if (args.workspaceId) {
          filter = {
            workspaceId: args.workspaceId,
            isDeleted: false,
          };
        }
        if (args.workspaceId && args.userId) {
          filter = {
            members: {
              [Operation.contains]: [args.userId],
            },
            workspaceId: args.workspaceId,
            isDeleted: false,
          };
        }
        if (args.workspaceId && args.name) {
          filter = {
            name: args.name,
            workspaceId: args.workspaceId,
            isDeleted: false,
          };
        }
        return await database.models[MODEL_NAME_CHANNEL].findAll({
          where: filter,
        });
      },
      getChannel: async (root, args) => {
        let filter = {};
        if (args.objectId) {
          filter = {
            objectId: {
              [Operation.eq]: args.objectId,
            },
          };
        }
        return (
          await database.models[MODEL_NAME_CHANNEL].findOne({
            where: filter,
          })
        ).dataValues;
      },
    },
    Mutation: {
      createChannel: async (root, body, context, info) => {
        const { input: args } = body;
        const channel = await database.models[MODEL_NAME_CHANNEL].create(args);
        pubsub.publish(MODEL_NAME_CHANNEL, {
          onUpdateChannel: channel.dataValues,
        });
        return channel.dataValues;
      },
      updateChannel: async (root, body, context, info) => {
        const { input: args } = body;
        const filter = {
          where: { objectId: args.objectId },
          returning: true,
        };
        const channel = (
          await database.models[MODEL_NAME_CHANNEL].update(args, filter)
        )[1][0];
        pubsub.publish(MODEL_NAME_CHANNEL, {
          onUpdateChannel: channel.dataValues,
        });
        return channel.dataValues;
      },
    },
  };
};

const MODEL_NAME_DETAIL = "details";
module.exports.createDetailResolver = function (
  database,
  Operation,
  withFilter,
  pubsub
) {
  return {
    Subscription: {
      onUpdateDetail: {
        subscribe: withFilter(
          () => pubsub.asyncIterator(MODEL_NAME_DETAIL),
          (payload, args) => {
            if (args.objectId) {
              return payload.onUpdateDetail.objectId === args.objectId;
            }
            if (args.workspaceId && args.userId) {
              return (
                payload.onUpdateDetail.workspaceId === args.workspaceId &&
                payload.onUpdateDetail.userId === args.userId
              );
            }
            return true;
          }
        ),
      },
    },
    Query: {
      listDetails: async (root, args) => {
        let filter = {};
        if (args.updatedAt) {
          filter = {
            updatedAt: {
              [Operation.gt]: args.updatedAt,
            },
          };
        }
        if (args.workspaceId) {
          filter = {
            workspaceId: args.workspaceId,
          };
        }
        if (args.workspaceId && args.userId) {
          filter = {
            workspaceId: args.workspaceId,
            userId: args.userId,
          };
        }
        return await database.models[MODEL_NAME_DETAIL].findAll({
          where: filter,
        });
      },
      getDetail: async (root, args) => {
        let filter = {};
        if (args.objectId) {
          filter = {
            objectId: {
              [Operation.eq]: args.objectId,
            },
          };
        }
        return (
          await database.models[MODEL_NAME_DETAIL].findOne({
            where: filter,
          })
        ).dataValues;
      },
    },
    Mutation: {
      createDetail: async (root, body, context, info) => {
        const { input: args } = body;
        const detail = await database.models[MODEL_NAME_DETAIL].create(args);
        pubsub.publish(MODEL_NAME_DETAIL, {
          onUpdateDetail: detail.dataValues,
        });
        return detail.dataValues;
      },
      updateDetail: async (root, body, context, info) => {
        const { input: args } = body;
        const filter = {
          where: { objectId: args.objectId },
          returning: true,
        };
        const detail = (
          await database.models[MODEL_NAME_DETAIL].update(args, filter)
        )[1][0];
        pubsub.publish(MODEL_NAME_DETAIL, {
          onUpdateDetail: detail.dataValues,
        });
        return detail.dataValues;
      },
    },
  };
};

const MODEL_NAME_MESSAGE = "messages";
module.exports.createMessageResolver = function (
  database,
  Operation,
  withFilter,
  pubsub
) {
  return {
    Subscription: {
      onUpdateMessage: {
        subscribe: withFilter(
          () => pubsub.asyncIterator(MODEL_NAME_MESSAGE),
          (payload, args) => {
            if (args.objectId) {
              return payload.onUpdateMessage.objectId === args.objectId;
            }
            if (args.chatId) {
              return payload.onUpdateMessage.chatId === args.chatId;
            }
            return true;
          }
        ),
      },
    },
    Query: {
      listMessages: async (root, args) => {
        let filter = {};
        if (args.updatedAt) {
          filter = {
            updatedAt: {
              [Operation.gt]: args.updatedAt,
            },
          };
        }
        if (args.chatId) {
          filter = {
            chatId: args.chatId,
            isDeleted: false,
          };
        }
        return await database.models[MODEL_NAME_MESSAGE].findAll({
          where: {
            ...filter,
            ...(args.nextToken && {
              createdAt: {
                [Operation.lt]: args.nextToken,
              },
            }),
          },
          limit: args.limit || 30,
          order: [["createdAt", "DESC"]],
        });
      },
      getMessage: async (root, args) => {
        let filter = {};
        if (args.objectId) {
          filter = {
            objectId: {
              [Operation.eq]: args.objectId,
            },
          };
        }
        return (
          await database.models[MODEL_NAME_MESSAGE].findOne({
            where: filter,
          })
        ).dataValues;
      },
    },
    Mutation: {
      createMessage: async (root, body, context, info) => {
        const { input: args } = body;
        const message = await database.models[MODEL_NAME_MESSAGE].create(args);
        pubsub.publish(MODEL_NAME_MESSAGE, {
          onUpdateMessage: message.dataValues,
        });
        return message.dataValues;
      },
      updateMessage: async (root, body, context, info) => {
        const { input: args } = body;
        const filter = {
          where: { objectId: args.objectId },
          returning: true,
        };
        const message = (
          await database.models[MODEL_NAME_MESSAGE].update(args, filter)
        )[1][0];
        pubsub.publish(MODEL_NAME_MESSAGE, {
          onUpdateMessage: message.dataValues,
        });
        return message.dataValues;
      },
    },
  };
};

const MODEL_NAME_PRESENCE = "presences";
module.exports.createPresenceResolver = function (
  database,
  Operation,
  withFilter,
  pubsub
) {
  return {
    Subscription: {
      onUpdatePresence: {
        subscribe: withFilter(
          () => pubsub.asyncIterator(MODEL_NAME_PRESENCE),
          (payload, args) => {
            if (args.objectId) {
              return payload.onUpdatePresence.objectId === args.objectId;
            }
            return true;
          }
        ),
      },
    },
    Query: {
      listPresences: async (root, args) => {
        let filter = {};
        if (args.updatedAt) {
          filter = {
            updatedAt: {
              [Operation.gt]: args.updatedAt,
            },
          };
        }
        return await database.models[MODEL_NAME_PRESENCE].findAll({
          where: filter,
        });
      },
      getPresence: async (root, args) => {
        let filter = {};
        if (args.objectId) {
          filter = {
            objectId: args.objectId,
          };
        }
        return (
          await database.models[MODEL_NAME_PRESENCE].findOne({
            where: filter,
          })
        ).dataValues;
      },
    },
    Mutation: {
      createPresence: async (root, body, context, info) => {
        const { input: args } = body;
        const presence = await database.models[MODEL_NAME_PRESENCE].create(
          args
        );
        pubsub.publish(MODEL_NAME_PRESENCE, {
          onUpdatePresence: presence.dataValues,
        });
        return presence.dataValues;
      },
      updatePresence: async (root, body, context, info) => {
        const { input: args } = body;
        const filter = {
          where: { objectId: args.objectId },
          returning: true,
        };
        const presence = (
          await database.models[MODEL_NAME_PRESENCE].update(args, filter)
        )[1][0];
        pubsub.publish(MODEL_NAME_PRESENCE, {
          onUpdatePresence: presence.dataValues,
        });
        return presence.dataValues;
      },
    },
  };
};

const MODEL_NAME_WORKSPACE = "workspaces";
module.exports.createWorkspaceResolver = function (
  database,
  Operation,
  withFilter,
  pubsub
) {
  return {
    Subscription: {
      onUpdateWorkspace: {
        subscribe: withFilter(
          () => pubsub.asyncIterator(MODEL_NAME_WORKSPACE),
          (payload, args) => {
            if (args.objectId) {
              return payload.onUpdateWorkspace.objectId === args.objectId;
            }
            return true;
          }
        ),
      },
    },
    Query: {
      listWorkspaces: async (root, args) => {
        let filter = {};
        if (args.updatedAt) {
          filter = {
            updatedAt: {
              [Operation.gt]: args.updatedAt,
            },
          };
        }
        return await database.models[MODEL_NAME_WORKSPACE].findAll({
          where: filter,
        });
      },
      getWorkspace: async (root, args) => {
        let filter = {};
        if (args.objectId) {
          filter = {
            objectId: {
              [Operation.eq]: args.objectId,
            },
          };
        }
        return (
          await database.models[MODEL_NAME_WORKSPACE].findOne({
            where: filter,
          })
        ).dataValues;
      },
    },
    Mutation: {
      createWorkspace: async (root, body, context, info) => {
        const { input: args } = body;
        const workspace = await database.models[MODEL_NAME_WORKSPACE].create(
          args
        );
        pubsub.publish(MODEL_NAME_WORKSPACE, {
          onUpdateWorkspace: workspace.dataValues,
        });
        return workspace.dataValues;
      },
      updateWorkspace: async (root, body, context, info) => {
        const { input: args } = body;
        const filter = {
          where: { objectId: args.objectId },
          returning: true,
        };
        const workspace = (
          await database.models[MODEL_NAME_WORKSPACE].update(args, filter)
        )[1][0];
        pubsub.publish(MODEL_NAME_WORKSPACE, {
          onUpdateWorkspace: workspace.dataValues,
        });
        return workspace.dataValues;
      },
    },
  };
};

const MODEL_NAME_DIRECT = "directs";
module.exports.createDirectResolver = function (
  database,
  Operation,
  withFilter,
  pubsub
) {
  return {
    Subscription: {
      onUpdateDirect: {
        subscribe: withFilter(
          () => pubsub.asyncIterator(MODEL_NAME_DIRECT),
          (payload, args) => {
            if (args.objectId) {
              return payload.onUpdateDirect.objectId === args.objectId;
            }
            if (args.workspaceId) {
              return payload.onUpdateDirect.workspaceId === args.workspaceId;
            }
            return true;
          }
        ),
      },
    },
    Query: {
      listDirects: async (root, args) => {
        let filter = {};
        if (args.updatedAt) {
          filter = {
            updatedAt: {
              [Operation.gt]: args.updatedAt,
            },
          };
        }
        if (args.workspaceId) {
          filter = {
            workspaceId: args.workspaceId,
          };
        }
        if (args.workspaceId && args.userId) {
          filter = {
            members: {
              [Operation.contains]: [args.userId],
            },
            workspaceId: args.workspaceId,
          };
        }
        return await database.models[MODEL_NAME_DIRECT].findAll({
          where: filter,
        });
      },
      getDirect: async (root, args) => {
        let filter = {};
        if (args.objectId) {
          filter = {
            objectId: {
              [Operation.eq]: args.objectId,
            },
          };
        }
        return (
          await database.models[MODEL_NAME_DIRECT].findOne({
            where: filter,
          })
        ).dataValues;
      },
    },
    Mutation: {
      createDirect: async (root, body, context, info) => {
        const { input: args } = body;
        const direct = await database.models[MODEL_NAME_DIRECT].create(args);
        pubsub.publish(MODEL_NAME_DIRECT, {
          onUpdateDirect: direct.dataValues,
        });
        return direct.dataValues;
      },
      updateDirect: async (root, body, context, info) => {
        const { input: args } = body;
        const filter = {
          where: { objectId: args.objectId },
          returning: true,
        };
        const direct = (
          await database.models[MODEL_NAME_DIRECT].update(args, filter)
        )[1][0];
        pubsub.publish(MODEL_NAME_DIRECT, {
          onUpdateDirect: direct.dataValues,
        });
        return direct.dataValues;
      },
    },
  };
};

const MODEL_NAME_REACTION = "reactions";
module.exports.createReactionResolver = function (
  database,
  Operation,
  withFilter,
  pubsub
) {
  return {
    Subscription: {
      onUpdateReaction: {
        subscribe: withFilter(
          () => pubsub.asyncIterator(MODEL_NAME_REACTION),
          (payload, args) => {
            if (args.objectId) {
              return payload.onUpdateReaction.objectId === args.objectId;
            }
            if (args.chatId) {
              return payload.onUpdateReaction.chatId === args.chatId;
            }
            return true;
          }
        ),
      },
    },
    Query: {
      listReactions: async (root, args) => {
        let filter = {};
        if (args.updatedAt) {
          filter = {
            updatedAt: {
              [Operation.gt]: args.updatedAt,
            },
          };
        }
        if (args.chatId) {
          filter = {
            chatId: args.chatId,
          };
        }
        return await database.models[MODEL_NAME_REACTION].findAll({
          where: filter,
        });
      },
      getReaction: async (root, args) => {
        let filter = {};
        if (args.objectId) {
          filter = {
            objectId: {
              [Operation.eq]: args.objectId,
            },
          };
        }
        return (
          await database.models[MODEL_NAME_REACTION].findOne({
            where: filter,
          })
        ).dataValues;
      },
    },
    Mutation: {
      createReaction: async (root, body, context, info) => {
        const { input: args } = body;
        const reaction = await database.models[MODEL_NAME_REACTION].create(
          args
        );
        pubsub.publish(MODEL_NAME_REACTION, {
          onUpdateReaction: reaction.dataValues,
        });
        return reaction.dataValues;
      },
      updateReaction: async (root, body, context, info) => {
        const { input: args } = body;
        const filter = {
          where: { objectId: args.objectId },
          returning: true,
        };
        const reaction = (
          await database.models[MODEL_NAME_REACTION].update(args, filter)
        )[1][0];
        pubsub.publish(MODEL_NAME_REACTION, {
          onUpdateReaction: reaction.dataValues,
        });
        return reaction.dataValues;
      },
    },
  };
};
