import {useAuth} from '@/contexts/AuthContext';
import {useParams} from '@/contexts/ParamsContext';
import {useUser} from '@/contexts/UserContext';
import {useUserById} from '@/contexts/UsersContext';
import * as queries from '@/graphql/queries';
import * as subscriptions from '@/graphql/subscriptions';
import {useQuery, useSubscription} from '@apollo/client';
import {createContext, useContext, useEffect, useState} from 'react';

export const DirectMessagesContext = createContext({
  value: null,
  loading: true,
});

export function DirectMessagesProvider({children}) {
  const {user} = useAuth();
  const {workspaceId} = useParams();

  const [directs, setDirects] = useState([]);

  const {data, loading} = useQuery(queries.LIST_DIRECTS, {
    variables: {
      workspaceId,
    },
    skip: !workspaceId,
    fetchPolicy: 'cache-and-network',
  });
  const {data: dataPush} = useSubscription(subscriptions.DIRECT, {
    variables: {
      workspaceId,
    },
    skip: !workspaceId,
  });

  useEffect(() => {
    if (data) setDirects(data.listDirects);
  }, [data]);

  useEffect(() => {
    if (dataPush) {
      setDirects([
        ...directs.filter(
          item => item.objectId !== dataPush.onUpdateDirect.objectId,
        ),
        dataPush.onUpdateDirect,
      ]);
    }
  }, [dataPush]);

  return (
    <DirectMessagesContext.Provider
      value={{
        value: directs?.filter(item => item.active.includes(user?.uid)),
        loading,
      }}>
      {children}
    </DirectMessagesContext.Provider>
  );
}

export function useDirectMessages() {
  const {value, loading} = useContext(DirectMessagesContext);
  return {value, loading};
}

export function useDirectMessageById(id) {
  const {value, loading} = useContext(DirectMessagesContext);
  return {value: value?.find(p => p.objectId === id), loading};
}

export function useDirectRecipient(id) {
  const {value: direct} = useDirectMessageById(id);
  const {user} = useUser();

  const isMe =
    direct?.members?.length === 1 && direct?.members[0] === user?.uid;
  const otherUserId = isMe
    ? user?.uid
    : direct?.members.find(m => m !== user?.uid);

  const {value: recipient} = useUserById(otherUserId);

  return {value: recipient, isMe};
}
