import EditChannelItemsDialog from "components/dashboard/channels/EditChannelItemsDialog";
import { useTheme } from "contexts/ThemeContext";
import React, { useState } from "react";
import classNames from "utils/classNames";

export default function EditChannelItems({
  value,
  name,
  color,
  editable,
  textArea,
  placeholder = `Add a ${name}`,
  title = `Edit ${name}`,
  icon,
  displayDetails = true,
  onClick,
  field,
}: {
  name: string;
  value?: string;
  color?: string;
  editable?: string;
  textArea?: boolean;
  placeholder?: string;
  title?: string;
  field?: string;
  icon?: React.ReactNode;
  displayDetails?: boolean;
  onClick?: any;
}) {
  const { themeColors } = useTheme();
  const [open, setOpen] = useState(false);
  return (
    <>
      <div
        role="button"
        tabIndex={0}
        onClick={() => (onClick ? onClick() : setOpen(true))}
        className="th-border-selbg flex focus:outline-none flex-col space-y-1 first:rounded-t-xl p-4 border-b cursor-pointer last:border-0 last:rounded-b-xl"
      >
        <span
          className={classNames(
            color || "",
            "font-bold text-sm flex items-center"
          )}
          style={{
            color: color || themeColors?.foreground,
          }}
        >
          {icon}
          {name}
        </span>
        {displayDetails && (
          <span className="text-sm opacity-70 th-color-for max-w-full truncate">
            {value || placeholder}
          </span>
        )}
      </div>
      {editable && (
        <EditChannelItemsDialog
          open={open}
          setOpen={setOpen}
          title={title}
          placeholder={placeholder}
          infos={editable}
          textArea={textArea}
          field={field}
        />
      )}
    </>
  );
}
