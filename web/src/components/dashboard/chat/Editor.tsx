import QuillEditor from "components/dashboard/quill/QuillEditor";
import { MESSAGE_MAX_CHARACTERS } from "config";
import { useUser } from "contexts/UserContext";
import { Formik } from "formik";
import { uploadFile } from "gqlite-lib/dist/client/storage";
import { useChannelById } from "hooks/useChannels";
import { useDirectMessageById } from "hooks/useDirects";
import { useUserById } from "hooks/useUsers";
import { useEffect, useRef, useState } from "react";
import { useDropzone } from "react-dropzone";
import toast from "react-hot-toast";
import { useParams } from "react-router-dom";
import { postData } from "utils/api-helpers";
import classNames from "utils/classNames";
import now from "utils/now";
import { v4 as uuidv4 } from "uuid";

function TypingUser({ userId }: { userId: string }) {
  const { value } = useUserById(userId);

  if (!value) return null;

  return (
    <div className="mr-2 th-color-for">
      {value?.displayName} <span className="th-color-for">is typing...</span>
    </div>
  );
}

function KeyboardInfos({ hasText }: { hasText: boolean }) {
  return (
    <div
      className={classNames(
        !hasText ? "opacity-0" : "opacity-100",
        "flex font-normal text-xs space-x-3"
      )}
    >
      <div>
        <span className="font-bold">Shift + Return</span> to send
      </div>
      <div>
        <span className="font-bold">Return</span> to add a new line
      </div>
    </div>
  );
}

export default function Editor() {
  const dropzone = useDropzone({
    // Disable click and keydown behavior
    noClick: true,
    noKeyboard: true,
    maxFiles: 1,
    onDrop: (acceptedFiles) => {
      setFiles(acceptedFiles);
    },
  });

  const { workspaceId, channelId, dmId } = useParams();

  const editorRef = useRef<any>(null);
  const editor = editorRef?.current?.getEditor();

  const [files, setFiles] = useState<File[]>([]);

  const [hasText, setHasText] = useState(false);
  const [isTyping, setIsTyping] = useState(false);

  useEffect(() => {
    const type = dmId ? "directs" : "channels";
    const id = dmId || channelId;
    setFiles([]);

    postData(
      `/${type}/${id}/typing_indicator`,
      {
        isTyping: false,
      },
      {},
      false
    );

    postData(`/${type}/${id}/reset_typing`, {}, {}, false);
    const interval = setInterval(() => {
      postData(`/${type}/${id}/reset_typing`, {}, {}, false);
    }, 30000);

    return () => {
      clearInterval(interval);
      postData(
        `/${type}/${id}/typing_indicator`,
        {
          isTyping: false,
        },
        {},
        false
      );
      postData(`/${type}/${id}/reset_typing`, {}, {}, false);
    };
  }, [channelId, dmId]);

  const { value: channel } = useChannelById(channelId);
  const { value: dm } = useDirectMessageById(dmId);

  const { user } = useUser();
  const otherUserId = dm?.members.find((m: string) => m !== user?.uid);
  const { value: userData } = useUserById(otherUserId || user?.uid);

  if (channelId && !channel) return null;
  if (dmId && !dm) return null;

  const typingArray = channel
    ? channel.typing.filter((typ: any) => typ !== user?.uid)
    : dm.typing.filter((typ: any) => typ !== user?.uid);

  const validate = () => {
    const errors: any = {};

    const realText = editor?.getText() as string | null | undefined;

    if (realText && realText.trim().length > MESSAGE_MAX_CHARACTERS)
      errors.text = `Message is too long. Max ${MESSAGE_MAX_CHARACTERS} characters.`;

    return errors;
  };

  return (
    <div className="w-full px-5 pb-2 flex-shrink-0">
      <div
        className={classNames(
          dropzone.isDragActive ? "th-border-blue" : "th-border-selbg",
          "w-full border rounded flex items-center th-bg-bg"
        )}
      >
        <Formik
          initialValues={{
            text: "",
          }}
          validate={validate}
          enableReinitialize
          onSubmit={async ({ text }, { setSubmitting, resetForm }) => {
            setSubmitting(true);
            try {
              const messageId = uuidv4();
              const realText = editor?.getText() as string | null | undefined;
              if (!realText?.trim() && !files?.length) return;

              let filePath: string | undefined;
              if (files?.length) {
                filePath = await uploadFile(
                  "messenger",
                  `Message/${messageId}/${now()}_file`,
                  files[0]
                );
              }

              await postData("/messages", {
                objectId: messageId,
                text: realText?.trim().length ? text : "",
                chatId: channelId || dmId,
                workspaceId,
                ...(files?.length && {
                  fileName: files[0]?.name,
                  filePath,
                }),
                chatType: channelId ? "Channel" : "Direct",
              });
              const el = document.getElementById("messages")!;
              el.scrollTo(el.scrollHeight, 0);
              resetForm();
              setIsTyping(false);
              setFiles([]);
            } catch (err: any) {
              toast.error(err.message);
            }
            setSubmitting(false);
          }}
        >
          {({ values, setFieldValue, handleSubmit, errors, isSubmitting }) => (
            <form
              noValidate
              onSubmit={handleSubmit}
              className="w-full h-full flex items-center"
            >
              <QuillEditor
                files={files}
                setFiles={setFiles}
                editorRef={editorRef}
                editor={editor}
                text={values.text}
                setFieldValue={setFieldValue}
                placeholder={
                  channelId
                    ? `Send a message to ${`#${channel?.name}`}`
                    : `Send a message to ${userData?.displayName}`
                }
                errors={errors}
                isSubmitting={isSubmitting}
                handleSubmit={handleSubmit}
                setHasText={setHasText}
                dropzone={dropzone}
                isTyping={isTyping}
                setIsTyping={setIsTyping}
              />
            </form>
          )}
        </Formik>
      </div>
      <div
        className={classNames(
          "text-xs font-semibold mt-2 th-color-for flex items-center justify-between"
        )}
      >
        <div
          className={classNames(
            typingArray?.length > 0 ? "opacity-100" : "opacity-0"
          )}
        >
          {typingArray?.map((typing: string) => (
            <TypingUser userId={typing} key={typing} />
          ))}
        </div>
        <KeyboardInfos hasText={hasText} />
      </div>
    </div>
  );
}
