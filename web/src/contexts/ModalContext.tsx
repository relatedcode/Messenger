import { createContext, useContext, useState } from "react";

export const ModalContext = createContext({
  openCreateWorkspace: false,
  setOpenCreateWorkspace: null as any,

  openCreateChannel: false,
  setOpenCreateChannel: null as any,

  openEditPassword: false,
  setOpenEditPassword: null as any,

  openInviteTeammates: false,
  setOpenInviteTeammates: null as any,

  openPreferences: false,
  setOpenPreferences: null as any,

  openCreateMessage: false,
  setOpenCreateMessage: null as any,
  createMessageSection: "",
  setCreateMessageSection: null as any,

  openWorkspaceSettings: false,
  setOpenWorkspaceSettings: null as any,
  workspaceSettingsSection: "",
  setWorkspaceSettingsSection: null as any,
});

export function ModalProvider({ children }: { children: React.ReactNode }) {
  const [openCreateWorkspace, setOpenCreateWorkspace] = useState(false);
  const [openCreateChannel, setOpenCreateChannel] = useState(false);
  const [openEditPassword, setOpenEditPassword] = useState(false);
  const [openInviteTeammates, setOpenInviteTeammates] = useState(false);
  const [openPreferences, setOpenPreferences] = useState(false);

  const [openCreateMessage, setOpenCreateMessage] = useState(false);
  const [createMessageSection, setCreateMessageSection] = useState<
    "channels" | "members"
  >("channels");

  const [openWorkspaceSettings, setOpenWorkspaceSettings] = useState(false);
  const [workspaceSettingsSection, setWorkspaceSettingsSection] = useState<
    "members" | "settings"
  >("members");

  return (
    <ModalContext.Provider
      value={{
        openCreateWorkspace,
        setOpenCreateWorkspace,

        openCreateChannel,
        setOpenCreateChannel,

        openEditPassword,
        setOpenEditPassword,

        openInviteTeammates,
        setOpenInviteTeammates,

        openPreferences,
        setOpenPreferences,

        openCreateMessage,
        setOpenCreateMessage,
        createMessageSection,
        setCreateMessageSection,

        openWorkspaceSettings,
        setOpenWorkspaceSettings,
        workspaceSettingsSection,
        setWorkspaceSettingsSection,
      }}
    >
      {children}
    </ModalContext.Provider>
  );
}

export function useModal() {
  return useContext(ModalContext);
}
