import { Dialog, Tab, Transition } from "@headlessui/react";
import { PlusIcon, XIcon } from "@heroicons/react/outline";
import ModalButton from "components/dashboard/ModalButton";
import Spinner from "components/Spinner";
import TextField from "components/TextField";
import { WorkspacesSelectDropdown } from "components/WorkspacesDropdown";
import { useModal } from "contexts/ModalContext";
import { useTheme } from "contexts/ThemeContext";
import { useUser } from "contexts/UserContext";
import { Formik } from "formik";
import { useMyWorkspaces, WorkspacesContext } from "hooks/useWorkspaces";
import { TabLists } from "pages/dashboard/NewWorkspace";
import React, { Fragment, useContext, useRef } from "react";
import toast from "react-hot-toast";
import { useNavigate, useParams } from "react-router-dom";
import { postData } from "utils/api-helpers";
import classNames from "utils/classNames";
import { getHref } from "utils/get-file-url";
import wait from "utils/wait";
import * as Yup from "yup";

function CreateWorkspace() {
  const { user } = useUser();
  const { value: allWorkspaces, loading } = useContext(WorkspacesContext);
  const cancelButtonRef = useRef(null);
  const { openCreateWorkspace: open, setOpenCreateWorkspace: setOpen } =
    useModal();
  const { value: workspaces } = useMyWorkspaces();
  const navigate = useNavigate();

  const workspacesToJoin = allWorkspaces?.filter(
    (item: any) => !item.members.includes(user?.uid)
  );

  const [isLoading, setIsLoading] = React.useState(false);

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
            <div className="th-bg-bg inline-block align-bottom rounded-lg text-left overflow-hidden shadow-xl transform transition-all sm:my-8 sm:align-middle sm:max-w-lg sm:w-full">
              <div className="th-bg-bg px-4 pt-5 pb-4 sm:p-6 sm:pb-4 flex justify-between items-center">
                <h5 className="font-bold text-2xl th-color-for">
                  Add workspace
                </h5>
                <div
                  role="button"
                  tabIndex={0}
                  className="cursor-pointer focus:outline-none"
                  onClick={() => setOpen(false)}
                >
                  <XIcon className="h-5 w-5 th-color-for" />
                </div>
              </div>
              <div className="p-6 pt-0 pb-6 th-bg-bg">
                <span className="font-base text-sm th-color-for">
                  A workspace is made up of channels, where team members can
                  communicate and work together.
                </span>

                <Tab.Group>
                  <TabLists />
                  <Tab.Panels>
                    <Tab.Panel className="focus:outline-none">
                      <Formik
                        initialValues={{
                          name: "",
                        }}
                        validationSchema={Yup.object({
                          name: Yup.string().max(100).required(),
                        })}
                        enableReinitialize
                        onSubmit={async ({ name }, { setSubmitting }) => {
                          setSubmitting(true);
                          try {
                            const { workspaceId, channelId } = await postData(
                              "/workspaces",
                              {
                                name,
                              }
                            );
                            while (
                              workspaces?.find(
                                (w: any) => w.objectId === workspaceId
                              )
                            ) {
                              /* eslint-disable-next-line */
                              await wait(1000);
                            }
                            await wait(2000);
                            navigate(
                              `/dashboard/workspaces/${workspaceId}/channels/${channelId}`
                            );
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
                        }) => (
                          <form noValidate onSubmit={handleSubmit}>
                            <div className="space-y-6 pt-5">
                              <TextField
                                label="Name"
                                name="name"
                                focus
                                required
                                value={values.name}
                                handleChange={handleChange}
                                placeholder="Workspace name"
                              />
                            </div>
                            <div className="pt-3 sm:flex sm:flex-row-reverse">
                              <ModalButton
                                text="Create"
                                isSubmitting={isSubmitting}
                              />
                            </div>
                          </form>
                        )}
                      </Formik>
                    </Tab.Panel>
                    <Tab.Panel className="focus:outline-none">
                      {loading ? (
                        <Spinner />
                      ) : (
                        <Formik
                          initialValues={{
                            workspace: workspacesToJoin![0]?.objectId || "",
                          }}
                          enableReinitialize
                          onSubmit={async ({ workspace }) => {
                            setIsLoading(true);
                            try {
                              const { workspaceId, channelId } = await postData(
                                `/workspaces/${workspace}/members`,
                                {
                                  email: user?.email,
                                }
                              );
                              while (
                                workspaces?.find(
                                  (w: any) => w.objectId === workspaceId
                                )
                              ) {
                                /* eslint-disable-next-line */
                                await wait(1000);
                              }
                              await wait(1000);
                              navigate(
                                `/dashboard/workspaces/${workspaceId}/channels/${channelId}`
                              );
                              setOpen(false);
                              setIsLoading(false);
                            } catch (err: any) {
                              toast.error(err.message);
                              setIsLoading(false);
                            }
                          }}
                        >
                          {({ handleSubmit, values, setFieldValue }) => (
                            <form noValidate onSubmit={handleSubmit}>
                              {workspacesToJoin?.length! > 0 ? (
                                <>
                                  <div className="space-y-6 pt-5">
                                    <WorkspacesSelectDropdown
                                      workspaces={workspacesToJoin}
                                      select={values.workspace}
                                      setSelect={setFieldValue}
                                    />
                                  </div>
                                  <div className="pt-5 sm:flex sm:flex-row-reverse">
                                    <ModalButton
                                      text="Join"
                                      isSubmitting={isLoading}
                                    />
                                  </div>
                                </>
                              ) : (
                                <div className="mt-5 th-color-for text-base font-medium w-full text-center">
                                  You are already a member of all the
                                  workspaces.
                                </div>
                              )}
                            </form>
                          )}
                        </Formik>
                      )}
                    </Tab.Panel>
                  </Tab.Panels>
                </Tab.Group>
              </div>
            </div>
          </Transition.Child>
        </div>
      </Dialog>
    </Transition.Root>
  );
}

function WorkspaceItem({
  src,
  objectId,
  channelId,
}: {
  objectId: string;
  channelId: string;
  src: any;
}) {
  const { themeColors } = useTheme();
  const { workspaceId } = useParams();
  const navigate = useNavigate();
  const selected = objectId === workspaceId;
  const photoURL = src;
  return (
    <div
      role="button"
      tabIndex={0}
      className={classNames(
        "flex items-center justify-center cursor-pointer focus:outline-none"
      )}
      onClick={() =>
        navigate(`/dashboard/workspaces/${objectId}/channels/${channelId}`)
      }
    >
      <img
        src={photoURL || `${process.env.PUBLIC_URL}/blank_workspace.png`}
        alt="workspace"
        className={classNames(
          selected ? "border-2" : "",
          "h-10 w-10 rounded-md p-px"
        )}
        style={{ borderColor: selected ? themeColors?.blue : "" }}
      />
    </div>
  );
}

function AddWorkspaces() {
  const { themeColors } = useTheme();
  const { setOpenCreateWorkspace: setOpen } = useModal();
  return (
    <div
      role="button"
      tabIndex={0}
      className="flex items-center justify-center focus:outline-none"
      onClick={() => setOpen(true)}
    >
      <div className="flex items-center justify-center cursor-pointer rounded h-10 w-10">
        <PlusIcon
          className="h-8 w-8 p-1"
          style={{ color: themeColors?.foreground }}
        />
      </div>
    </div>
  );
}

export default function Workspaces() {
  const { value } = useMyWorkspaces();
  return (
    <div className="row-span-2 border-r flex flex-col items-center space-y-5 py-5 flex-1 overflow-y-auto th-bg-selbg th-border-bg">
      {value?.map((doc: any) => (
        <WorkspaceItem
          key={doc.objectId}
          objectId={doc.objectId}
          channelId={doc.channelId}
          src={getHref(doc.thumbnailURL) || getHref(doc.photoURL)}
        />
      ))}
      <AddWorkspaces />
      <CreateWorkspace />
    </div>
  );
}
