import React, {createContext, useState} from 'react';

export const ModalContext = createContext({
  openPreferences: false,
  setOpenPreferences: () => {},

  openProfile: false,
  setOpenProfile: () => {},

  openSearch: false,
  setOpenSearch: () => {},

  openChannelDetails: false,
  setOpenChannelDetails: () => {},

  openDirectDetails: false,
  setOpenDirectDetails: () => {},

  openChannelBrowser: false,
  setOpenChannelBrowser: () => {},

  openMemberBrowser: false,
  setOpenMemberBrowser: () => {},

  openWorkspaceBrowser: false,
  setOpenWorkspaceBrowser: () => {},

  openStickers: false,
  setOpenStickers: () => {},
});

export function useModal() {
  return React.useContext(ModalContext);
}

export function ModalProvider({children}) {
  const [openPreferences, setOpenPreferences] = useState(false);
  const [openProfile, setOpenProfile] = useState(false);
  const [openSearch, setOpenSearch] = useState(false);
  const [openChannelDetails, setOpenChannelDetails] = useState(false);
  const [openDirectDetails, setOpenDirectDetails] = useState(false);
  const [openChannelBrowser, setOpenChannelBrowser] = useState(false);
  const [openMemberBrowser, setOpenMemberBrowser] = useState(false);
  const [openWorkspaceBrowser, setOpenWorkspaceBrowser] = useState(false);
  const [openStickers, setOpenStickers] = useState(false);

  return (
    <ModalContext.Provider
      value={{
        openPreferences,
        setOpenPreferences,

        openProfile,
        setOpenProfile,

        openSearch,
        setOpenSearch,

        openChannelDetails,
        setOpenChannelDetails,

        openDirectDetails,
        setOpenDirectDetails,

        openChannelBrowser,
        setOpenChannelBrowser,

        openMemberBrowser,
        setOpenMemberBrowser,

        openWorkspaceBrowser,
        setOpenWorkspaceBrowser,

        openStickers,
        setOpenStickers,
      }}>
      {children}
    </ModalContext.Provider>
  );
}
