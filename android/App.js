import {apolloClient} from '@/config/apollo';
import {AuthProvider, useAuth} from '@/contexts/AuthContext';
import {ChannelsProvider} from '@/contexts/ChannelsContext';
import {DetailsProvider} from '@/contexts/DetailsContext';
import {DirectMessagesProvider} from '@/contexts/DirectMessagesContext';
import {ModalProvider} from '@/contexts/ModalContext';
import {ParamsProvider} from '@/contexts/ParamsContext';
import {UserProvider} from '@/contexts/UserContext';
import {UsersProvider} from '@/contexts/UsersContext';
import {WorkspacesProvider} from '@/contexts/WorkspacesContext';
import Login from '@/views/Login';
import Main from '@/views/Main';
import {ApolloProvider} from '@apollo/client';
import {ActionSheetProvider} from '@expo/react-native-action-sheet';
import {NavigationContainer} from '@react-navigation/native';
import {ActivityIndicator} from 'react-native';
import 'react-native-get-random-values';
import {
  Colors,
  DefaultTheme,
  Provider as PaperProvider,
} from 'react-native-paper';

function Views() {
  const {isInitialized, isAuthenticated, user} = useAuth();

  console.log('isAuthenticated', isAuthenticated);
  console.log('user', user);

  if (!isInitialized) return <ActivityIndicator />;
  if (!isAuthenticated) return <Login />;

  return <Main />;
}

const theme = {
  ...DefaultTheme,
  colors: {
    ...DefaultTheme.colors,
    primary: Colors.blue700,
    accent: Colors.blue400,
  },
  dark: false,
};

export default function App() {
  return (
    <PaperProvider theme={theme}>
      <ActionSheetProvider>
        <NavigationContainer>
          <ApolloProvider client={apolloClient}>
            <ModalProvider>
              <AuthProvider>
                <UserProvider>
                  <ParamsProvider>
                    <UsersProvider>
                      <WorkspacesProvider>
                        <ChannelsProvider>
                          <DirectMessagesProvider>
                            <DetailsProvider>
                              <Views />
                            </DetailsProvider>
                          </DirectMessagesProvider>
                        </ChannelsProvider>
                      </WorkspacesProvider>
                    </UsersProvider>
                  </ParamsProvider>
                </UserProvider>
              </AuthProvider>
            </ModalProvider>
          </ApolloProvider>
        </NavigationContainer>
      </ActionSheetProvider>
    </PaperProvider>
  );
}
