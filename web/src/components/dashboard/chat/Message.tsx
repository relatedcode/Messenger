import { DocumentTextIcon, DownloadIcon } from "@heroicons/react/outline";
import { PencilIcon, TrashIcon } from "@heroicons/react/solid";
import EditMessage from "components/dashboard/chat/EditMessage";
import QuillReader from "components/dashboard/quill/QuillReader";
import { ReactionModal } from "components/ReactionModal";
import Spinner from "components/Spinner";
import { useReactions } from "contexts/ReactionsContext";
import { useTheme } from "contexts/ThemeContext";
import { useUser } from "contexts/UserContext";
import { useUserById } from "hooks/useUsers";
import { reactions } from "lib/reactions";
import React, { useMemo, useRef, useState } from "react";
import toast from "react-hot-toast";
import { useLocation, useNavigate, useParams } from "react-router-dom";
import styled from "styled-components";
import { deleteData } from "utils/api-helpers";
import bytesToSize from "utils/bytesToSize";
import classNames from "utils/classNames";
import { getHref } from "utils/get-file-url";
import hexToRgbA from "utils/hexToRgbA";

const MessageDiv = styled.div`
  :hover {
    background-color: ${(props) =>
      hexToRgbA(props.theme.selectionBackground, "0.4")};
  }
`;

function UserName({ id }: { id: string }) {
  const { value } = useUserById(id);

  return (
    <span className="after:content-[',_'] last:after:content-['_'] font-semibold">
      {value?.displayName}
    </span>
  );
}

function Reactions({ groupedReactions }: { groupedReactions: any[] }) {
  const keys = Object.keys(groupedReactions);

  return (
    <div className="flex space-x-2 mt-1 px-12">
      {reactions
        .filter((reaction) => keys.includes(reaction.value || ""))
        .map((reaction) => (
          <div
            className="flex items-center th-color-for py-[3px] pl-[3px] pr-[5px] rounded-full border th-border-selbg group relative"
            key={reaction.value}
          >
            <div
              className={classNames(
                reaction.bgColor,
                "w-5 h-5 rounded-full flex items-center justify-center"
              )}
            >
              <reaction.icon
                className={classNames(
                  reaction.iconColor,
                  "flex-shrink-0 h-3 w-3"
                )}
                aria-hidden="true"
              />
            </div>
            <div className="text-sm pl-1">
              {groupedReactions[(reaction.value || "") as any].length || 0}
            </div>
            <div className="bg-white shadow-lg rounded-lg p-2 hidden absolute group-hover:block origin-top-left bottom-0 left-0 -translate-y-8 w-44 z-50">
              {groupedReactions[(reaction.value || "") as any]
                .map((r: any) => r.userId)
                .map((userId: string) => (
                  <UserName key={userId} id={userId} />
                ))}
              reacted.
            </div>
          </div>
        ))}
    </div>
  );
}

export default function Message({
  message,
  previousSameSender,
  previousMessageDate,
  children,
  index,
  editMessage,
  setEditMessage,
}: {
  message: any;
  previousSameSender: boolean;
  previousMessageDate: any;
  children: React.ReactNode;
  index: number;
  editMessage: string;
  setEditMessage: React.Dispatch<React.SetStateAction<string>>;
}) {
  const messageReader = useMemo(
    () => <QuillReader text={message?.text} isEdited={message?.isEdited} />,
    [message]
  );

  const edit = editMessage === message?.objectId;

  const { themeColors } = useTheme();

  const { user } = useUser();

  const downloadRef = useRef<any>(null);

  const navigate = useNavigate();

  const location = useLocation();

  const { value } = useUserById(message?.senderId);

  const { channelId, dmId } = useParams();
  const chatId = channelId || dmId;

  const { reactions: messageReactions } = useReactions(
    chatId,
    message?.objectId
  );

  // group reactions by value
  const groupedReactions = useMemo(() => {
    let groups: any = {};
    messageReactions.forEach((reaction) => {
      groups[reaction.reaction] = [
        ...(groups[reaction.reaction] || []),
        reaction,
      ];
    });
    return groups;
  }, [messageReactions]);

  const myReaction = messageReactions.find(
    (reaction) => reaction.userId === user?.uid
  )?.reaction;

  const photoURL = getHref(value?.thumbnailURL) || getHref(value?.photoURL);

  const fileURL = getHref(message?.thumbnailURL) || getHref(message?.fileURL);

  const [loadingDelete, setLoadingDelete] = useState(false);

  const [imageLoaded, setImageLoaded] = useState(false);

  const sizes = useMemo(() => {
    const ratio = message?.mediaWidth / message?.mediaHeight;
    if (ratio < 1) {
      return {
        height: "384px",
        width: `${Math.round(
          (384 * message.mediaWidth) / message.mediaHeight
        )}px`,
      };
    }
    return {
      height: `${Math.round(
        (384 * message.mediaHeight) / message.mediaWidth
      )}px`,
      width: "384px",
    };
  }, [message?.mediaHeight, message?.mediaWidth]);

  const deleteMessage = async () => {
    setLoadingDelete(true);
    try {
      await deleteData(`/messages/${message?.objectId}`);
    } catch (err: any) {
      toast.error(err.message);
    }
    setLoadingDelete(false);
  };

  const prevCreatedAt = new Date(previousMessageDate);

  const createdAt = new Date(message?.createdAt);

  const displayProfilePicture = useMemo(
    () =>
      !previousSameSender ||
      (index + 1) % 30 === 0 ||
      (previousSameSender &&
        prevCreatedAt &&
        createdAt &&
        createdAt?.getTime() - prevCreatedAt?.getTime() > 600000),
    [previousSameSender, index, prevCreatedAt, createdAt]
  );

  const messageRender = useMemo(
    () => (
      <div className="flex flex-1 group">
        {displayProfilePicture && (
          <div className="flex flex-col items-start h-full pt-1 w-10">
            <div
              role="button"
              tabIndex={0}
              className="rounded h-10 w-10 bg-cover cursor-pointer focus:outline-none"
              style={{
                backgroundImage: `url(${
                  photoURL || `${process.env.PUBLIC_URL}/blank_user.png`
                })`,
              }}
              onClick={() =>
                navigate(
                  `${
                    location.pathname.split("/user_profile")[0]
                  }/user_profile/${value?.objectId}`
                )
              }
            />
          </div>
        )}

        {!displayProfilePicture && (
          <div className="flex flex-col items-start h-full pt-1 w-10 opacity-0 group-hover:opacity-100">
            <span className="font-light text-xs ml-2 align-bottom th-color-for">
              {new Date(message?.createdAt)
                ?.toLocaleTimeString()
                .replace(/:\d+ /, " ")
                .slice(0, -3)}
            </span>
          </div>
        )}

        <div className="flex flex-col flex-1 pl-3 w-full">
          {displayProfilePicture && (
            <div
              className={classNames(
                edit ? "th-color-black" : "th-color-for",
                "flex items-center"
              )}
            >
              <span
                role="button"
                tabIndex={0}
                className={classNames(
                  !value?.displayName ? "opacity-0" : "",
                  "font-extrabold text-base align-top hover:underline cursor-pointer focus:outline-none max-w-sm truncate"
                )}
                onClick={() =>
                  navigate(
                    `${
                      location.pathname.split("/user_profile")[0]
                    }/user_profile/${value?.objectId}`
                  )
                }
              >
                {value?.displayName || "undefined"}
              </span>
              <span className="font-light text-xs ml-2 align-bottom">
                {new Date(message?.createdAt)
                  ?.toLocaleTimeString()
                  .replace(/:\d+ /, " ")
                  .slice(0, -3)}
              </span>
            </div>
          )}

          {message?.text && !edit && messageReader}

          {message?.text && edit && (
            <EditMessage setEdit={setEditMessage} message={message} />
          )}

          {message.fileURL && !edit && (
            <>
              {message?.fileType?.includes("image/") && (
                <>
                  <div
                    className={classNames(
                      imageLoaded ? "block" : "hidden",
                      "relative my-1"
                    )}
                  >
                    <img
                      className="bg-cover max-w-sm max-h-sm rounded relative focus:outline-none cursor-pointer"
                      onLoad={() => setImageLoaded(true)}
                      alt={message?.fileName}
                      src={fileURL}
                      onClick={() => downloadRef?.current?.click()}
                    />
                  </div>
                  {!imageLoaded && (
                    <div
                      className="relative my-1 max-w-sm max-h-sm rounded bg-gray-100"
                      style={{
                        height: sizes?.height,
                        width: sizes?.width,
                      }}
                    />
                  )}
                </>
              )}

              {message?.fileType?.includes("video/") && (
                <div className="max-h-sm max-w-sm relative my-1">
                  <video
                    className="max-h-sm max-w-sm"
                    controls
                    disablePictureInPicture
                    controlsList="nodownload"
                    poster={getHref(message?.thumbnailURL)}
                  >
                    <source
                      src={getHref(message?.fileURL)}
                      type={message?.fileType}
                    />
                  </video>
                </div>
              )}

              {message?.fileType?.includes("audio/") && (
                <div className="relative my-1">
                  <audio controls controlsList="nodownload">
                    <source src={fileURL} type={message?.fileType} />
                  </audio>
                </div>
              )}

              {!message?.fileType?.includes("audio/") &&
                !message?.fileType?.includes("video/") &&
                !message?.fileType?.includes("image/") && (
                  <div className="relative my-1">
                    <div className="rounded h-16 w-80 relative group bg-gray-800 border border-gray-600 flex space-x-2 items-center p-1 overflow-hidden">
                      <DocumentTextIcon className="h-9 w-9 text-blue-500 flex-shrink-0" />
                      <div className="flex flex-col min-w-0">
                        <div className="text-gray-300 text-sm font-bold truncate">
                          {message?.fileName}
                        </div>
                        <div className="text-gray-400 text-sm truncate">
                          {bytesToSize(message?.fileSize)}
                        </div>
                      </div>
                    </div>
                  </div>
                )}
            </>
          )}

          {message?.sticker && (
            <img
              className="h-32 w-32 my-2 rounded-sm"
              alt={message?.sticker}
              src={`${process.env.PUBLIC_URL}/stickers/${message?.sticker}`}
            />
          )}
        </div>

        <div
          className={classNames(
            edit ? "opacity-0" : "opacity-0 group-hover:opacity-100",
            "absolute top-0 right-0 mx-5 transform -translate-y-3 z-20 inline-flex shadow-sm rounded-md -space-x-px"
          )}
        >
          <ReactionModal
            messageId={message?.objectId}
            myReaction={myReaction}
          />

          {message?.fileURL && (
            <button
              type="button"
              className="th-bg-bg th-border-selbg th-color-for relative inline-flex items-center px-3 py-1 border text-sm font-medium focus:z-10 focus:outline-none"
              onClick={() => downloadRef?.current?.click()}
            >
              <span className="sr-only">Download</span>
              <a
                ref={downloadRef}
                className="hidden"
                download
                target="_blank"
                rel="noreferrer"
                href={getHref(message?.fileURL)}
              >
                Download
              </a>
              <DownloadIcon className="h-4 w-4" />
            </button>
          )}

          {message?.text && message?.senderId === user?.uid && (
            <button
              type="button"
              className="th-bg-bg th-border-selbg th-color-for relative inline-flex items-center px-3 py-1 border text-sm font-medium focus:z-10 focus:outline-none"
              onClick={() => setEditMessage(message?.objectId)}
            >
              <span className="sr-only">Edit</span>
              <PencilIcon className="h-4 w-4" />
            </button>
          )}

          {message?.senderId === user?.uid && (
            <button
              type="button"
              className="th-bg-bg th-border-selbg th-color-for relative inline-flex items-center px-3 py-1 border text-sm font-medium focus:z-10 focus:outline-none"
              onClick={deleteMessage}
            >
              <span className="sr-only">Delete</span>
              {loadingDelete ? (
                <Spinner className="h-4 w-4 th-color-for" />
              ) : (
                <TrashIcon className="h-4 w-4" />
              )}
            </button>
          )}
        </div>
      </div>
    ),
    [
      photoURL,
      fileURL,
      message,
      value?.objectId,
      value?.displayName,
      edit,
      loadingDelete,
      imageLoaded,
      displayProfilePicture,
      myReaction,
    ]
  );

  return (
    <div className="w-full first:mb-4 last:mt-4">
      {children}

      <MessageDiv
        theme={themeColors}
        className={classNames(
          edit ? "py-2" : "py-1",
          "px-5 w-full flex items-start relative"
        )}
        style={{
          backgroundColor: edit ? hexToRgbA(themeColors?.yellow, "0.7")! : "",
        }}
      >
        <div className="flex flex-col flex-1">
          {messageRender}
          {!edit && <Reactions groupedReactions={groupedReactions} />}
        </div>
      </MessageDiv>
    </div>
  );
}
