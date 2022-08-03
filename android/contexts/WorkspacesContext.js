import {useUser} from '@/contexts/UserContext';
import * as queries from '@/graphql/queries';
import * as subscriptions from '@/graphql/subscriptions';
import {useQuery, useSubscription} from '@apollo/client';
import {createContext, useContext, useEffect, useState} from 'react';

export const WorkspacesContext = createContext({
  value: null,
  loading: true,
});

export function WorkspacesProvider({children}) {
  const {user} = useUser();
  const [workspaces, setWorkspaces] = useState([]);

  const {data, loading} = useQuery(queries.LIST_WORKSPACES, {
    skip: !user,
    fetchPolicy: 'cache-and-network',
  });
  const {data: dataPush} = useSubscription(subscriptions.WORKSPACE, {
    skip: !user,
  });

  useEffect(() => {
    if (data) setWorkspaces(data.listWorkspaces);
  }, [data]);

  useEffect(() => {
    if (dataPush) {
      setWorkspaces([
        ...workspaces.filter(
          item => item.objectId !== dataPush.onUpdateWorkspace.objectId,
        ),
        dataPush.onUpdateWorkspace,
      ]);
    }
  }, [dataPush]);

  return (
    <WorkspacesContext.Provider
      value={{
        value: workspaces?.filter(w => w.isDeleted === false),
        loading,
      }}>
      {children}
    </WorkspacesContext.Provider>
  );
}

export function useWorkspaceById(id) {
  const {value} = useWorspaces();
  return {value: value?.find(p => p.objectId === id)};
}

export function useAllWorkspaces() {
  const {value, loading} = useWorspaces();

  return {
    value,
    loading,
  };
}

export function useMyWorkspaces() {
  const {user} = useUser();
  const {value, loading} = useWorspaces();

  return {
    value: value
      ?.filter(w => w.isDeleted === false && w.members.includes(user?.uid))
      ?.sort(
        (a, b) =>
          new Date(b.createdAt).getTime() - new Date(a.createdAt).getTime(),
      ),
    loading,
  };
}

export function useWorspaces() {
  return useContext(WorkspacesContext);
}
