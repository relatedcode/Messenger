import { Listbox, Transition } from "@headlessui/react";
import { EmojiHappyIcon } from "@heroicons/react/outline";
import { reactions } from "lib/reactions";
import { Fragment, useEffect, useState } from "react";
import toast from "react-hot-toast";
import { postData } from "utils/api-helpers";
import classNames from "utils/classNames";

export function ReactionModal({
  messageId,
  myReaction,
}: {
  messageId: string;
  myReaction: string;
}) {
  const [selected, setSelected] = useState(reactions[reactions.length - 1]);

  useEffect(() => {
    setSelected(
      reactions.find((r) => r.value === myReaction) ||
        reactions[reactions.length - 1]
    );
  }, [myReaction]);

  return (
    <Listbox
      value={selected}
      onChange={async (e) => {
        setSelected(e);
        try {
          await postData(`/messages/${messageId}/reactions`, {
            reaction: e.value,
          });
        } catch (err: any) {
          toast.error(err.message);
        }
      }}
    >
      {({ open }) => (
        <>
          <Listbox.Label className="sr-only">Reaction</Listbox.Label>
          <div className="relative flex flex-1">
            <Listbox.Button className="th-bg-bg th-border-selbg th-color-for relative inline-flex items-center px-3 py-1 border text-sm font-medium focus:z-10 focus:outline-none">
              <span className="sr-only">Reaction</span>
              <EmojiHappyIcon className="h-4 w-4" />
            </Listbox.Button>

            <Transition
              show={open}
              as={Fragment}
              leave="transition ease-in duration-100"
              leaveFrom="opacity-100"
              leaveTo="opacity-0"
            >
              <Listbox.Options className="origin-top-left bottom-0 right-0 absolute z-10 -ml-6 w-60 bg-white shadow rounded-lg py-3 text-base ring-1 ring-black ring-opacity-5 focus:outline-none sm:ml-auto sm:w-64 sm:text-sm">
                {reactions.map((reaction) => (
                  <Listbox.Option
                    key={reaction.value}
                    className={({ active, selected }) =>
                      classNames(
                        active ? "bg-gray-100" : "bg-white",
                        selected ? "font-semibold" : "",
                        "cursor-default select-none relative py-2 px-3"
                      )
                    }
                    value={reaction}
                  >
                    {({ selected }) => (
                      <div className="flex items-center">
                        <div
                          className={classNames(
                            reaction.bgColor,
                            "w-8 h-8 rounded-full flex items-center justify-center"
                          )}
                        >
                          <reaction.icon
                            className={classNames(
                              reaction.iconColor,
                              "flex-shrink-0 h-5 w-5"
                            )}
                            aria-hidden="true"
                          />
                        </div>
                        <span
                          className={classNames(
                            selected ? "font-extrabold" : "",
                            "ml-3 block font-medium truncate"
                          )}
                        >
                          {reaction.name}
                        </span>
                      </div>
                    )}
                  </Listbox.Option>
                ))}
              </Listbox.Options>
            </Transition>
          </div>
        </>
      )}
    </Listbox>
  );
}
