import AuthGuard from "components/AuthGuard";
import GuestGuard from "components/GuestGuard";
import LoadingScreen from "components/LoadingScreen";
import Login from "pages/authentication/Login";
import Signup from "pages/authentication/Signup";
import Logout from "pages/dashboard/Logout";
import NewWorkspace from "pages/dashboard/NewWorkspace";
import NotFound from "pages/NotFound";
import { lazy, Suspense } from "react";

const Loadable = (Component: any) => (props: any) =>
  (
    <Suspense fallback={<LoadingScreen />}>
      <Component {...props} />
    </Suspense>
  );

const Dashboard = Loadable(lazy(() => import("pages/dashboard/Dashboard")));

const routes = [
  {
    path: "authentication",
    children: [
      {
        path: "login",
        element: (
          <GuestGuard>
            <Login />
          </GuestGuard>
        ),
      },
      {
        path: "register",
        element: (
          <GuestGuard>
            <Signup />
          </GuestGuard>
        ),
      },
    ],
  },
  {
    path: "/dashboard",
    children: [
      {
        path: "",
        element: (
          <AuthGuard>
            <Dashboard />
          </AuthGuard>
        ),
      },
      {
        path: "new_workspace",
        element: (
          <AuthGuard>
            <NewWorkspace />
          </AuthGuard>
        ),
      },
      {
        path: "workspaces/:workspaceId",
        children: [
          {
            path: "",
            element: (
              <AuthGuard>
                <Dashboard />
              </AuthGuard>
            ),
          },
          {
            path: "channels/:channelId/*",
            element: (
              <AuthGuard>
                <Dashboard />
              </AuthGuard>
            ),
          },
          {
            path: "dm/:dmId/*",
            element: (
              <AuthGuard>
                <Dashboard />
              </AuthGuard>
            ),
          },
        ],
      },
      {
        path: "logout",
        element: <Logout />,
      },
    ],
  },
  {
    path: "*",
    children: [
      {
        path: "",
        element: (
          <GuestGuard>
            <Login />
          </GuestGuard>
        ),
      },
      {
        path: "404",
        element: <NotFound />,
      },
      {
        path: "*",
        element: <NotFound />,
      },
    ],
  },
];

export default routes;
