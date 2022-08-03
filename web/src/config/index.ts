// Your app name
export const APP_NAME = "Related:Chat";

// The default theme of the web app
export const DEFAULT_THEME = "theme01";

// The number of files in the `public/stickers` folder
export const STICKERS_COUNT = 78;

// The number of files in the `public/themes` folder
export const THEMES_COUNT = 60;

// The max number of characters a message can have
export const MESSAGE_MAX_CHARACTERS = 12000;

// The number of messages per "page" (pagination)
export const MESSAGES_PER_PAGE = 30;

// Use email fast sign in (DEVELOPMENT ONLY)
export const FAKE_EMAIL = true;

export const getAPIUrl = () => {
  return typeof window !== "undefined"
    ? process.env.REACT_APP_API_URL ||
        `${window?.location.protocol}//${window?.location.hostname}:4001`
    : "";
};

export const getGQLServerUrl = () => {
  return typeof window !== "undefined"
    ? process.env.REACT_APP_GQL_SERVER_URL ||
        `${window?.location.protocol}//${window?.location.hostname}:4000`
    : "";
};
