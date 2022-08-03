import { useQuery, useSubscription } from "@apollo/client";
import { ChannelsContext } from "contexts/ChannelsContext";
import * as queries from "graphql/queries";
import * as subscriptions from "graphql/subscriptions";
import useAuth from "hooks/useAuth";
import { useContext, useEffect, useState } from "react";
import { useLocation } from "react-router-dom";

function compareName(a: any, b: any) {
  if (a.name < b.name) {
    return -1;
  }
  if (a.name > b.name) {
    return 1;
  }
  return 0;
}

export function useChannelsByWorkspace() {
  const location = useLocation();
  const workspaceId = location.pathname
    .split("/dashboard/workspaces/")[1]
    ?.split("/")[0];

  const [channels, setChannels] = useState<any[]>([]);

  const { data, loading } = useQuery(queries.LIST_CHANNELS, {
    variables: {
      workspaceId,
    },
    skip: !workspaceId,
    fetchPolicy: "cache-and-network",
  });
  const { data: dataPush } = useSubscription(subscriptions.CHANNEL, {
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
          (item) => item.objectId !== dataPush.onUpdateChannel.objectId
        ),
        dataPush.onUpdateChannel,
      ]);
    }
  }, [dataPush]);

  return {
    value: [...channels]
      .sort(compareName)
      ?.filter((c) => c.isDeleted === false),
    loading,
  };
}

export function useChannels() {
  const { user }: any = useAuth();
  const { value } = useContext(ChannelsContext);

  return {
    value: value?.filter(
      (c: any) =>
        c.members.includes(user?.uid) &&
        c.isArchived === false &&
        c.isDeleted === false
    ),
  };
}

export function useChannelById(id: any) {
  const { value } = useContext(ChannelsContext);
  return { value: value?.find((p: any) => p.objectId === id) };
}
