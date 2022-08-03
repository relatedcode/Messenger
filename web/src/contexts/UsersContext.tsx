import { useUsersByWorkspace } from "hooks/useUsers";
import { createContext } from "react";

export const UsersContext = createContext({
  value: null as any,
  loading: true,
});

export function UsersProvider({ children }: { children: React.ReactNode }) {
  const users = useUsersByWorkspace();
  return (
    <UsersContext.Provider value={users}>{children}</UsersContext.Provider>
  );
}
