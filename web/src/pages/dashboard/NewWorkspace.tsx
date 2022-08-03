import { Tab } from "@headlessui/react";
import AuthButton from "components/authentication/AuthButton";
import LoadingScreen from "components/LoadingScreen";
import TextField from "components/TextField";
import { WorkspacesDropdown } from "components/WorkspacesDropdown";
import { APP_NAME } from "config";
import { useUser } from "contexts/UserContext";
import { Formik } from "formik";
import { useMyWorkspaces, WorkspacesContext } from "hooks/useWorkspaces";
import { Fragment, useContext, useState } from "react";
import { Helmet } from "react-helmet-async";
import toast from "react-hot-toast";
import { Navigate, useNavigate } from "react-router-dom";
import { postData } from "utils/api-helpers";
import classNames from "utils/classNames";
import * as Yup from "yup";

const tabs = [{ name: "Create" }, { name: "Join" }];

export function TabLists() {
  return (
    <div className="mt-5">
      <div className="hidden sm:block">
        <nav
          className="group p-0.5 rounded-lg flex bg-gray-100 hover:bg-gray-200"
          aria-label="Tabs"
        >
          {tabs.map((tab) => (
            <Tab.List key={tab.name} className="w-1/2 text-center flex">
              <Tab as={Fragment}>
                {({ selected }) => (
                  <button
                    className={classNames(
                      selected
                        ? "flex rounded-md focus:outline-none"
                        : "px-auto rounded-md flex items-center text-sm text-gray-600 font-medium focus:outline-none",
                      "flex-1 flex"
                    )}
                    aria-current={selected ? "page" : undefined}
                  >
                    <span
                      className={classNames(
                        selected
                          ? "bg-white shadow-sm ring-1 ring-black ring-opacity-5"
                          : "",
                        "p-1.5 lg:pl-2.5 lg:pr-3.5 rounded-md flex justify-center items-center text-sm font-medium flex-1"
                      )}
                    >
                      {tab.name}
                    </span>
                  </button>
                )}
              </Tab>
            </Tab.List>
          ))}
        </nav>
      </div>
    </div>
  );
}

function HeaderDefaultWorkspace() {
  const navigate = useNavigate();
  const { userdata } = useUser();
  return (
    <header className="w-full py-8 grid grid-cols-3">
      <div />
      <div />
      <div className="flex text-sm flex-col justify-center items-end mr-6">
        <div className="text-gray-500">{userdata?.fullName}</div>
        <button
          onClick={() => {
            navigate("/dashboard/logout");
          }}
          className="font-semibold"
          style={{ color: "#1264a3" }}
        >
          Sign out
        </button>
      </div>
    </header>
  );
}

export default function NewWorkspace() {
  const { user } = useUser();
  const { value: allWorkspaces, loading: loadingAllWorkspaces } =
    useContext(WorkspacesContext);
  const { value: workspaces } = useMyWorkspaces();
  const [createWorkspaceLoading, setCreateWorkspaceLoading] = useState(false);

  if (loadingAllWorkspaces) return <LoadingScreen />;

  if (workspaces?.length > 0)
    return (
      <Navigate
        to={`/dashboard/workspaces/${workspaces[0].objectId}/channels/${workspaces[0].channelId}`}
      />
    );

  return (
    <>
      <Helmet>
        <title>{APP_NAME}</title>
      </Helmet>
      <HeaderDefaultWorkspace />
      <div className="max-w-2xl flex flex-col items-center mx-auto">
        <h1 className="font-extrabold text-5xl mb-2 th-color-for">
          Add workspaces
        </h1>
        <div className="max-w-md w-full mt-10">
          <Tab.Group>
            <TabLists />
            <Tab.Panels>
              <Tab.Panel className="focus:outline-none">
                <Formik
                  initialValues={{
                    workspaceName: "",
                  }}
                  validationSchema={Yup.object().shape({
                    workspaceName: Yup.string().max(255).required(),
                  })}
                  onSubmit={async ({ workspaceName }) => {
                    setCreateWorkspaceLoading(true);
                    try {
                      await postData("/workspaces", {
                        name: workspaceName,
                      });
                    } catch (err: any) {
                      toast.error(err.message);
                      setCreateWorkspaceLoading(false);
                    }
                  }}
                >
                  {({ values, handleChange, handleSubmit }) => (
                    <form
                      className="max-w-md w-full mt-10"
                      noValidate
                      onSubmit={handleSubmit}
                    >
                      <div className="w-full space-y-5">
                        <TextField
                          value={values.workspaceName}
                          handleChange={handleChange}
                          label="Workspace name"
                          name="workspaceName"
                          focus
                          placeholder="Workspace name"
                        />
                        <div className="pt-4">
                          <AuthButton
                            text="Create workspace"
                            isSubmitting={createWorkspaceLoading}
                          />
                        </div>
                      </div>
                    </form>
                  )}
                </Formik>
              </Tab.Panel>
              <Tab.Panel className="focus:outline-none">
                <Formik
                  initialValues={{
                    workspace: allWorkspaces![0] || "",
                  }}
                  enableReinitialize
                  onSubmit={async ({ workspace }) => {
                    setCreateWorkspaceLoading(true);
                    try {
                      await postData(
                        `/workspaces/${workspace.objectId}/members`,
                        {
                          email: user?.email,
                        }
                      );
                    } catch (err: any) {
                      toast.error(err.message);
                      setCreateWorkspaceLoading(false);
                    }
                  }}
                >
                  {({ handleSubmit, values, setFieldValue }) => (
                    <form
                      className="max-w-md w-full mt-10"
                      noValidate
                      onSubmit={handleSubmit}
                    >
                      <div className="w-full space-y-5">
                        {allWorkspaces?.length! > 0 ? (
                          <>
                            <WorkspacesDropdown
                              workspaces={allWorkspaces}
                              select={values.workspace}
                              setSelect={setFieldValue}
                            />
                            <div className="pt-4">
                              <AuthButton
                                text="Join workspace"
                                isSubmitting={createWorkspaceLoading}
                              />
                            </div>
                          </>
                        ) : (
                          <div className="th-color-for text-base font-medium w-full text-center">
                            No workspaces available.
                          </div>
                        )}
                      </div>
                    </form>
                  )}
                </Formik>
              </Tab.Panel>
            </Tab.Panels>
          </Tab.Group>
        </div>
      </div>
    </>
  );
}
