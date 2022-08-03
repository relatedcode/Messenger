import classNames from "utils/classNames";

export default function ModalButton({
  text,
  isSubmitting,
  onClick,
  type = "submit",
  isDelete = false,
  className = "w-full inline-flex sm:ml-3 justify-center items-center py-2 px-4 border border-transparent text-base font-bold rounded text-white focus:outline-none focus:ring-4 focus:ring-blue-200 sm:w-auto sm:text-sm disabled:opacity-50",
  disabled = false,
  ref,
}: {
  text: string;
  isSubmitting?: boolean;
  onClick?: any;
  type?: any;
  isDelete?: boolean;
  className?: string;
  disabled?: boolean;
  ref?: any;
}) {
  return (
    <button
      type={type}
      disabled={isSubmitting || disabled}
      className={classNames(
        !isDelete
          ? "th-bg-blue th-color-brwhite"
          : "th-bg-red th-color-brwhite",
        className
      )}
      onClick={onClick}
      ref={ref}
    >
      {isSubmitting && (
        <svg
          className="animate-spin -ml-1 mr-2 h-4 w-4 th-color-brwhite"
          xmlns="http://www.w3.org/2000/svg"
          fill="none"
          viewBox="0 0 24 24"
        >
          <circle
            className="opacity-25"
            cx="12"
            cy="12"
            r="10"
            stroke="currentColor"
            strokeWidth="4"
          />
          <path
            className="opacity-75"
            fill="currentColor"
            d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"
          />
        </svg>
      )}
      {text}
    </button>
  );
}
