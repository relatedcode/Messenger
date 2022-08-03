import { Dialog, Transition } from "@headlessui/react";
import { XIcon } from "@heroicons/react/outline";
import CancelButton from "components/CancelButton";
import ModalButton from "components/dashboard/ModalButton";
import TextField from "components/TextField";
import { APP_NAME } from "config";
import { useUser } from "contexts/UserContext";
import { Formik } from "formik";
import { uploadFile } from "gqlite-lib/dist/client/storage";
import React, { Fragment, useEffect, useRef, useState } from "react";
import toast from "react-hot-toast";
import { postData } from "utils/api-helpers";
import { getHref } from "utils/get-file-url";
import now from "utils/now";

export default function EditProfile({
  open,
  setOpen,
}: {
  open: boolean;
  setOpen: React.Dispatch<React.SetStateAction<boolean>>;
}) {
  const { userdata } = useUser();

  const userPhotoURL = getHref(userdata?.photoURL);

  const [photo, setPhoto] = useState<File | null | undefined>(null);
  const [photoUrl, setPhotoUrl] = useState("");
  const fileRef = useRef<any>(null);

  useEffect(() => {
    if (photo) setPhotoUrl(URL.createObjectURL(photo));
    else setPhotoUrl("");
  }, [photo]);

  useEffect(() => {
    if (open) {
      setPhoto(null);
      setPhotoUrl("");
    }
  }, [open]);

  const handleSavePicture = async () => {
    try {
      const path = await uploadFile(
        "messenger",
        `User/${userdata.objectId}/${now()}_photo`,
        photo!
      );
      return path;
    } catch (err: any) {
      console.error(err);
      return "";
    }
  };

  const handleDeletePicture = async () => {
    try {
      await postData(`/users/${userdata?.objectId}`, {
        photoPath: "",
      });
      setPhoto(null);
      setPhotoUrl("");
    } catch (err: any) {
      console.error(err);
    }
  };

  return (
    <Transition.Root show={open} as={Fragment}>
      <Dialog
        as="div"
        static
        className="fixed z-10 inset-0 overflow-y-auto"
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
            <div className="inline-block align-bottom rounded-lg text-left overflow-hidden shadow-xl transform transition-all sm:my-8 sm:align-middle sm:max-w-2xl sm:w-full th-bg-bg">
              <Formik
                initialValues={{
                  fullName: userdata?.fullName || "",
                  displayName: userdata?.displayName || "",
                  title: userdata?.title || "",
                  phoneNumber: userdata?.phoneNumber || "",
                }}
                enableReinitialize
                onSubmit={async (
                  { fullName, displayName, title, phoneNumber },
                  { setSubmitting }
                ) => {
                  setSubmitting(true);
                  try {
                    await postData(`/users/${userdata.objectId}`, {
                      ...(fullName !== userdata?.fullName && { fullName }),
                      ...(displayName !== userdata?.displayName && {
                        displayName,
                      }),
                      ...(title !== userdata?.title && { title }),
                      ...(phoneNumber !== userdata?.phoneNumber && {
                        phoneNumber,
                      }),
                      ...(photoUrl && { photoPath: await handleSavePicture() }),
                    });
                    setOpen(false);
                  } catch (err: any) {
                    toast.error(err.message);
                  }
                  setSubmitting(false);
                }}
              >
                {({ values, handleChange, isSubmitting, handleSubmit }) => (
                  <form
                    className="flex flex-col h-full"
                    noValidate
                    onSubmit={handleSubmit}
                  >
                    <div className="px-4 pt-5 pb-4 sm:p-6 sm:pb-4 flex justify-between items-center th-bg-bg">
                      <h5 className="font-bold text-2xl th-color-for">
                        Edit your profile
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
                    <div className="p-6 pt-0 pb-6 grid grid-cols-3 th-bg-bg">
                      <div className="col-span-2 space-y-6 px-px max-h-450 overflow-y-auto">
                        <TextField
                          label="Full name"
                          name="fullName"
                          value={values.fullName}
                          handleChange={handleChange}
                          placeholder="Full name"
                        />
                        <TextField
                          label="Display name"
                          name="displayName"
                          value={values.displayName}
                          handleChange={handleChange}
                          placeholder="Display name"
                          infos={`This could be your first name, or a nickname — however you’d like people to refer to you in ${APP_NAME}.`}
                        />
                        <TextField
                          label="What I do"
                          name="title"
                          value={values.title}
                          handleChange={handleChange}
                          placeholder="What I do"
                          infos="Let people know what you do."
                        />
                        <TextField
                          label="Phone number"
                          name="phoneNumber"
                          value={values.phoneNumber}
                          handleChange={handleChange}
                          placeholder="(123) 555-555"
                          infos="Enter a phone number."
                        />
                      </div>
                      <div className="col-span-1 flex flex-col pl-7">
                        <h4 className="block text-sm font-bold th-color-for">
                          Profile photo
                        </h4>
                        <input
                          ref={fileRef}
                          hidden
                          type="file"
                          accept="image/*"
                          onChange={(e) => setPhoto(e.target.files?.item(0))}
                        />
                        <div
                          className="rounded h-44 w-44 bg-cover mt-2"
                          style={{
                            backgroundImage: `url(${
                              photoUrl ||
                              userPhotoURL ||
                              `${process.env.PUBLIC_URL}/blank_user.png`
                            })`,
                          }}
                        />
                        <button
                          type="button"
                          className="th-bg-blue th-color-brwhite inline-flex justify-center py-2 px-4 text-base font-bold rounded focus:outline-none focus:ring-4 focus:ring-blue-200 mt-4 sm:w-auto sm:text-sm"
                          onClick={() => fileRef?.current?.click()}
                        >
                          Upload an Image
                        </button>
                        {userPhotoURL && (
                          <button
                            type="button"
                            className="w-44 text-center text-sm mt-3 th-color-blue"
                            onClick={handleDeletePicture}
                          >
                            Remove photo
                          </button>
                        )}
                      </div>
                    </div>
                    <div className="px-4 py-5 sm:px-6 sm:flex sm:flex-row-reverse border-t th-border-selbg">
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
