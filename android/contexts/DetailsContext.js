import {useAuth} from '@/contexts/AuthContext';
import {useParams} from '@/contexts/ParamsContext';
import * as queries from '@/graphql/queries';
import * as subscriptions from '@/graphql/subscriptions';
import {useQuery, useSubscription} from '@apollo/client';
import {createContext, useContext, useEffect, useState} from 'react';

export const DetailsContext = createContext({
  value: null,
  loading: true,
});

export function DetailsProvider({children}) {
  const {user} = useAuth();
  const {workspaceId} = useParams();

  const [details, setDetails] = useState([]);

  const {data, loading} = useQuery(queries.LIST_DETAILS, {
    variables: {
      workspaceId,
      userId: user?.uid,
    },
    skip: !user || !workspaceId,
    fetchPolicy: 'cache-and-network',
  });
  const {data: dataPush} = useSubscription(subscriptions.DETAIL, {
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
          item => item.objectId !== dataPush.onUpdateDetail.objectId,
        ),
        dataPush.onUpdateDetail,
      ]);
    }
  }, [dataPush]);

  return (
    <DetailsContext.Provider
      value={{
        value: details,
        loading,
      }}>
      {children}
    </DetailsContext.Provider>
  );
}

export function useDetailByChat(id) {
  const {value} = useContext(DetailsContext);
  return {value: value?.find(p => p.chatId === id)};
}
