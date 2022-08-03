import {useAuth} from '@/contexts/AuthContext';
import {useParams} from '@/contexts/ParamsContext';
import * as queries from '@/graphql/queries';
import * as subscriptions from '@/graphql/subscriptions';
import {useQuery, useSubscription} from '@apollo/client';
import {createContext, useContext, useEffect, useState} from 'react';

function compareFullName(a, b) {
  if (a.fullName < b.fullName) {
    return -1;
  }
  if (a.fullName > b.fullName) {
    return 1;
  }
  return 0;
}

export const UsersContext = createContext({
  value: null,
  loading: true,
});

export function UsersProvider({children}) {
  const {user} = useAuth();
  const {workspaceId} = useParams();

  const [users, setUsers] = useState([]);

  const {data, loading} = useQuery(queries.LIST_USERS, {
    skip: !user,
    fetchPolicy: 'cache-and-network',
  });
  const {data: dataPush} = useSubscription(subscriptions.USER, {
    skip: !user,
  });

  useEffect(() => {
    if (data) setUsers(data.listUsers);
  }, [data]);

  useEffect(() => {
    if (dataPush) {
      setUsers([
        ...users.filter(
          item => item.objectId !== dataPush.onUpdateUser.objectId,
        ),
        dataPush.onUpdateUser,
      ]);
    }
  }, [dataPush]);

  return (
    <UsersContext.Provider
      value={{
        value: users
          ?.filter(u => u.workspaces.includes(workspaceId))
          ?.sort(compareFullName),
        loading,
      }}>
      {children}
    </UsersContext.Provider>
  );
}

export function useUsers() {
  const {value, loading} = useContext(UsersContext);
  return {
    value,
    loading,
  };
}

export function useUserById(id) {
  const {value, loading} = useContext(UsersContext);
  return {
    value: value?.find(p => p.objectId === id),
    loading,
  };
}
