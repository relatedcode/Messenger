import { useQuery, useSubscription } from "@apollo/client";
import { DetailsContext } from "contexts/DetailsContext";
import * as queries from "graphql/queries";
import * as subscriptions from "graphql/subscriptions";
import useAuth from "hooks/useAuth";
import { useContext, useEffect, useState } from "react";
import { useLocation } from "react-router-dom";

export function useDetailsByWorkspace() {
  const { user } = useAuth();
  const location = useLocation();
  const workspaceId = location.pathname
    .split("/dashboard/workspaces/")[1]
    ?.split("/")[0];

  const [details, setDetails] = useState<any[]>([]);

  const { data, loading } = useQuery(queries.LIST_DETAILS, {
    variables: {
      workspaceId,
      userId: user?.uid,
    },
    skip: !user || !workspaceId,
    fetchPolicy: "cache-and-network",
  });
  const { data: dataPush } = useSubscription(subscriptions.DETAIL, {
    variables: {
      workspaceId,
      userId: user?.uid,
    },
    skip: !user || !workspaceId,
  });

  useEffect(() => {
    if (data) setDetails(data.listDetails);
  }, [data]);

  useEffect(() => {
    if (dataPush) {
      setDetails([
        ...details.filter(
          (item) => item.objectId !== dataPush.onUpdateDetail.objectId
        ),
        dataPush.onUpdateDetail,
      ]);
    }
  }, [dataPush]);

  return {
    value: details,
    loading,
  };
}

export function useDetailByChat(id: any) {
  const { value } = useContext(DetailsContext);
  return { value: value?.find((p: any) => p.chatId === id) };
}
