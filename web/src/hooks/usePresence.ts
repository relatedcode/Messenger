import { useQuery, useSubscription } from "@apollo/client";
import * as queries from "graphql/queries";
import * as subscriptions from "graphql/subscriptions";
import useAuth from "hooks/useAuth";
import { useEffect, useState } from "react";
import timeDiff from "utils/time-diff";

export function usePresenceByUserId(id?: string | null) {
  const { user } = useAuth();

  const isMe = user?.uid === id;

  const [currentTime, setCurrentTime] = useState(Date.now());

  useEffect(() => {
    const interval = setInterval(() => {
      setCurrentTime(Date.now());
    }, 3000);
    return () => clearInterval(interval);
  }, []);

  const [currentPresence, setCurrentPresence] = useState<any>(null);

  const { data, loading } = useQuery(queries.GET_PRESENCE, {
    variables: {
      objectId: id,
    },
    skip: !id,
  });
  const { data: dataPush } = useSubscription(subscriptions.PRESENCE, {
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
