import { Dialog, RadioGroup, Transition } from "@headlessui/react";
import {
  CheckCircleIcon,
  EyeIcon,
  HashtagIcon,
  XIcon,
} from "@heroicons/react/outline";
import { APP_NAME, THEMES_COUNT } from "config";
import { useModal } from "contexts/ModalContext";
import { IColor, useTheme } from "contexts/ThemeContext";
import { useUser } from "contexts/UserContext";
import { Fragment, useEffect, useMemo, useState } from "react";
import { postData } from "utils/api-helpers";
import classNames from "utils/classNames";

function ThemeItem({ name }: { name: string }) {
  const { themeColors } = useTheme();
  const [previewTheme, setPreviewTheme] = useState<IColor | null>(null);

  useEffect(() => {
    fetch(`${process.env.PUBLIC_URL}/themes/${name}.json`, {
      headers: {
        "Content-Type": "application/json",
        Accept: "application/json",
      },
    })
      .then((response) => response.json())
      .then((json) => {
        setPreviewTheme(json);
      });
  }, []);

  return (
    <RadioGroup.Option value={name} className="focus:outline-none">
      {({ checked }) => (
        <div
          className="h-40 w-48 flex flex-col border rounded cursor-pointer"
          style={{
            color: checked ? themeColors?.blue : themeColors?.foreground,
            borderColor: checked
              ? themeColors?.blue
              : themeColors?.selectionBackground,
          }}
        >
          <div className="h-2/3">
            <div
              style={{
                backgroundColor: previewTheme?.blue,
                borderTopRightRadius: "3px",
                borderTopLeftRadius: "3px",
              }}
              className="h-1/5 w-full"
            />
            <div className="flex items-center justify-center h-4/5 w-full">
              <div
                style={{ backgroundColor: previewTheme?.selectionBackground }}
                className="w-1/6 h-full"
              />
              <div
                style={{ backgroundColor: previewTheme?.background }}
                className="w-full h-full relative"
              >
                <div className="absolute z-30 left-0 top-0 w-full h-full">
                  <div
                    style={{ backgroundColor: previewTheme?.foreground }}
                    className="h-2 w-8 m-1 rounded-l-full rounded-r-full"
                  />
                  <div className="flex items-center space-x-1 mx-1 w-full">
                    <HashtagIcon
                      className="h-3 w-3"
                      style={{ color: previewTheme?.foreground }}
                    />
                    <div
                      style={{ backgroundColor: previewTheme?.foreground }}
                      className="h-2 w-11 m-1 rounded-l-full rounded-r-full"
                    />
                  </div>
                  <div
                    className="flex items-center space-x-1 px-1 w-full"
                    style={{ backgroundColor: previewTheme?.blue }}
                  >
                    <HashtagIcon
                      className="h-3 w-3"
                      style={{ color: previewTheme?.brightWhite }}
                    />
                    <div
                      style={{ backgroundColor: previewTheme?.brightWhite }}
                      className="h-2 w-11 m-1 rounded-l-full rounded-r-full"
                    />
                  </div>
                  <div className="flex items-center justify-between space-x-1 px-1 w-full">
                    <div className="flex items-center space-x-2">
                      <div
                        className="h-2 w-2 rounded-full"
                        style={{ backgroundColor: "#94e864" }}
                      />
                      <div
                        style={{ backgroundColor: previewTheme?.foreground }}
                        className="h-2 w-11 m-1 rounded-l-full rounded-r-full"
                      />
                    </div>
                    <div
                      style={{ backgroundColor: previewTheme?.red }}
                      className="h-2 w-4 m-1 rounded-l-full rounded-r-full"
                    />
                  </div>
                </div>
              </div>
            </div>
          </div>
          <div
            style={{
              borderColor: checked
                ? themeColors?.blue
                : themeColors?.selectionBackground,
            }}
            className="px-5 py-2 h-1/3 border-t flex items-center overflow-x-auto"
          >
            {checked && (
              <CheckCircleIcon className="h-5 w-5 th-color-blue mr-2 flex-shrink-0" />
            )}
            {previewTheme?.name}
          </div>
        </div>
      )}
    </RadioGroup.Option>
  );
}

function Themes() {
  const { theme, setTheme } = useTheme();
  const { themeColors } = useTheme();

  const themes = useMemo(
    () =>
      Array.from(
        Array(THEMES_COUNT),
        (_, index) =>
          `theme${index + 1 < 10 ? `0${index + 1}` : index + 1}.json`
      ),
    []
  );

  return (
    <div>
      <span style={{ color: themeColors?.foreground }}>
        {`Change the appearance of ${APP_NAME} across all of your workspaces.`}
      </span>
      <RadioGroup
        className="grid grid-cols-2 gap-4 mt-5"
        value={theme.replace(".json", "")}
        onChange={setTheme}
      >
        {themes.map((th) => (
          <ThemeItem key={th} name={th.replace(".json", "")} />
        ))}
      </RadioGroup>
    </div>
  );
}

export default function Preferences() {
  const { themeColors, theme } = useTheme();
  const { userdata } = useUser();
  const { openPreferences: open, setOpenPreferences: setOpen } = useModal();
  const [selected, setSelected] = useState("themes");

  const onClose = () => {
    if (userdata?.objectId && userdata?.theme !== theme) {
      postData(`/users/${userdata.objectId}`, {
        theme,
      });
    }
    setOpen(false);
  };

  return (
    <Transition.Root show={open} as={Fragment}>
      <Dialog
        as="div"
        static
        className="fixed z-10 inset-0 overflow-y-auto"
        open={open}
        onClose={onClose}
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
            <Dialog.Overlay className="fixed inset-0 transition-opacity" />
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
            <div className="inline-block border th-border-selbg th-bg-bg align-bottom rounded-lg text-left overflow-hidden shadow-xl transform transition-all sm:my-8 sm:align-middle sm:max-w-3xl sm:w-full">
              <div
                style={{
                  backgroundColor: themeColors?.background,
                  borderColor: themeColors?.selectionBackground,
                }}
                className="border-b p-6 flex justify-between items-center"
              >
                <h5 className="font-bold text-2xl th-color-for">Preferences</h5>
                <div
                  role="button"
                  tabIndex={0}
                  className="cursor-pointer focus:outline-none"
                  onClick={onClose}
                >
                  <XIcon className="h-5 w-5 th-color-for" />
                </div>
              </div>
              <div className="p-6 px-4 pt-0 pb-0 max-h-screen min-h-400 grid grid-cols-4 th-bg-bg">
                <RadioGroup
                  className="col-span-1 h-full py-4"
                  value={selected}
                  onChange={setSelected}
                >
                  <RadioGroup.Option
                    className="focus:outline-none"
                    value="themes"
                  >
                    {({ checked }) => (
                      <div
                        className={classNames(
                          "flex items-center px-2 py-px rounded space-x-2 cursor-pointer outline-none ring-0"
                        )}
                        style={{
                          backgroundColor: checked
                            ? themeColors?.blue
                            : themeColors?.background,
                          color: checked
                            ? themeColors?.brightWhite
                            : themeColors?.foreground,
                        }}
                      >
                        <EyeIcon className="h-4 w-4" />
                        <span>Themes</span>
                      </div>
                    )}
                  </RadioGroup.Option>
                </RadioGroup>
                <div className="col-span-3 flex flex-col px-6 py-3 overflow-y-scroll h-550">
                  {selected === "themes" && <Themes />}
                </div>
              </div>
            </div>
          </Transition.Child>
        </div>
      </Dialog>
    </Transition.Root>
  );
}
