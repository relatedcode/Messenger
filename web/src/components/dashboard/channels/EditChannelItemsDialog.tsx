import { Dialog, Transition } from "@headlessui/react";
import { XIcon } from "@heroicons/react/outline";
import CancelButton from "components/CancelButton";
import ModalButton from "components/dashboard/ModalButton";
import TextArea from "components/TextArea";
import TextField from "components/TextField";
import { useTheme } from "contexts/ThemeContext";
import { Formik } from "formik";
import { useChannelById } from "hooks/useChannels";
import React, { Fragment, useRef } from "react";
import toast from "react-hot-toast";
import { useParams } from "react-router-dom";
import { postData } from "utils/api-helpers";

export default function EditChannelItemsDialog({
  open,
  setOpen,
  title,
  placeholder,
  infos,
  textArea = true,
  field,
}: {
  open: boolean;
  setOpen: React.Dispatch<React.SetStateAction<boolean>>;
  title: string;
  placeholder: string;
  infos: string;
  textArea?: boolean;
  field?: string;
}) {
  const { themeColors } = useTheme();
  const cancelButtonRef = useRef(null);
  const { channelId } = useParams();
  const { value } = useChannelById(channelId);

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
                  {title}
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
                  detail: (value ? value[`${field}`] : "") || "",
                }}
                enableReinitialize
                onSubmit={async (values, { setSubmitting }) => {
                  setSubmitting(true);
                  try {
                    await postData(`/channels/${channelId}`, {
                      [`${field}`]:
                        field === "name"
                          ? `${values.detail.replace("#", "").trim()}`
                          : values.detail,
                    });
                    toast.success("Updated.");
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
                      <div className="space-y-6">
                        {textArea && (
                          <TextArea
                            name="detail"
                            placeholder={placeholder}
                            infos={infos}
                            focus
                            value={values.detail}
                            handleChange={handleChange}
                          />
                        )}
                        {!textArea && (
                          <TextField
                            label="Name"
                            name="detail"
                            focus
                            placeholder={placeholder}
                            infos={infos}
                            handleChange={(e: any) =>
                              setFieldValue(
                                "detail",
                                e.target.value
                                  .toLowerCase()
                                  .replace(/[^a-z0-9_\- ]/g, "")
                                  .replace("#", "")
                              )
                            }
                            value={values.detail.replace("#", "")}
                          />
                        )}
                      </div>
                    </div>
                    <div className="px-4 pb-5 pt-1 sm:px-6 sm:flex sm:flex-row-reverse">
                      <ModalButton text="Save" isSubmitting={isSubmitting} />
                      <CancelButton setOpen={setOpen} />
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
