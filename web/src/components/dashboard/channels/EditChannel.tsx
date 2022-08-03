import { Dialog, RadioGroup, Transition } from "@headlessui/react";
import { ArchiveIcon, TrashIcon, XIcon } from "@heroicons/react/outline";
import ConfirmationModal from "components/ConfirmationModal";
import EditChannelItems from "components/dashboard/channels/EditChannelItems";
import MembersSection from "components/dashboard/channels/MembersSection";
import { useTheme } from "contexts/ThemeContext";
import { useUser } from "contexts/UserContext";
import { useWorkspaceById } from "hooks/useWorkspaces";
import React, { Fragment, useEffect, useRef, useState } from "react";
import toast from "react-hot-toast";
import { useNavigate, useParams } from "react-router-dom";
import { deleteData, postData } from "utils/api-helpers";
import classNames from "utils/classNames";

export default function EditChannel({
  open,
  setOpen,
  name,
  topic,
  details,
  createdAt,
}: {
  open: boolean;
  setOpen: React.Dispatch<React.SetStateAction<boolean>>;
  name: string;
  topic: string;
  details: string;
  createdAt: any;
}) {
  const { themeColors } = useTheme();
  const cancelButtonRef = useRef(null);
  const [section, setSection] = useState("about");
  const { channelId, workspaceId } = useParams();
  const { value } = useWorkspaceById(workspaceId);
  const { user } = useUser();
  const navigate = useNavigate();

  const defaultChannel = value?.channelId === channelId;

  useEffect(() => {
    setSection("about");
  }, [open]);

  const [openDeleteChannel, setOpenDeleteChannel] = useState(false);
  const [openArchiveChannel, setOpenArchiveChannel] = useState(false);
  const [openLeaveChannel, setOpenLeaveChannel] = useState(false);

  const deleteChannel = async () => {
    try {
      await deleteData(`/channels/${channelId}`);
      setOpenDeleteChannel(false);
      setOpen(false);
      navigate(`/dashboard/workspaces/${workspaceId}`);
    } catch (err: any) {
      toast.error(err.message);
    }
  };

  const archiveChannel = async () => {
    try {
      await postData(`/channels/${channelId}/archive`);
      setOpenArchiveChannel(false);
      setOpen(false);
      navigate(`/dashboard/workspaces/${workspaceId}`);
    } catch (err: any) {
      toast.error(err.message);
    }
  };

  const leaveChannel = async () => {
    try {
      await deleteData(`/channels/${channelId}/members/${user?.uid}`);
      setOpenLeaveChannel(false);
      setOpen(false);
      navigate(`/dashboard/workspaces/${workspaceId}`);
    } catch (err: any) {
      toast.error(err.message);
    }
  };

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
              className="inline-block align-bottom rounded-lg text-left overflow-hidden shadow-xl transform transition-all sm:my-8 sm:align-middle sm:max-w-xl sm:w-full"
            >
              <div
                style={{ backgroundColor: themeColors?.background }}
                className="pl-8 p-6 pb-4 flex justify-between items-center"
              >
                <h5
                  style={{ color: themeColors?.foreground }}
                  className="font-bold text-2xl max-w-full truncate"
                >
                  {`#${name}`}
                  {defaultChannel ? (
                    <span
                      style={{ color: themeColors?.foreground }}
                      className="text-base opacity-70 px-2"
                    >
                      (default)
                    </span>
                  ) : null}
                </h5>
                <div
                  role="button"
                  tabIndex={0}
                  className="cursor-pointer focus:outline-none"
                  onClick={() => setOpen(false)}
                >
                  <XIcon
                    className="h-5 w-5"
                    style={{ color: themeColors?.foreground }}
                  />
                </div>
              </div>
              <div className="pt-10" style={{ color: themeColors?.background }}>
                <RadioGroup
                  as="div"
                  value={section}
                  onChange={setSection}
                  className="flex space-x-6 px-8 text-sm font-normal"
                  style={{ color: themeColors?.foreground }}
                >
                  <RadioGroup.Option
                    value="about"
                    className="focus:outline-none"
                  >
                    {({ checked }) => (
                      <div
                        className={classNames(
                          checked ? "border-b-2" : "",
                          "pb-2 cursor-pointer"
                        )}
                        style={{
                          borderColor: checked ? themeColors?.brightBlue : "",
                        }}
                      >
                        <span>About</span>
                      </div>
                    )}
                  </RadioGroup.Option>
                  <RadioGroup.Option
                    value="members"
                    className="focus:outline-none"
                  >
                    {({ checked }) => (
                      <div
                        className={classNames(
                          checked ? "border-b-2" : "",
                          "pb-2 cursor-pointer"
                        )}
                        style={{
                          borderColor: checked ? themeColors?.brightBlue : "",
                        }}
                      >
                        <span>Members</span>
                      </div>
                    )}
                  </RadioGroup.Option>
                  <RadioGroup.Option
                    value="settings"
                    className="focus:outline-none"
                  >
                    {({ checked }) => (
                      <div
                        className={classNames(
                          checked ? "border-b-2" : "",
                          "pb-2 cursor-pointer"
                        )}
                        style={{
                          borderColor: checked ? themeColors?.brightBlue : "",
                        }}
                      >
                        <span>Settings</span>
                      </div>
                    )}
                  </RadioGroup.Option>
                </RadioGroup>
                <div
                  className={classNames(
                    section === "members" ? "" : "px-8",
                    "space-y-6 pt-5 pb-8 border-t h-550 th-bg-bg th-border-selbg"
                  )}
                >
                  {section === "about" && (
                    <>
                      <div className="border rounded-xl th-bg-bg th-border-selbg">
                        <EditChannelItems
                          name="Topic"
                          field="topic"
                          value={topic}
                          editable="Let people know what this channel is focused on right now (ex. a project milestone). Topics are always visible in the header."
                        />
                        <EditChannelItems
                          name="Description"
                          field="details"
                          value={details}
                          editable="Let people know what this channel is for."
                        />
                        <EditChannelItems name="Created at" value={createdAt} />
                        {!defaultChannel && (
                          <EditChannelItems
                            name="Leave channel"
                            color={themeColors?.red}
                            displayDetails={false}
                            onClick={() => setOpenLeaveChannel(true)}
                          />
                        )}
                      </div>
                      <ConfirmationModal
                        text="You can rejoin at any time."
                        title="Leave channel"
                        onConfirm={leaveChannel}
                        open={openLeaveChannel}
                        setOpen={setOpenLeaveChannel}
                      />
                    </>
                  )}
                  {section === "members" && <MembersSection />}
                  {section === "settings" && (
                    <>
                      <div
                        style={{
                          backgroundColor: themeColors?.background,
                          borderColor: themeColors?.selectionBackground,
                        }}
                        className="border rounded-xl"
                      >
                        <EditChannelItems
                          name="Name"
                          field="name"
                          title="Rename this channel"
                          placeholder="e.g. marketing"
                          value={`#${name}`}
                          textArea={false}
                          editable="Names must be lowercase, without spaces or periods, and can’t be longer than 80 characters."
                        />
                      </div>
                      {!defaultChannel && (
                        <div
                          style={{
                            backgroundColor: themeColors?.background,
                            borderColor: themeColors?.selectionBackground,
                          }}
                          className="border rounded-xl"
                        >
                          <EditChannelItems
                            icon={
                              <ArchiveIcon
                                style={{
                                  color: themeColors?.red,
                                }}
                                className="focus-within:h-5 w-5 mr-2"
                              />
                            }
                            color={themeColors?.red}
                            name="Archive channel"
                            displayDetails={false}
                            onClick={() => setOpenArchiveChannel(true)}
                          />
                          <EditChannelItems
                            icon={
                              <TrashIcon
                                style={{
                                  color: themeColors?.red,
                                }}
                                className="focus-within:h-5 w-5 mr-2"
                              />
                            }
                            color={themeColors?.red}
                            name="Delete channel"
                            displayDetails={false}
                            onClick={() => setOpenDeleteChannel(true)}
                          />
                        </div>
                      )}
                      <ConfirmationModal
                        text="This action is irreversible."
                        title="Delete channel"
                        onConfirm={deleteChannel}
                        open={openDeleteChannel}
                        setOpen={setOpenDeleteChannel}
                      />
                      <ConfirmationModal
                        text="You can unarchive this channel at any time."
                        title="Archive channel"
                        onConfirm={archiveChannel}
                        open={openArchiveChannel}
                        setOpen={setOpenArchiveChannel}
                      />
                    </>
                  )}
                </div>
              </div>
            </div>
          </Transition.Child>
        </div>
      </Dialog>
    </Transition.Root>
  );
}
