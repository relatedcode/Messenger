import { Dialog, RadioGroup, Transition } from "@headlessui/react";
import { XIcon } from "@heroicons/react/outline";
import ChannelsSection from "components/dashboard/sidebar/ChannelsSection";
import TeammatesSection from "components/dashboard/sidebar/TeammatesSection";
import { useModal } from "contexts/ModalContext";
import { useTheme } from "contexts/ThemeContext";
import { Fragment, useRef } from "react";
import classNames from "utils/classNames";

export default function CreateMessageModal() {
  const { themeColors } = useTheme();
  const cancelButtonRef = useRef(null);
  const {
    openCreateMessage: open,
    setOpenCreateMessage: setOpen,
    createMessageSection: section,
    setCreateMessageSection: setSection,
  } = useModal();

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
                  className="font-bold text-2xl"
                >
                  New message
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
              <div
                className="pt-10"
                style={{ backgroundColor: themeColors?.background }}
              >
                <RadioGroup
                  as="div"
                  value={section}
                  onChange={setSection}
                  className="flex space-x-6 px-8 text-sm font-normal"
                  style={{ color: themeColors?.foreground }}
                >
                  <RadioGroup.Option
                    value="channels"
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
                        <span>Channels</span>
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
                </RadioGroup>
                <div
                  className={classNames("space-y-6 pt-5 pb-8 border-t h-550")}
                  style={{
                    backgroundColor: themeColors?.background,
                    borderColor: themeColors?.selectionBackground,
                  }}
                >
                  {section === "channels" && <ChannelsSection />}
                  {section === "members" && <TeammatesSection />}
                </div>
              </div>
            </div>
          </Transition.Child>
        </div>
      </Dialog>
    </Transition.Root>
  );
}
