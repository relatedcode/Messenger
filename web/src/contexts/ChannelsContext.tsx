import { useChannelsByWorkspace } from "hooks/useChannels";
import { createContext } from "react";

export const ChannelsContext = createContext({
  value: null as any,
  loading: true,
});

export function ChannelsProvider({ children }: { children: React.ReactNode }) {
  const channelsData = useChannelsByWorkspace();
  return (
    <ChannelsContext.Provider value={channelsData}>
      {children}
    </ChannelsContext.Provider>
  );
}
