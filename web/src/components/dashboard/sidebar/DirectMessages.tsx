import { Disclosure } from "@headlessui/react";
import { DotsHorizontalIcon, PlusIcon, XIcon } from "@heroicons/react/outline";
import AddTeammatesModal from "components/dashboard/workspaces/AddTeammatesModal";
import Spinner from "components/Spinner";
import { DirectMessagesContext } from "contexts/DirectMessagesContext";
import { useModal } from "contexts/ModalContext";
import { useTheme } from "contexts/ThemeContext";
import { useUser } from "contexts/UserContext";
import { useDetailByChat } from "hooks/useDetails";
import { usePresenceByUserId } from "hooks/usePresence";
import { useUserById } from "hooks/useUsers";
import { ReactComponent as ArrowIcon } from "icons/arrow.svg";
import { useContext, useState } from "react";
import toast from "react-hot-toast";
import { useNavigate, useParams } from "react-router-dom";
import { postData } from "utils/api-helpers";
import classNames from "utils/classNames";
import { getHref } from "utils/get-file-url";

function DirectMessage({ dm }: { dm: any }) {
  const { themeColors } = useTheme();
  const navigate = useNavigate();
  const { workspaceId, dmId } = useParams();

  const { user } = useUser();

  const isMe = dm?.members?.length === 1 && dm?.members[0] === user?.uid;
  const otherUserId = dm?.members.find((m: string) => m !== user?.uid);

  const { value } = useUserById(otherUserId || user?.uid);
  const { isPresent } = usePresenceByUserId(otherUserId || user?.uid);

  const photoURL = getHref(value?.thumbnailURL) || getHref(value?.photoURL);

  const { value: detail } = useDetailByChat(dm?.objectId);
  const notifications = dm
    ? dm.lastMessageCounter - (detail?.lastRead || 0)
    : 0;

  const [loading, setLoading] = useState(false);

  const selected = dmId === dm?.objectId;

  const typingArray = dm?.typing?.filter((typ: any) => typ !== user?.uid);

  const closeConversation = async () => {
    setLoading(true);
    try {
      const id = dm?.objectId;
      await postData(`/directs/${dm?.objectId}/close`);
      if (dmId === id) navigate(`/dashboard/workspaces/${workspaceId}`);
    } catch (err: any) {
      toast.error(err.message);
    }
    setLoading(false);
  };
  return (
    <div
      className="relative py-1 flex items-center justify-between cursor-pointer focus:outline-none group"
      style={{
        backgroundColor: selected ? themeColors?.blue : "transparent",
        color: selected ? themeColors?.brightWhite : themeColors?.foreground,
      }}
    >
      <div
        className="pl-8 flex items-center w-full focus:outline-none"
        role="button"
        tabIndex={0}
        onClick={() =>
          navigate(`/dashboard/workspaces/${workspaceId}/dm/${dm?.objectId}`)
        }
      >
        <div className="relative mr-2 flex-shrink-0">
          <div
            className={classNames(
              selected ? "th-bg-blue" : "th-bg-selbg",
              "rounded-full h-3 w-3 absolute bottom-0 right-0 transform translate-x-1 translate-y-1 flex items-center justify-center"
            )}
          >
            <div
              style={{
                backgroundColor: isPresent ? "#94e864" : "transparent",
              }}
              className={classNames(
                isPresent ? "" : "border border-gray-400",
                "rounded-full h-2 w-2"
              )}
            />
          </div>
          <img
            src={photoURL || `${process.env.PUBLIC_URL}/blank_user.png`}
            alt="message"
            className="rounded h-5 w-5"
          />
        </div>
        <div
          className={classNames(
            notifications ? "font-semibold" : "",
            "truncate w-36",
            selected ? "th-color-brwhite" : "th-color-for"
          )}
        >
          {!isMe ? value?.displayName : `${value?.displayName} (me)`}
        </div>
      </div>
      <div className="mr-3">
        {notifications > 0 && !typingArray?.length && (
          <div
            style={{
              paddingTop: "2px",
              paddingBottom: "2px",
              marginTop: "2px",
              marginBottom: "2px",
            }}
            className="text-xs rounded px-2 focus:outline-none th-color-brwhite th-bg-red font-semibold flex items-center justify-center"
            role="button"
            tabIndex={0}
            onClick={() =>
              navigate(
                `/dashboard/workspaces/${workspaceId}/dm/${dm?.objectId}`
              )
            }
          >
            {notifications}
          </div>
        )}
        {notifications > 0 && typingArray?.length > 0 && (
          <div
            style={{
              paddingTop: "2px",
              paddingBottom: "2px",
              marginTop: "2px",
              marginBottom: "2px",
            }}
            className="rounded flex items-centerjustify-center px-1 th-color-brwhite th-bg-red font-semibold text-xs"
          >
            <DotsHorizontalIcon className="h-4 w-4 animate-bounce" />
          </div>
        )}
        {!notifications && !loading && typingArray?.length > 0 && (
          <div
            style={{ paddingTop: "4px", paddingBottom: "4px" }}
            className="rounded flex items-center justify-center px-2 th-color-brwhite font-semibold text-xs"
          >
            <DotsHorizontalIcon className="h-4 w-4 animate-bounce" />
          </div>
        )}
        {!notifications && !typingArray?.length && loading && (
          <Spinner className="h-4 w-4 flex-shrink-0 m-1" />
        )}
        {!notifications && !loading && !typingArray?.length && (
          <XIcon
            onClick={closeConversation}
            className="flex-shrink-0 h-6 w-6 p-1 opacity-0 group-hover:opacity-100"
          />
        )}
      </div>
    </div>
  );
}

function AddTeammates() {
  const { setOpenCreateMessage: setOpen, setCreateMessageSection: setSection } =
    useModal();
  return (
    <div
      role="button"
      tabIndex={0}
      className="flex items-center px-8 cursor-pointer focus:outline-none pt-2"
      onClick={() => {
        setOpen(true);
        setSection("members");
      }}
    >
      <div className="flex items-center justify-center rounded p-1 mr-2 th-bg-blue">
        <PlusIcon className="h-3 w-3 th-color-brwhite" />
      </div>
      <h5 className="th-color-for">Add members</h5>
    </div>
  );
}

export default function DirectMessages() {
  const { themeColors } = useTheme();
  const { value } = useContext(DirectMessagesContext);
  return (
    <div>
      <Disclosure defaultOpen>
        {({ open }) => (
          <>
            <Disclosure.Button className="flex justify-between items-center px-4 cursor-pointer">
              <div className="flex items-center">
                <ArrowIcon
                  className={classNames(
                    open ? "transform rotate-90" : "",
                    "h-4 w-4 mr-2"
                  )}
                  style={{
                    color: themeColors?.foreground,
                  }}
                />
                <h5 className="th-color-for">Direct messages</h5>
              </div>
            </Disclosure.Button>
            <Disclosure.Panel
              style={{ color: themeColors?.foreground }}
              className="pt-3 pb-2 text-sm space-y-1"
            >
              {value?.map((doc: any) => (
                <DirectMessage key={doc.objectId} dm={doc} />
              ))}
              <AddTeammates />
            </Disclosure.Panel>
          </>
        )}
      </Disclosure>
      <AddTeammatesModal />
    </div>
  );
}
