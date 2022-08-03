import { Listbox, Transition } from "@headlessui/react";
import { CheckIcon, SelectorIcon } from "@heroicons/react/solid";
import { Fragment } from "react";
import classNames from "utils/classNames";
import { getHref } from "utils/get-file-url";

export function WorkspacesSelectDropdown({
  workspaces,
  select,
  setSelect,
}: {
  workspaces: any;
  select: any;
  setSelect: any;
}) {
  return (
    <div>
      <label
        htmlFor="workspaces"
        className="block text-sm font-bold th-color-for"
      >
        Join workspace
      </label>
      <select
        id="workspaces"
        name="workspaces"
        value={select}
        onChange={(e) => setSelect("workspace", e.target.value)}
        className="mt-3 w-full th-color-for th-bg-bg border th-border-brblack rounded-md shadow-sm pl-3 pr-10 py-2 text-left cursor-default focus:outline-none sm:text-sm"
      >
        {workspaces.map((workspace: any) => (
          <option value={workspace.objectId}>{workspace.name}</option>
        ))}
      </select>
    </div>
  );
}

export function WorkspacesDropdown({
  workspaces,
  select,
  setSelect,
}: {
  workspaces: any;
  select: any;
  setSelect: any;
}) {
  return (
    <Listbox
      value={select}
      onChange={(e) => setSelect("workspace", e)}
      as="div"
    >
      <Listbox.Label className="block text-sm font-bold th-color-for">
        Join workspace
      </Listbox.Label>
      <div className="mt-2 relative">
        <Listbox.Button className="relative w-full th-bg-bg border th-border-brblack rounded-md shadow-sm pl-3 pr-10 py-2 text-left cursor-default focus:outline-none sm:text-sm">
          <span className="flex items-center">
            <img
              src={
                getHref(select?.thumbnailURL) ||
                getHref(select?.photoURL) ||
                `${process.env.PUBLIC_URL}/blank_workspace.png`
              }
              alt=""
              className="flex-shrink-0 h-6 w-6 rounded-md"
            />
            <span className="ml-3 block truncate th-color-for">
              {select.name}
            </span>
          </span>
          <span className="ml-3 absolute inset-y-0 right-0 flex items-center pr-2 pointer-events-none">
            <SelectorIcon className="h-5 w-5 th-color-for" aria-hidden="true" />
          </span>
        </Listbox.Button>

        <Transition
          as={Fragment}
          leave="transition ease-in duration-100"
          leaveFrom="opacity-100"
          leaveTo="opacity-0"
        >
          <Listbox.Options className="absolute z-10 mt-1 w-full th-bg-bg shadow-lg max-h-56 rounded-md py-1 text-base ring-1 ring-black ring-opacity-5 overflow-auto focus:outline-none sm:text-sm">
            {workspaces.map((workspace: any) => {
              const photoURL =
                getHref(workspace?.thumbnailURL) ||
                getHref(workspace?.photoURL) ||
                `${process.env.PUBLIC_URL}/blank_workspace.png`;
              return (
                <Listbox.Option
                  key={workspace.objectId}
                  className={({ active }) =>
                    classNames(
                      active ? "th-color-bg th-bg-blue" : "th-color-for",
                      "cursor-default select-none relative py-2 pl-3 pr-9"
                    )
                  }
                  value={workspace}
                >
                  {({ selected, active }) => (
                    <>
                      <div className="flex items-center">
                        <img
                          src={photoURL}
                          alt=""
                          className="flex-shrink-0 h-6 w-6 rounded-md"
                        />
                        <span
                          className={classNames(
                            selected ? "font-semibold" : "font-normal",
                            "ml-3 block truncate"
                          )}
                        >
                          {workspace.name}
                        </span>
                      </div>

                      {selected ? (
                        <span
                          className={classNames(
                            active ? "th-color-bg" : "th-color-blue",
                            "absolute inset-y-0 right-0 flex items-center pr-4"
                          )}
                        >
                          <CheckIcon className="h-5 w-5" aria-hidden="true" />
                        </span>
                      ) : null}
                    </>
                  )}
                </Listbox.Option>
              );
            })}
          </Listbox.Options>
        </Transition>
      </div>
    </Listbox>
  );
}
