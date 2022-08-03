import { useEffect, useRef } from "react";

export default function TextField({
  label,
  name,
  autoComplete,
  placeholder,
  infos,
  value,
  handleChange,
  type = "text",
  required = false,
  focus = false,
  disabled = false,
}: {
  label?: string;
  name: string;
  placeholder: string;
  autoComplete?: string;
  infos?: string;
  value?: string;
  handleChange?: any;
  type?: string;
  required?: boolean;
  focus?: boolean;
  disabled?: boolean;
}) {
  const inputRef = useRef(null);
  useEffect(() => {
    // @ts-ignore
    if (focus) inputRef?.current.focus();
  }, []);
  return (
    <div className="w-full">
      {label && (
        <label htmlFor={name} className="block text-sm font-bold th-color-for">
          {label}
        </label>
      )}
      <input
        type={type}
        name={name}
        id={name}
        required={required}
        placeholder={placeholder}
        autoComplete={autoComplete}
        value={value}
        onChange={handleChange}
        ref={inputRef}
        disabled={disabled}
        className="th-bg-bg th-border-brblack th-color-for th-border- mt-2 focus:ring-indigo-400 focus:border-indigo-500 block w-full shadow-sm text-base rounded disabled:opacity-50"
      />
      <div className="text-xs font-normal mt-2 th-color-for">{infos}</div>
    </div>
  );
}
