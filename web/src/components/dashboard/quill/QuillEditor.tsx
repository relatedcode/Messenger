import { Popover } from "@headlessui/react";
import {
  DocumentTextIcon,
  EmojiHappyIcon,
  PhotographIcon,
  PlayIcon,
  XIcon,
} from "@heroicons/react/outline";
import { PaperAirplaneIcon } from "@heroicons/react/solid";
import Spinner from "components/Spinner";
import Style from "components/Style";
import { MESSAGE_MAX_CHARACTERS, STICKERS_COUNT } from "config";
import { useTheme } from "contexts/ThemeContext";
import { Picker } from "emoji-mart";
import "emoji-mart/css/emoji-mart.css";
import { ReactComponent as AttachFileIcon } from "icons/attach_file.svg";
import debounce from "lodash/debounce";
import React, { useCallback, useEffect, useMemo, useState } from "react";
import { DropzoneState } from "react-dropzone";
import toast from "react-hot-toast";
import ReactQuill from "react-quill";
import "react-quill/dist/quill.snow.css";
import { useParams } from "react-router-dom";
import { postData } from "utils/api-helpers";
import classNames from "utils/classNames";
import hexToRgbA from "utils/hexToRgbA";

function EmojiDropdown({
  onEmojiClick,
  editor,
}: {
  onEmojiClick: any;
  editor: any;
}) {
  const { themeColors } = useTheme();
  return (
    <>
      <Style
        css={`
          .emoji-mart {
            background-color: ${themeColors?.background};
            border-color: ${themeColors?.selectionBackground};
          }
          .emoji-mart-bar {
            border-color: ${themeColors?.selectionBackground};
          }
          .emoji-mart-category-label span {
            background-color: ${themeColors?.background};
            color: ${themeColors?.foreground};
          }
          .emoji-mart-search input {
            background-color: ${themeColors?.background};
            border-color: ${themeColors?.selectionBackground};
          }
          .emoji-mart-search-icon svg {
            fill: ${themeColors?.foreground};
          }
          .emoji-mart-skin-swatches {
            background-color: ${themeColors?.background};
            border-color: ${themeColors?.selectionBackground};
          }
        `}
      />
      <Popover as="div" className="z-10 relative">
        {({ open }) => (
          <>
            <Popover.Button
              as="button"
              className="flex items-center focus:outline-none"
              onClick={() => editor?.blur()}
            >
              <EmojiHappyIcon
                style={{ color: themeColors?.foreground }}
                className="h-5 w-5"
              />
            </Popover.Button>

            {open && (
              <div>
                <Popover.Panel
                  static
                  className="origin-top-left absolute bottom-0 right-0"
                >
                  <Picker
                    onClick={onEmojiClick}
                    title="Emojis"
                    showPreview={false}
                    native
                    set="apple"
                  />
                </Popover.Panel>
              </div>
            )}
          </>
        )}
      </Popover>
    </>
  );
}

function StickersDropdown() {
  const stickers = useMemo(() => {
    return Array.from(
      Array(STICKERS_COUNT),
      (_, index) => `sticker${index + 1 < 10 ? `0${index + 1}` : index + 1}.png`
    );
  }, []);

  const { workspaceId, channelId, dmId } = useParams();

  const [loading, setLoading] = useState("");

  const sendSticker = async (sticker: string) => {
    setLoading(sticker);
    try {
      await postData("/messages", {
        chatId: channelId || dmId,
        workspaceId,
        chatType: channelId ? "Channel" : "Direct",
        sticker,
      });
    } catch (err: any) {
      toast.error(err.message);
    }
    setLoading("");
  };

  return (
    <Popover as="div" className="z-10 relative">
      {({ open }) => (
        <>
          <Popover.Button
            as="button"
            className="flex items-center focus:outline-none"
          >
            <PhotographIcon className="h-5 w-5 th-color-for" />
          </Popover.Button>

          {open && (
            <div>
              <Popover.Panel
                static
                className="th-bg-bg th-border-selbg origin-top-left max-h-96 overflow-y-scroll w-72 absolute bottom-0 right-0 shadow border rounded py-2 px-2 grid grid-cols-3 gap-1"
              >
                {stickers.map((sticker) => (
                  <div
                    role="button"
                    tabIndex={0}
                    key={sticker}
                    className="flex items-center justify-center focus:outline-none relative"
                    onClick={() => sendSticker(sticker)}
                  >
                    <img
                      alt={sticker}
                      className={classNames(
                        "h-full w-full rounded-sm cursor-pointer"
                      )}
                      src={`${process.env.PUBLIC_URL}/stickers/${sticker}`}
                    />
                    {loading === sticker && (
                      <div className="w-full h-full z-20 opacity-50 bg-white absolute inset-0 flex items-center justify-center">
                        <Spinner className="text-gray-700" />
                      </div>
                    )}
                  </div>
                ))}
              </Popover.Panel>
            </div>
          )}
        </>
      )}
    </Popover>
  );
}

function CustomToolbar({
  isSubmitting,
  errors,
  isFiles,
  editor,
  setHasText,
  openDropzone,
}: {
  isSubmitting: boolean;
  errors: any;
  isFiles: boolean;
  editor: any;
  setHasText: any;
  openDropzone: any;
}) {
  const { themeColors } = useTheme();
  const realText = editor?.getText() as string | null | undefined;
  const isText = realText?.trim();

  useEffect(() => {
    if (isText) {
      setHasText(true);
    } else {
      setHasText(false);
    }
  }, [isText]);

  const sendDisabled = isSubmitting || (!isFiles && !isText);

  const onEmojiClick = (emojiObject: any) => {
    const range = editor?.getLength() - 1;
    editor?.insertText(range, emojiObject.native);
  };

  return (
    <div id="toolbar" className="flex items-center justify-between w-full">
      <div className="flex items-center">
        <button className="ql-bold" />
        <button className="ql-italic" />
        <button className="ql-strike" />
        <button className="ql-blockquote" />
        <button className="ql-code" />
        <button className="ql-list" value="ordered" />
        <button className="ql-list" value="bullet" />
        <button className="ql-code-block" />
        <button className="ql-link" />
      </div>
      <div className="ml-auto flex items-center space-x-2">
        <StickersDropdown />
        <EmojiDropdown onEmojiClick={onEmojiClick} editor={editor} />
        <AttachFileIcon
          className="h-5 w-5 cursor-pointer th-color-for"
          onClick={() => {
            openDropzone();
          }}
        />
        <button
          id="sendButton"
          type="submit"
          disabled={sendDisabled}
          className={classNames(isSubmitting ? "opacity-50" : "")}
          style={{
            backgroundColor:
              // eslint-disable-next-line
              errors.text && isText
                ? themeColors?.red
                : isText || isFiles
                ? themeColors?.blue
                : "transparent",
          }}
        >
          {!isSubmitting && (
            <>
              {errors.text && isText ? (
                <span className="th-color-brwhite">
                  {MESSAGE_MAX_CHARACTERS - isText.length}
                </span>
              ) : (
                <PaperAirplaneIcon
                  className={classNames(
                    isText ? "th-color-brwhite" : "th-color-for",
                    "transform rotate-90 h-5 w-5"
                  )}
                />
              )}
            </>
          )}
          {isSubmitting && (
            <svg
              className="animate-spin h-5 w-5 th-color-for"
              xmlns="http://www.w3.org/2000/svg"
              fill="none"
              viewBox="0 0 24 24"
            >
              <circle
                className="opacity-25"
                cx="12"
                cy="12"
                r="10"
                stroke="currentColor"
                strokeWidth="4"
              />
              <path
                className="opacity-75"
                fill="currentColor"
                d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"
              />
            </svg>
          )}
        </button>
      </div>
    </div>
  );
}

function FileThumbnail({
  file,
  children,
}: {
  file: File;
  children: React.ReactNode;
}) {
  if (file.type.includes("image/"))
    return (
      <div
        key={file.lastModified}
        className="bg-cover rounded h-20 w-20 relative group"
        style={{ backgroundImage: `url(${URL.createObjectURL(file)})` }}
      >
        {children}
      </div>
    );
  if (file?.type?.includes("video/") || file?.type?.includes("audio/"))
    return (
      <div
        key={file.lastModified}
        className="rounded h-20 w-44 relative group bg-gray-800 border border-gray-600 flex space-x-2 items-center p-1"
      >
        <PlayIcon className="h-9 w-9 text-blue-500 flex-shrink-0" />
        <div className="text-gray-300 font-bold text-sm truncate">
          {file.name}
        </div>
        {children}
      </div>
    );
  return (
    <div
      key={file.lastModified}
      className="rounded h-20 w-44 relative group bg-gray-800 border border-gray-600 flex space-x-2 items-center p-1"
    >
      <DocumentTextIcon className="h-9 w-9 text-blue-500 flex-shrink-0" />
      <div className="text-gray-300 text-sm font-bold truncate">
        {file.name}
      </div>
      {children}
    </div>
  );
}

function FileViewer({
  setFiles,
  files,
}: {
  files: File[];
  setFiles: React.Dispatch<React.SetStateAction<File[]>>;
}) {
  const filesViewer = useMemo(
    () => (
      <div
        className={classNames(
          files?.length ? "" : "hidden",
          "w-full h-24 px-3 flex py-2"
        )}
      >
        {files?.length &&
          Array.from(files).map((file) => (
            <FileThumbnail file={file} key={file.lastModified}>
              <div className="absolute top-0 right-0 bg-gray-700 p-1 rounded-full transform translate-x-1 -translate-y-1 opacity-0 group-hover:opacity-100">
                <XIcon
                  className="text-white h-3 w-3 cursor-pointer"
                  onClick={() => {
                    setFiles([]);
                  }}
                />
              </div>
            </FileThumbnail>
          ))}
      </div>
    ),
    [files]
  );
  return filesViewer;
}

const handleTyping = debounce((setIsTyping) => {
  setIsTyping(false);
}, 3000);

interface EditorProps {
  placeholder: string;
  setFieldValue: any;
  text: string;
  handleSubmit: any;
  isSubmitting: boolean;
  errors: any;
  editorRef: any;
  files: File[];
  setFiles: React.Dispatch<React.SetStateAction<File[]>>;
  editor: any;
  setHasText: React.Dispatch<React.SetStateAction<boolean>>;
  dropzone: DropzoneState;
  isTyping: any;
  setIsTyping: any;
}

function Editor({
  placeholder,
  setFieldValue,
  text,
  handleSubmit,
  isSubmitting,
  errors,
  editorRef,
  files,
  setFiles,
  editor,
  setHasText,
  dropzone,
  isTyping,
  setIsTyping,
}: EditorProps) {
  const {
    getRootProps,
    getInputProps,
    isDragActive,
    open: openDropzone,
  } = dropzone;
  const { themeColors } = useTheme();

  const { channelId, dmId } = useParams();

  const modules = useMemo(
    () => ({
      toolbar: {
        container: "#toolbar",
      },
      clipboard: {
        matchVisual: false,
      },
      keyboard: {
        bindings: {
          tab: false,
          custom: {
            key: 13,
            shiftKey: true,
            handler: () => {
              handleSubmit();
            },
          },
        },
      },
    }),
    []
  );

  useEffect(() => {
    setFieldValue("text", "");
    document
      .querySelector("#chat-editor > div > div.ql-editor.ql-blank")
      ?.setAttribute("data-placeholder", placeholder);
  }, [placeholder]);

  const debounceRequest = useCallback(() => {
    handleTyping(setIsTyping);
  }, []);

  useEffect(() => {
    const type = dmId ? "directs" : "channels";
    const id = dmId || channelId;
    if (isTyping) {
      postData(
        `/${type}/${id}/typing_indicator`,
        {
          isTyping: true,
        },
        {},
        false
      );
    }
  }, [isTyping]);

  useEffect(() => {
    let interval: any;
    const type = dmId ? "directs" : "channels";
    const id = dmId || channelId;

    if (isTyping && !isSubmitting) {
      interval = setInterval(() => {
        postData(
          `/${type}/${id}/typing_indicator`,
          {
            isTyping: true,
          },
          {},
          false
        );
      }, 3000);
    } else {
      clearInterval(interval);
      postData(
        `/${type}/${id}/typing_indicator`,
        {
          isTyping: false,
        },
        {},
        false
      );
    }
    return () => clearInterval(interval);
  }, [isTyping]);

  return (
    <div className="flex flex-col w-full">
      <div {...getRootProps()}>
        <input {...getInputProps()} />
        <Style
          css={`
            .editor .ql-editor {
              color: ${themeColors?.foreground};
              background-color: ${themeColors?.background};
              font-weight: ${themeColors?.messageFontWeight === "light"
                ? "300"
                : "400"};
            }
            .editor .ql-editor {
              border-top-left-radius: 3px;
              border-top-right-radius: 3px;
            }
            .quill > .ql-container > .ql-editor.ql-blank::before {
              color: ${themeColors?.foreground};
              font-style: normal;
              opacity: 0.7;
            }
            .ql-snow.ql-toolbar {
              background-color: ${themeColors?.background};
              border-color: ${isDragActive
                ? themeColors?.blue
                : themeColors?.selectionBackground};
              border-bottom-left-radius: 3px;
              border-bottom-right-radius: 3px;
            }

            /* Code editor */
            .ql-snow .ql-editor pre.ql-syntax {
              background-color: ${themeColors?.brightBlack};
              color: ${themeColors?.brightWhite};
              border-color: ${hexToRgbA(themeColors?.background!, "0.2")};
              border-width: 1px;
            }
            .ql-snow .ql-editor code,
            .ql-snow .ql-editor pre {
              background-color: ${themeColors?.brightBlack};
              color: ${themeColors?.brightWhite};
              border-color: ${hexToRgbA(themeColors?.background!, "0.2")};
              border-width: 1px;
            }

            /* Toolbar icons */
            .ql-snow .ql-stroke {
              stroke: ${themeColors?.foreground};
            }
            .ql-snow .ql-fill,
            .ql-snow .ql-stroke.ql-fill {
              fill: ${themeColors?.foreground};
            }

            /* Link */
            .ql-snow .ql-editor a {
              color: ${themeColors?.blue};
              text-decoration: none;
            }
            .ql-snow .ql-editor a:hover {
              text-decoration: underline;
            }
          `}
        />
        <ReactQuill
          onChange={(e) => {
            setFieldValue("text", e);
            setIsTyping(true);
            debounceRequest();
          }}
          value={text}
          className="editor"
          placeholder={placeholder}
          modules={modules}
          formats={[
            "bold",
            "italic",
            "strike",
            "list",
            "code",
            "link",
            "blockquote",
            "code-block",
          ]}
          theme="snow"
          id="chat-editor"
          ref={editorRef}
        />
        <FileViewer files={files} setFiles={setFiles} />
        <CustomToolbar
          isSubmitting={isSubmitting}
          errors={errors}
          isFiles={!!files?.length}
          editor={editor}
          setHasText={setHasText}
          openDropzone={openDropzone}
        />
      </div>
    </div>
  );
}

export default Editor;
