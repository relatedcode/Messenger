import { XIcon } from "@heroicons/react/outline";
import ChatArea from "components/dashboard/ChatArea";
import Navbar from "components/dashboard/navbar/Navbar";
import Sidebar from "components/dashboard/sidebar/Sidebar";
import Workspaces from "components/dashboard/workspaces/Workspaces";
import LoadingScreen from "components/LoadingScreen";
import { APP_NAME } from "config";
import { useUser } from "contexts/UserContext";
import { usePresenceByUserId } from "hooks/usePresence";
import { useUserById } from "hooks/useUsers";
import { useMyWorkspaces } from "hooks/useWorkspaces";
import { useEffect } from "react";
import { Helmet } from "react-helmet-async";
import {
  Navigate,
  useLocation,
  useNavigate,
  useParams,
} from "react-router-dom";
import { postData } from "utils/api-helpers";
import classNames from "utils/classNames";
import { getHref } from "utils/get-file-url";

function ProfileViewItem({ value, text }: { value: string; text: string }) {
  return (
    <div className="flex flex-col px-5 w-full">
      <span className="font-bold text-sm th-color-for">{text}</span>
      <span className="font-normal truncate w-full th-color-for">{value}</span>
    </div>
  );
}

function ProfileView() {
  const location = useLocation();
  const navigate = useNavigate();
  const userId = location.pathname.split("/user_profile/")[1];

  const { value } = useUserById(userId);
  const { isPresent } = usePresenceByUserId(userId);

  const photoURL = getHref(value?.photoURL);

  return (
    <div className="row-span-2 border-l flex flex-col overflow-hidden th-border-selbg">
      <div className="h-14 border-b flex items-center justify-between py-1 px-4 th-border-selbg">
        <span className="text-lg font-bold th-color-for">Profile</span>
        <XIcon
          onClick={() => navigate(location.pathname.split("/user_profile")[0])}
          className="h-5 w-5 cursor-pointer th-color-for"
        />
      </div>
      <div className="flex-1 overflow-y-auto flex flex-col items-center">
        <div
          className="h-40 w-40 md:h-44 md:w-44 lg:h-56 lg:w-56 rounded mt-4 bg-cover"
          style={{
            backgroundImage: `url(${
              photoURL || `${process.env.PUBLIC_URL}/blank_user.png`
            })`,
          }}
        />
        <div className="flex items-center justify-center mt-4 mb-8 w-full">
          <span className="font-extrabold text-lg truncate max-w-3/4 th-color-for">
            {value?.fullName}
          </span>
          <div
            className={classNames(
              isPresent
                ? "bg-green-500"
                : "bg-transparent border border-gray-500",
              "h-2 w-2 rounded-full ml-2"
            )}
          />
        </div>
        <div className="space-y-3 w-full">
          <ProfileViewItem text="Display name" value={value?.displayName} />
          <ProfileViewItem text="Email address" value={value?.email} />
          {value?.phoneNumber && (
            <ProfileViewItem text="Phone number" value={value?.phoneNumber} />
          )}
          {value?.title && (
            <ProfileViewItem text="What I do?" value={value?.title} />
          )}
        </div>
      </div>
    </div>
  );
}

export default function Dashboard() {
  const { workspaceId, channelId, dmId } = useParams();
  const { value, loading } = useMyWorkspaces();
  const { user } = useUser();
  const location = useLocation();
  const profile = location.pathname?.includes("user_profile");

  useEffect(() => {
    if (user?.uid) {
      postData(`/users/${user?.uid}/presence`, {}, {}, false);
      const intId = setInterval(() => {
        postData(`/users/${user?.uid}/presence`, {}, {}, false);
      }, 30000);
      return () => clearInterval(intId);
    }
  }, [user?.uid]);

  useEffect(() => {
    const appHeight = () => {
      const vh = window.innerHeight * 0.01;
      document.documentElement.style.setProperty("--vh", `${vh}px`);
    };
    window.addEventListener("resize", appHeight);
  }, []);

  if (loading) return <LoadingScreen />;

  if (value?.length === 0) return <Navigate to="/dashboard/new_workspace" />;

  if (!workspaceId || !value.find((w: any) => w.objectId === workspaceId))
    return (
      <Navigate
        to={`/dashboard/workspaces/${value[0].objectId}/channels/${value[0].channelId}`}
      />
    );

  if (workspaceId && !channelId && !dmId)
    return (
      <Navigate
        to={`/dashboard/workspaces/${workspaceId}/channels/${
          value.find((w: any) => w.objectId === workspaceId)?.channelId
        }`}
      />
    );

  return (
    <>
      <Helmet>
        <title>{APP_NAME}</title>
      </Helmet>
      <div
        className={classNames(
          profile ? "grid-cols-profile" : "grid-cols-main",
          "h-screen grid overflow-hidden grid-rows-main"
        )}
      >
        <Navbar />
        <Workspaces />
        <Sidebar />
        <ChatArea />
        {profile && <ProfileView />}
      </div>
    </>
  );
}
