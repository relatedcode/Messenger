import Style from "components/Style";
import { useTheme } from "contexts/ThemeContext";
import { useForceUpdate } from "lib/hooks";
import { useEffect, useRef } from "react";
import ReactQuill from "react-quill";
import "react-quill/dist/quill.bubble.css";
import classNames from "utils/classNames";
import hexToRgbA from "utils/hexToRgbA";

export default function Reader({
  text,
  isEdited,
}: {
  text: string;
  isEdited: boolean;
}) {
  const forceUpdate = useForceUpdate();
  const { themeColors } = useTheme();
  const editorRef = useRef<any>(null);
  const editor = editorRef?.current?.getEditor();
  const unprivilegedEditor = editorRef?.current?.makeUnprivilegedEditor(editor);

  const onlyText = unprivilegedEditor?.getText();

  const endWithPTag = text.substr(text?.length - 4) === "</p>";

  const position = endWithPTag ? text?.length - 4 : text?.length;

  const display =
    text && isEdited && position
      ? !endWithPTag
        ? `${text}<p><span class="ql-size-small" style="color: rgb(136, 136, 136);"> (edited)</span></p>`
        : [
            text.slice(0, position),
            '<span class="ql-size-small" style="color: rgb(136, 136, 136);"> (edited)</span>',
            text.slice(position),
          ].join("")
      : text;

  useEffect(() => {
    forceUpdate();
  }, [text, display]);

  return (
    <>
      <Style
        css={`
          .reader .ql-editor {
            color: ${themeColors?.foreground};
            font-weight: ${themeColors?.messageFontWeight === "light"
              ? "300"
              : "400"};
          }

          /* Code editor */
          .ql-bubble .ql-editor pre.ql-syntax {
            background-color: ${themeColors?.brightBlack};
            color: ${themeColors?.brightWhite};
            border-color: ${hexToRgbA(themeColors?.background!, "0.2")};
            border-width: 1px;
          }
          .ql-bubble .ql-editor code,
          .ql-bubble .ql-editor pre {
            background-color: ${themeColors?.brightBlack};
            color: ${themeColors?.brightWhite};
            border-color: ${hexToRgbA(themeColors?.background!, "0.2")};
            border-width: 1px;
          }

          /* Link */
          .ql-bubble .ql-editor a {
            color: ${themeColors?.blue};
            text-decoration: none;
          }
          .ql-bubble .ql-editor a:hover {
            text-decoration: underline;
          }
        `}
      />
      <ReactQuill
        value={display}
        theme="bubble"
        readOnly
        ref={editorRef}
        className={classNames(
          /[!"#$%&'()*+,-./:;<=>?@[\]^_`{|}~A-Za-z0-9]/g.test(
            onlyText?.replace(" (edited)", "")
          )
            ? ""
            : "editor-has-only-emoji",
          "reader"
        )}
      />
    </>
  );
}
