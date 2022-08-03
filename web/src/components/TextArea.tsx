import { useEffect, useRef } from "react";

export default function TextArea({
  label,
  name,
  autoComplete,
  placeholder,
  infos,
  value,
  handleChange,
  focus = false,
}: {
  label?: string;
  name: string;
  placeholder: string;
  autoComplete?: string;
  infos?: string;
  value: string;
  handleChange?: any;
  focus?: boolean;
}) {
  const inputRef = useRef<any>(null);
  useEffect(() => {
    if (focus) inputRef?.current?.focus();
  }, []);
  return (
    <div className="w-full">
      {label && (
        <label
          htmlFor="first-name"
          className="block text-sm font-bold th-color-for"
        >
          {label}
        </label>
      )}
      <textarea
        value={value}
        name={name}
        id={name}
        ref={inputRef}
        onChange={handleChange}
        placeholder={placeholder}
        autoComplete={autoComplete}
        className="th-bg-bg th-border-brblack th-color-for mt-2 focus:ring-indigo-400 focus:border-indigo-500 block w-full shadow-sm text-sm rounded-md h-28 resize-none"
      />
      <div className="text-xs font-normal mt-2 th-color-for">{infos}</div>
    </div>
  );
}
