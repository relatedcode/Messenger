import { useQuery, useSubscription } from "@apollo/client";
import { useUser } from "contexts/UserContext";
import * as queries from "graphql/queries";
import * as subscriptions from "graphql/subscriptions";
import React, { createContext, useContext, useEffect, useState } from "react";

export const WorkspacesContext = createContext({
  value: null as any,
  loading: true,
});

export function useMyWorkspaces() {
  const { user } = useUser();
  const { value, loading } = useContext(WorkspacesContext);

  return {
    value: value
      ?.filter(
        (w: any) => w.isDeleted === false && w.members.includes(user?.uid)
      )
      ?.sort(
        (a: any, b: any) =>
          new Date(b.createdAt).getTime() - new Date(a.createdAt).getTime()
      ),
    loading,
  };
}

export function WorkspacesProvider({
  children,
}: {
  children: React.ReactNode;
}) {
  const { user } = useUser();
  const [workspaces, setWorkspaces] = useState<any[]>([]);

  const { data, loading } = useQuery(queries.LIST_WORKSPACES, {
    skip: !user,
    fetchPolicy: "cache-and-network",
  });
  const { data: dataPush } = useSubscription(subscriptions.WORKSPACE, {
    skip: !user,
  });

  useEffect(() => {
    if (data) setWorkspaces(data.listWorkspaces);
  }, [data]);

  useEffect(() => {
    if (dataPush) {
      setWorkspaces([
        ...workspaces.filter(
          (item) => item.objectId !== dataPush.onUpdateWorkspace.objectId
        ),
        dataPush.onUpdateWorkspace,
      ]);
    }
  }, [dataPush]);

  return (
    <WorkspacesContext.Provider
      value={{
        value: workspaces?.filter((w: any) => w.isDeleted === false),
        loading,
      }}
    >
      {children}
    </WorkspacesContext.Provider>
  );
}

export function useWorkspaceById(id: any) {
  const { value } = useContext(WorkspacesContext);
  return { value: value?.find((p: any) => p.objectId === id) };
}
