import { Dialog, Disclosure, Transition } from "@headlessui/react";
import {
  DotsHorizontalIcon,
  HashtagIcon,
  PlusIcon,
  XIcon,
} from "@heroicons/react/outline";
import ModalButton from "components/dashboard/ModalButton";
import TextField from "components/TextField";
import { useModal } from "contexts/ModalContext";
import { useTheme } from "contexts/ThemeContext";
import { useUser } from "contexts/UserContext";
import { Formik } from "formik";
import { useChannelById, useChannels } from "hooks/useChannels";
import { useDetailByChat } from "hooks/useDetails";
import { ReactComponent as ArrowIcon } from "icons/arrow.svg";
import { Fragment, useRef } from "react";
import toast from "react-hot-toast";
import { useNavigate, useParams } from "react-router-dom";
import { postData } from "utils/api-helpers";
import classNames from "utils/classNames";
import * as Yup from "yup";

function CreateChannel() {
  const { themeColors } = useTheme();
  const cancelButtonRef = useRef(null);
  const { openCreateChannel: open, setOpenCreateChannel: setOpen } = useModal();
  const { workspaceId } = useParams();
  const navigate = useNavigate();

  return (
    <Transition.Root show={open} as={Fragment}>
      <Dialog
        as="div"
        static
        className="fixed z-10 inset-0 overflow-y-auto"
        initialFocus={cancelButtonRef}
        open={open}
        onClose={setOpen}
      >
        <div className="flex items-end justify-center min-h-screen pt-4 px-4 pb-20 text-center sm:block sm:p-0">
          <Transition.Child
            as={Fragment}
            enter="ease-out duration-300"
            enterFrom="opacity-0"
            enterTo="opacity-100"
            leave="ease-in duration-200"
            leaveFrom="opacity-100"
            leaveTo="opacity-0"
          >
            <Dialog.Overlay className="fixed inset-0 bg-gray-900 bg-opacity-50 transition-opacity" />
          </Transition.Child>

          {/* This element is to trick the browser into centering the modal contents. */}
          <span
            className="hidden sm:inline-block sm:align-middle sm:h-screen"
            aria-hidden="true"
          >
            &#8203;
          </span>
          <Transition.Child
            as={Fragment}
            enter="ease-out duration-300"
            enterFrom="opacity-0 translate-y-4 sm:translate-y-0 sm:scale-95"
            enterTo="opacity-100 translate-y-0 sm:scale-100"
            leave="ease-in duration-200"
            leaveFrom="opacity-100 translate-y-0 sm:scale-100"
            leaveTo="opacity-0 translate-y-4 sm:translate-y-0 sm:scale-95"
          >
            <div
              style={{ backgroundColor: themeColors?.background }}
              className="inline-block align-bottom rounded-lg text-left overflow-hidden shadow-xl transform transition-all sm:my-8 sm:align-middle sm:max-w-lg sm:w-full"
            >
              <div
                style={{ backgroundColor: themeColors?.background }}
                className="px-4 pt-5 pb-4 sm:p-6 sm:pb-4 flex justify-between items-center"
              >
                <h5
                  style={{ color: themeColors?.foreground }}
                  className="font-bold text-2xl"
                >
                  Create a channel
                </h5>
                <div
                  role="button"
                  tabIndex={0}
                  className="cursor-pointer focus:outline-none"
                  onClick={() => setOpen(false)}
                >
                  <XIcon
                    style={{ color: themeColors?.foreground }}
                    className="h-5 w-5"
                  />
                </div>
              </div>
              <Formik
                initialValues={{
                  name: "",
                  details: "",
                }}
                validationSchema={Yup.object({
                  name: Yup.string().max(100).required(),
                  details: Yup.string().max(1000).notRequired(),
                })}
                enableReinitialize
                onSubmit={async ({ name, details }, { setSubmitting }) => {
                  setSubmitting(true);
                  try {
                    const { channelId } = await postData("/channels", {
                      name,
                      details,
                      workspaceId,
                    });
                    navigate(
                      `/dashboard/workspaces/${workspaceId}/channels/${channelId}`
                    );
                    toast.success("Channel created.");
                    setOpen(false);
                  } catch (err: any) {
                    toast.error(err.message);
                  }
                  setSubmitting(false);
                }}
              >
                {({
                  values,
                  handleChange,
                  isSubmitting,
                  handleSubmit,
                  setFieldValue,
                }) => (
                  <form noValidate onSubmit={handleSubmit}>
                    <div
                      style={{ backgroundColor: themeColors?.background }}
                      className="p-6 pt-0 pb-6"
                    >
                      <span
                        style={{ color: themeColors?.foreground }}
                        className="font-base text-sm"
                      >
                        Channels are where your team communicates. They’re best
                        when organized around a topic — #marketing, for example.
                      </span>
                      <div className="space-y-6 pt-5">
                        <TextField
                          label="Name"
                          name="name"
                          required
                          focus
                          value={values.name}
                          handleChange={(e: any) =>
                            setFieldValue(
                              "name",
                              e.target.value
                                .toLowerCase()
                                .replace(/[^a-z0-9_\- ]/g, "")
                                .replace("#", "")
                            )
                          }
                          placeholder="e.g. plan-budget"
                        />
                        <TextField
                          label="Description"
                          name="details"
                          required
                          value={values.details}
                          handleChange={handleChange}
                          placeholder=""
                          infos="What's this channel about?"
                        />
                      </div>
                    </div>
                    <div className="px-4 pb-5 pt-1 sm:px-6 sm:flex sm:flex-row-reverse">
                      <ModalButton text="Create" isSubmitting={isSubmitting} />
                    </div>
                  </form>
                )}
              </Formik>
            </div>
          </Transition.Child>
        </div>
      </Dialog>
    </Transition.Root>
  );
}

function Channel({ name, objectId }: { name: string; objectId: string }) {
  const { themeColors } = useTheme();
  const navigate = useNavigate();
  const { workspaceId, channelId } = useParams();
  const { value: channel } = useChannelById(objectId);
  const { value: detail } = useDetailByChat(objectId);
  const { user } = useUser();
  const notifications = channel
    ? channel.lastMessageCounter - (detail?.lastRead || 0)
    : 0;

  const selected = channelId === objectId;

  const typingArray = channel?.typing?.filter((typ: any) => typ !== user?.uid);

  return (
    <div
      role="button"
      tabIndex={0}
      className="flex items-center justify-between pl-8 pr-3 py-1 cursor-pointer focus:outline-none"
      onClick={() =>
        navigate(`/dashboard/workspaces/${workspaceId}/channels/${objectId}`)
      }
      style={{
        backgroundColor: selected ? themeColors?.blue : "transparent",
      }}
    >
      <div className="flex items-center">
        <HashtagIcon
          className={classNames(
            "h-4 w-4 mr-3",
            selected ? "th-color-brwhite" : "th-color-for"
          )}
        />
        <h5
          className={classNames(
            notifications ? "font-semibold" : "",
            "truncate w-36"
          )}
          style={{
            color: selected
              ? themeColors?.brightWhite
              : themeColors?.foreground,
          }}
        >
          {name.replace("#", "")}
        </h5>
      </div>
      {notifications > 0 && !typingArray?.length && (
        <div
          style={{ paddingTop: "2px", paddingBottom: "2px" }}
          className="rounded flex items-center justify-center px-2 th-color-brwhite th-bg-red font-semibold text-xs"
        >
          {notifications}
        </div>
      )}
      {notifications > 0 && typingArray?.length > 0 && (
        <div
          style={{ paddingTop: "2px", paddingBottom: "2px" }}
          className="rounded flex items-center justify-center px-1 th-color-brwhite th-bg-red font-semibold text-xs"
        >
          <DotsHorizontalIcon className="h-4 w-4 animate-bounce" />
        </div>
      )}
      {typingArray?.length > 0 && !notifications && (
        <div
          style={{ paddingTop: "2px", paddingBottom: "2px" }}
          className="rounded flex items-center justify-center px-2 th-color-brwhite font-semibold text-xs"
        >
          <DotsHorizontalIcon className="h-4 w-4 animate-bounce" />
        </div>
      )}
    </div>
  );
}

function AddChannels() {
  const { setOpenCreateMessage: setOpen, setCreateMessageSection: setSection } =
    useModal();
  return (
    <div
      role="button"
      tabIndex={0}
      className="flex items-center px-8 cursor-pointer focus:outline-none pt-2"
      onClick={() => {
        setOpen(true);
        setSection("channels");
      }}
    >
      <div className="flex items-center justify-center rounded p-1 mr-2 th-bg-blue">
        <PlusIcon className="h-3 w-3 th-color-brwhite" />
      </div>
      <h5 className="th-color-for">Add channels</h5>
    </div>
  );
}

export default function Channels() {
  const { themeColors } = useTheme();
  const { value } = useChannels();

  return (
    <div>
      <Disclosure defaultOpen>
        {({ open }) => (
          <>
            <Disclosure.Button className="flex justify-between items-center px-4 cursor-pointer">
              <div className="flex items-center">
                <ArrowIcon
                  className={`h-4 w-4 mr-2 ${
                    open ? "transform rotate-90" : ""
                  }`}
                  style={{
                    color: themeColors?.foreground,
                  }}
                />
                <h5
                  style={{
                    color: themeColors?.foreground,
                  }}
                >
                  Channels
                </h5>
              </div>
            </Disclosure.Button>
            <Disclosure.Panel
              style={{ color: themeColors?.foreground }}
              className="pt-3 pb-2 text-sm space-y-1"
            >
              {value?.map((doc: any) => (
                <Channel
                  key={doc.objectId}
                  objectId={doc.objectId}
                  name={doc.name}
                />
              ))}
              <AddChannels />
            </Disclosure.Panel>
          </>
        )}
      </Disclosure>
      <CreateChannel />
    </div>
  );
}
