import {useAuth} from '@/contexts/AuthContext';
import {useModal} from '@/contexts/ModalContext';
import {useParams} from '@/contexts/ParamsContext';
import {useUser} from '@/contexts/UserContext';
import {useMyWorkspaces} from '@/contexts/WorkspacesContext';
import {postData} from '@/lib/api-helpers';
import {globalStyles} from '@/styles/styles';
import ChannelBrowserModal from '@/views/modals/ChannelBrowser';
import MemberBrowserModal from '@/views/modals/MemberBrowser';
import Preferences from '@/views/modals/Preferences';
import SearchModal from '@/views/modals/Search';
import WorkspaceBrowserModal from '@/views/modals/WorkspaceBrowser';
import Workspace from '@/views/Workspace';
import Feather from '@expo/vector-icons/Feather';
import {
  createDrawerNavigator,
  DrawerContentScrollView,
} from '@react-navigation/drawer';
import * as Application from 'expo-application';
import React from 'react';
import {ActivityIndicator, Image, SafeAreaView, View} from 'react-native';
import {Colors, Divider, Text, TouchableRipple} from 'react-native-paper';

const DrawerNav = createDrawerNavigator();

function CustomDrawerContent(props) {
  const {value} = useMyWorkspaces();
  const {setOpenPreferences, setOpenWorkspaceBrowser} = useModal();
  const {logout} = useAuth();
  const {workspaceId} = useParams();
  return (
    <View style={{flex: 1}}>
      <DrawerContentScrollView {...props}>
        <Text
          style={{
            fontWeight: 'bold',
            paddingHorizontal: 20,
            paddingVertical: 10,
            fontSize: 20,
          }}>
          Workspaces
        </Text>

        <View>
          {value.map(workspace => (
            <TouchableRipple
              style={{paddingHorizontal: 20, paddingVertical: 10}}
              onPress={() =>
                props.navigation.navigate('Workspace', {
                  objectId: workspace.objectId,
                })
              }
              key={workspace.objectId}>
              <View style={[globalStyles.alignStart]}>
                <Image
                  style={{
                    width: 50,
                    height: 50,
                    borderRadius: 10,
                    ...(workspaceId === workspace.objectId && {
                      borderWidth: 2,
                      borderColor: Colors.black,
                    }),
                  }}
                  source={
                    workspace.thumbnailURL
                      ? {uri: workspace.thumbnailURL}
                      : require('@/files/blank_workspace.png')
                  }
                />
                <Text
                  style={{
                    paddingHorizontal: 10,
                    fontWeight: 'bold',
                    fontSize: 15,
                  }}>
                  {workspace.name}
                </Text>
              </View>
            </TouchableRipple>
          ))}
        </View>

        <Divider style={{marginVertical: 5}} />

        <TouchableRipple
          style={{
            paddingHorizontal: 20,
            paddingVertical: 10,
          }}
          onPress={() => setOpenWorkspaceBrowser(true)}>
          <View style={globalStyles.alignStart}>
            <Feather name="plus-circle" color={Colors.grey800} size={18} />
            <Text style={{paddingHorizontal: 10}}>Add a workspace</Text>
          </View>
        </TouchableRipple>

        <TouchableRipple
          style={{
            paddingHorizontal: 20,
            paddingVertical: 10,
          }}
          onPress={() => setOpenPreferences(true)}>
          <View style={globalStyles.alignStart}>
            <Feather name="settings" color={Colors.grey800} size={18} />
            <Text style={{paddingHorizontal: 10}}>Preferences</Text>
          </View>
        </TouchableRipple>

        <TouchableRipple
          style={{
            paddingHorizontal: 20,
            paddingVertical: 10,
          }}
          onPress={() => logout()}>
          <View style={globalStyles.alignStart}>
            <Feather name="log-out" color={Colors.grey800} size={18} />
            <Text style={{paddingHorizontal: 10}}>Log out</Text>
          </View>
        </TouchableRipple>
        <Text
          style={{
            paddingHorizontal: 20,
            paddingVertical: 30,
            color: Colors.grey500,
          }}>
          App version: {Application.nativeApplicationVersion}
        </Text>
      </DrawerContentScrollView>
    </View>
  );
}

export default function Main() {
  const {value, loading} = useMyWorkspaces();
  const {
    openMemberBrowser,
    openSearch,
    openPreferences,
    openChannelBrowser,
    openWorkspaceBrowser,
  } = useModal();
  const {user} = useUser();

  // MANAGE THE PRESENCE OF THE USER -------------------------------------
  React.useEffect(() => {
    if (user?.uid) {
      postData(`/users/${user?.uid}/presence`, {}, {}, false);
      const intervalId = setInterval(() => {
        postData(`/users/${user?.uid}/presence`, {}, {}, false);
      }, 30000);
      return () => {
        clearInterval(intervalId);
      };
    }
  }, [user?.uid]);
  // ---------------------------------------------------------------------

  if (loading || value.length === 0) return <ActivityIndicator />;

  return (
    <SafeAreaView style={{flex: 1}}>
      <DrawerNav.Navigator
        drawerContent={props => <CustomDrawerContent {...props} />}>
        {/* SCREENS */}
        <DrawerNav.Screen
          name="Workspace"
          component={Workspace}
          initialParams={{objectId: value[0].objectId}}
          options={{
            headerShown: false,
            swipeEnabled: false,
          }}
        />
      </DrawerNav.Navigator>

      {/* MODALS */}
      {openPreferences && <Preferences />}
      {openSearch && <SearchModal />}
      {openMemberBrowser && <MemberBrowserModal />}
      {openChannelBrowser && <ChannelBrowserModal />}
      {openWorkspaceBrowser && <WorkspaceBrowserModal />}
    </SafeAreaView>
  );
}
