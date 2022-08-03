import { useDirectMessagesByWorkspace } from "hooks/useDirects";
import { createContext } from "react";

export const DirectMessagesContext = createContext({
  value: null as any,
  loading: true,
});

export function DirectMessagesProvider({
  children,
}: {
  children: React.ReactNode;
}) {
  const dmData = useDirectMessagesByWorkspace();
  return (
    <DirectMessagesContext.Provider value={dmData}>
      {children}
    </DirectMessagesContext.Provider>
  );
}
