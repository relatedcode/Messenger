import { getFileURL } from "gqlite-lib/dist/client/storage";

export function getHref(url: string) {
  if (!url) return undefined;
  else return getFileURL(url);
}
