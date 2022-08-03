import {useAuth} from '@/contexts/AuthContext';
import {useParams} from '@/contexts/ParamsContext';
import * as queries from '@/graphql/queries';
import * as subscriptions from '@/graphql/subscriptions';
import {useQuery, useSubscription} from '@apollo/client';
import {createContext, useContext, useEffect, useState} from 'react';

function compareName(a, b) {
  if (a.name < b.name) {
    return -1;
  }
  if (a.name > b.name) {
    return 1;
  }
  return 0;
}

export const ChannelsContext = createContext({
  value: null,
  loading: true,
});

export function ChannelsProvider({children}) {
  const {workspaceId} = useParams();
  const [channels, setChannels] = useState([]);

  const {data, loading} = useQuery(queries.LIST_CHANNELS, {
    variables: {
      workspaceId,
    },
    skip: !workspaceId,
    fetchPolicy: 'cache-and-network',
  });
  const {data: dataPush} = useSubscription(subscriptions.CHANNEL, {
    variables: {
      workspaceId,
    },
    skip: !workspaceId,
  });

  useEffect(() => {
    if (data) setChannels(data.listChannels);
  }, [data]);

  useEffect(() => {
    if (dataPush) {
      setChannels([
        ...channels.filter(
          item => item.objectId !== dataPush.onUpdateChannel.objectId,
        ),
        dataPush.onUpdateChannel,
      ]);
    }
  }, [dataPush]);

  return (
    <ChannelsContext.Provider
      value={{
        value: [...channels].sort(compareName),
        loading,
      }}>
      {children}
    </ChannelsContext.Provider>
  );
}

export function useChannels() {
  const {user} = useAuth();
  const {value} = useContext(ChannelsContext);

  return {
    value: value?.filter(
      c =>
        c.members.includes(user?.uid) &&
        c.isArchived === false &&
        c.isDeleted === false,
    ),
  };
}

export function useAllChannels() {
  const {value} = useContext(ChannelsContext);

  return {
    value: value?.filter(c => c.isDeleted === false),
  };
}

export function useChannelById(id) {
  const {value} = useContext(ChannelsContext);
  return {value: value?.find(p => p.objectId === id)};
}
