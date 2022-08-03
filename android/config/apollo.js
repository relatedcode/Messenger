import {env} from '@/config/env';
import {getIdToken} from '@/lib/auth';
import {ApolloClient, HttpLink, InMemoryCache, split} from '@apollo/client';
import {setContext} from '@apollo/client/link/context';
import {GraphQLWsLink} from '@apollo/client/link/subscriptions';
import {getMainDefinition} from '@apollo/client/utilities';
import {createClient} from 'graphql-ws';

const httpLink = new HttpLink({
  uri: `${env.GQL_SERVER}/graphql`,
});

const wsLink = new GraphQLWsLink(
  createClient({
    url: `${env.GQL_SERVER.replace('http', 'ws')}/graphql`,
    connectionParams: async () => {
      const token = await getIdToken();
      if (!token) {
        return {};
      }
      return {
        headers: {
          Authorization: `Bearer ${token}`,
        },
      };
    },
  }),
);

const authLink = setContext(async (_, {headers}) => {
  // get the authentication token from local storage if it exists
  const token = await getIdToken();
  // return the headers to the context so httpLink can read them
  return {
    headers: {
      ...headers,
      authorization: token ? `Bearer ${token}` : '',
    },
  };
});

const splitLink = split(
  ({query}) => {
    const definition = getMainDefinition(query);
    return (
      definition.kind === 'OperationDefinition' &&
      definition.operation === 'subscription'
    );
  },
  wsLink,
  httpLink,
);

export const apolloClient = new ApolloClient({
  link: authLink.concat(splitLink),
  cache: new InMemoryCache({addTypename: false}),
});
