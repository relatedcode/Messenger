import { useDetailsByWorkspace } from "hooks/useDetails";
import { createContext } from "react";

export const DetailsContext = createContext({
  value: null as any,
  loading: true,
});

export function DetailsProvider({ children }: { children: React.ReactNode }) {
  const details = useDetailsByWorkspace();
  return (
    <DetailsContext.Provider value={details}>
      {children}
    </DetailsContext.Provider>
  );
}
