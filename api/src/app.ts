import * as channels from "controllers/channels";
import * as directs from "controllers/directs";
import * as messages from "controllers/messages";
import * as users from "controllers/users";
import * as workspaces from "controllers/workspaces";
import cors from "cors";
import express from "express";
import { verifyToken } from "utils/auth";

const app = express();

app.set("json spaces", 2);
app.use(cors({ origin: "*", methods: "GET,POST,HEAD,OPTIONS,DELETE" }));
app.use(express.urlencoded({ extended: true }));
app.use(express.json());

app.get(
  "/warm",
  async (
    req: express.Request,
    res: express.Response,
    next: express.NextFunction
  ) => {
    return res.status(200).json({
      success: true,
    });
  }
);

const authMiddleware = async (
  req: express.Request,
  res: express.Response,
  next: express.NextFunction
) => {
  try {
    if (!(req.headers && req.headers.authorization))
      throw new Error("The function must be called by an authenticated user.");

    const token = req.headers.authorization.split("Bearer ")[1];
    if (!token)
      throw new Error("The function must be called by an authenticated user.");

    const decodedToken = (await verifyToken(token)) as any;

    res.locals.uid = decodedToken.uid;
    res.locals.token = token;
    return next();
  } catch (err) {
    return next(err);
  }
};

const channelsRouter = express.Router();
channelsRouter.use(authMiddleware);
channelsRouter.post("/", channels.createChannel);
channelsRouter.post("/:id", channels.updateChannel);
channelsRouter.post("/:id/members", channels.addMember);
channelsRouter.delete("/:id/members/:userId", channels.deleteMember);
channelsRouter.delete("/:id", channels.deleteChannel);
channelsRouter.post("/:id/archive", channels.archiveChannel);
channelsRouter.post("/:id/unarchive", channels.unarchiveChannel);
channelsRouter.post("/:id/typing_indicator", channels.typingIndicator);
channelsRouter.post("/:id/reset_typing", channels.resetTyping);

const directsRouter = express.Router();
directsRouter.use(authMiddleware);
directsRouter.post("/", directs.createDirect);
directsRouter.post("/:id/close", directs.closeDirect);
directsRouter.post("/:id/typing_indicator", directs.typingIndicator);
directsRouter.post("/:id/reset_typing", directs.resetTyping);

const workspacesRouter = express.Router();
workspacesRouter.use(authMiddleware);
workspacesRouter.post("/", workspaces.createWorkspace);
workspacesRouter.post("/:id", workspaces.updateWorkspace);
workspacesRouter.delete("/:id", workspaces.deleteWorkspace);
workspacesRouter.post("/:id/members", workspaces.addTeammate);
workspacesRouter.delete("/:id/members/:userId", workspaces.deleteTeammate);

const messagesRouter = express.Router();
messagesRouter.use(authMiddleware);
messagesRouter.post("/", messages.createMessage);
messagesRouter.post("/:id", messages.editMessage);
messagesRouter.delete("/:id", messages.deleteMessage);
messagesRouter.post("/:id/reactions", messages.editMessageReaction);

const usersRouter = express.Router();
usersRouter.post("/", users.createUser);
usersRouter.post("/:id", authMiddleware, users.updateUser);
usersRouter.post("/:id/presence", authMiddleware, users.updatePresence);
usersRouter.post("/:id/read", authMiddleware, users.read);

app.use("/users", usersRouter);
app.use("/messages", messagesRouter);
app.use("/channels", channelsRouter);
app.use("/workspaces", workspacesRouter);
app.use("/directs", directsRouter);

app.use(
  (req: express.Request, res: express.Response, next: express.NextFunction) => {
    if (!res.locals.data) throw new Error("The requested URL was not found.");
    res.statusCode = 200;
    if (res.locals.data === true) return res.end();
    res.set("Content-Type", "application/json");
    return res.json(res.locals.data);
  }
);

app.use(
  (
    err: any,
    req: express.Request,
    res: express.Response,
    next: express.NextFunction
  ) => {
    res.set("Content-Type", "application/json");
    res.statusCode = 400;
    console.error(err.message);
    return res.json({
      error: {
        message: err.message,
      },
    });
  }
);

app.listen(4001, () =>
  console.log("🚀 Related:Chat API is listening on port 4001...")
);
