import { useQuery, useSubscription } from "@apollo/client";
import { DirectMessagesContext } from "contexts/DirectMessagesContext";
import * as queries from "graphql/queries";
import * as subscriptions from "graphql/subscriptions";
import useAuth from "hooks/useAuth";
import { useContext, useEffect, useState } from "react";
import { useLocation } from "react-router-dom";

export function useDirectMessagesByWorkspace() {
  const { user } = useAuth();
  const location = useLocation();
  const workspaceId = location.pathname
    .split("/dashboard/workspaces/")[1]
    ?.split("/")[0];

  const [directs, setDirects] = useState<any[]>([]);

  const { data, loading } = useQuery(queries.LIST_DIRECTS, {
    variables: {
      workspaceId,
    },
    skip: !workspaceId,
    fetchPolicy: "cache-and-network",
  });
  const { data: dataPush } = useSubscription(subscriptions.DIRECT, {
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
          (item) => item.objectId !== dataPush.onUpdateDirect.objectId
        ),
        dataPush.onUpdateDirect,
      ]);
    }
  }, [dataPush]);

  return {
    value: directs?.filter((item: any) => item.active.includes(user?.uid)),
    loading,
  };
}

export function useDirectMessageById(id: any) {
  const { value } = useContext(DirectMessagesContext);
  return { value: value?.find((p: any) => p.objectId === id) };
}
