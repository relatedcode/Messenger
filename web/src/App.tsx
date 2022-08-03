import {
  ApolloClient,
  ApolloProvider,
  HttpLink,
  InMemoryCache,
  split,
} from "@apollo/client";
import { setContext } from "@apollo/client/link/context";
import { GraphQLWsLink } from "@apollo/client/link/subscriptions";
import { getMainDefinition } from "@apollo/client/utilities";
import WideScreen from "components/WideScreen";
import { getGQLServerUrl } from "config";
import { AuthProvider } from "contexts/AuthContext";
import { ChannelsProvider } from "contexts/ChannelsContext";
import { DetailsProvider } from "contexts/DetailsContext";
import { DirectMessagesProvider } from "contexts/DirectMessagesContext";
import { ModalProvider } from "contexts/ModalContext";
import { ReactionsProvider } from "contexts/ReactionsContext";
import { ThemeProvider } from "contexts/ThemeContext";
import { UserProvider } from "contexts/UserContext";
import { UsersProvider } from "contexts/UsersContext";
import { getIdToken } from "gqlite-lib/dist/client/auth";
import { setUrl } from "gqlite-lib/dist/client/utils";
import { createClient } from "graphql-ws";
import { WorkspacesProvider } from "hooks/useWorkspaces";
import { useEffect, useState } from "react";
import { Helmet } from "react-helmet-async";
import { Toaster } from "react-hot-toast";
import { useRoutes } from "react-router-dom";
import routes from "routes";

function App() {
  const content = useRoutes(routes);

  const [apolloClient, setApolloClient] = useState<any>(null);

  useEffect(() => {
    fetch(`${process.env.REACT_APP_API_URL}/warm`);
  }, []);

  useEffect(() => {
    setUrl(getGQLServerUrl());

    const httpLink = new HttpLink({
      uri: `${getGQLServerUrl()}/graphql`,
    });

    const wsLink = new GraphQLWsLink(
      createClient({
        url: `${getGQLServerUrl().replace("http", "ws")}/graphql`,
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
      })
    );

    const authLink = setContext(async (_, { headers }) => {
      // get the authentication token from local storage if it exists
      const token = await getIdToken();
      // return the headers to the context so httpLink can read them
      return {
        headers: {
          ...headers,
          authorization: token ? `Bearer ${token}` : "",
        },
      };
    });

    const splitLink = split(
      ({ query }) => {
        const definition = getMainDefinition(query);
        return (
          definition.kind === "OperationDefinition" &&
          definition.operation === "subscription"
        );
      },
      wsLink,
      httpLink
    );

    const client = new ApolloClient({
      link: authLink.concat(splitLink),
      cache: new InMemoryCache({ addTypename: false }),
    });

    setApolloClient(client);
  }, []);

  if (!apolloClient) return null;

  return (
    <>
      <Helmet>
        <link rel="preconnect" href="https://fonts.googleapis.com" />
        <link
          rel="preconnect"
          href="https://fonts.gstatic.com"
          crossOrigin="anonymous"
        />
        <link
          href="https://fonts.googleapis.com/css2?family=Lato:ital,wght@0,100;0,300;0,400;0,700;0,900;1,100;1,300;1,400;1,700;1,900&display=swap"
          rel="stylesheet"
        />
      </Helmet>
      <ApolloProvider client={apolloClient}>
        <AuthProvider>
          <UserProvider>
            <ThemeProvider>
              <ModalProvider>
                <WorkspacesProvider>
                  <UsersProvider>
                    <ChannelsProvider>
                      <DirectMessagesProvider>
                        <DetailsProvider>
                          <ReactionsProvider>
                            <Toaster position="top-center" />
                            <WideScreen>{content}</WideScreen>
                          </ReactionsProvider>
                        </DetailsProvider>
                      </DirectMessagesProvider>
                    </ChannelsProvider>
                  </UsersProvider>
                </WorkspacesProvider>
              </ModalProvider>
            </ThemeProvider>
          </UserProvider>
        </AuthProvider>
      </ApolloProvider>
    </>
  );
}

export default App;
