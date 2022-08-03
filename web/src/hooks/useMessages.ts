import { useQuery, useSubscription } from "@apollo/client";
import * as queries from "graphql/queries";
import * as subscriptions from "graphql/subscriptions";
import { useEffect, useState } from "react";

function compareDate(a: any, b: any) {
  return new Date(b.createdAt).getTime() - new Date(a.createdAt).getTime();
}

export function useMessagesByChat(
  id: any,
  page = 1 // eslint-disable-line
) {
  const [messages, setMessages] = useState<any[]>([]);
  const [nextToken, setNextToken] = useState<any>(null);

  const { data, loading } = useQuery(queries.LIST_MESSAGES, {
    variables: {
      chatId: id,
      // limit: MESSAGES_PER_PAGE * page,
      ...(nextToken &&
        messages?.length &&
        id === messages[0]?.chatId && { nextToken }),
    },
    skip: !id || !page,
    fetchPolicy: "cache-and-network",
  });
  const { data: dataPush } = useSubscription(subscriptions.MESSAGE, {
    variables: {
      chatId: id,
    },
    skip: !id,
  });

  useEffect(() => {
    if (page > 1) setNextToken(messages[messages.length - 1].createdAt);
  }, [page]);

  useEffect(() => {
    setNextToken(null);
  }, [id]);

  useEffect(() => {
    if (data) {
      if (nextToken) {
        setMessages([...messages, ...data.listMessages]);
      } else {
        setMessages(data.listMessages);
      }
    }
  }, [data]);

  useEffect(() => {
    if (dataPush) {
      setMessages([
        ...messages.filter(
          (item) => item.objectId !== dataPush.onUpdateMessage.objectId
        ),
        dataPush.onUpdateMessage,
      ]);
    }
  }, [dataPush]);

  return {
    value: [...messages].filter((m) => !m.isDeleted).sort(compareDate),
    loading,
  };
}
