import {useAuth} from '@/contexts/AuthContext';
import * as queries from '@/graphql/queries';
import * as subscriptions from '@/graphql/subscriptions';
import {useQuery, useSubscription} from '@apollo/client';
import {useEffect, useState} from 'react';

export default function timeDiff(date1, date2) {
  return date1 ? Math.abs(date1.getTime() - date2) / 1000 : false;
}

export function usePresenceByUserId(id) {
  const {user} = useAuth();

  const isMe = user?.uid === id;

  const [currentTime, setCurrentTime] = useState(Date.now());

  useEffect(() => {
    const interval = setInterval(() => {
      setCurrentTime(Date.now());
    }, 3000);
    return () => clearInterval(interval);
  }, []);

  const [currentPresence, setCurrentPresence] = useState(null);

  const {data, loading} = useQuery(queries.GET_PRESENCE, {
    variables: {
      objectId: id,
    },
    skip: !id,
    fetchPolicy: 'cache-and-network',
  });
  const {data: dataPush} = useSubscription(subscriptions.PRESENCE, {
    variables: {
      objectId: id,
    },
    skip: !id,
  });

  useEffect(() => {
    if (data) setCurrentPresence(data.getPresence);
  }, [data]);

  useEffect(() => {
    if (dataPush) setCurrentPresence(dataPush.onUpdatePresence);
  }, [dataPush]);

  let isPresent = false;
  if (isMe) isPresent = true;
  else if (currentPresence?.lastPresence)
    isPresent =
      timeDiff(new Date(currentPresence.lastPresence), currentTime) < 35;

  return {
    isPresent,
    loading,
  };
}
