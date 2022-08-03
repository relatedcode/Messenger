import {useParams} from '@/contexts/ParamsContext';
import {useWorkspaceById} from '@/contexts/WorkspacesContext';
import {getFileURL} from '@/lib/storage';
import Chat from '@/views/Chat';
import DMs from '@/views/DMs';
import Home from '@/views/Home';
import You from '@/views/You';
import Feather from '@expo/vector-icons/Feather';
import {createBottomTabNavigator} from '@react-navigation/bottom-tabs';
import {getFocusedRouteNameFromRoute} from '@react-navigation/native';
import {
  CardStyleInterpolators,
  createStackNavigator,
} from '@react-navigation/stack';
import React from 'react';
import {Image, TouchableOpacity} from 'react-native';
import {Colors} from 'react-native-paper';

function showHeader(route) {
  const routeName = getFocusedRouteNameFromRoute(route) ?? 'Home';

  switch (routeName) {
    case 'Home':
      return true;
    case 'DMs':
      return false;
    case 'You':
      return false;
  }
}

const Tab = createBottomTabNavigator();

function Menu() {
  return (
    <Tab.Navigator
      activeColor={Colors.black}
      in={Colors.grey500}
      screenOptions={{tabBarHideOnKeyboard: true}}>
      <Tab.Screen
        name="Home"
        component={Home}
        options={{
          tabBarIcon: ({color}) => (
            <Feather name="home" color={color} size={24} />
          ),
          tabBarLabelStyle: {marginBottom: 3, fontWeight: 'bold'},
          tabBarActiveTintColor: Colors.black,
          tabBarInactiveTintColor: Colors.grey500,
          headerShown: false,
        }}
      />
      <Tab.Screen
        name="DMs"
        component={DMs}
        options={{
          tabBarIcon: ({color}) => (
            <Feather name="message-circle" color={color} size={24} />
          ),
          tabBarLabelStyle: {marginBottom: 3, fontWeight: 'bold'},
          headerTitle: 'Direct messages',
          headerTintColor: Colors.white,
          headerStyle: {
            backgroundColor: Colors.blue500,
          },
          tabBarActiveTintColor: Colors.black,
          tabBarInactiveTintColor: Colors.grey500,
        }}
      />
      <Tab.Screen
        name="You"
        component={You}
        options={{
          tabBarIcon: ({color}) => (
            <Feather name="user" color={color} size={24} />
          ),
          headerTintColor: Colors.white,
          headerStyle: {
            backgroundColor: Colors.blue500,
          },
          tabBarLabelStyle: {marginBottom: 3, fontWeight: 'bold'},
          tabBarActiveTintColor: Colors.black,
          tabBarInactiveTintColor: Colors.grey500,
        }}
      />
    </Tab.Navigator>
  );
}

const Stack = createStackNavigator();

export default function Workspace({route, navigation}) {
  const {objectId} = route.params;

  const {setWorkspaceId} = useParams();
  const {value: workspace} = useWorkspaceById(objectId);

  React.useEffect(() => {
    setWorkspaceId(objectId);
  }, [objectId]);

  return (
    <Stack.Navigator>
      <Stack.Screen
        name="Menu"
        component={Menu}
        options={({route}) => ({
          headerTitle: workspace?.name || 'Home',
          headerTintColor: Colors.white,
          headerStyle: {
            backgroundColor: Colors.blue500,
          },
          headerLeft: () => (
            <TouchableOpacity onPress={() => navigation.openDrawer()}>
              <Image
                style={{
                  width: 30,
                  height: 30,
                  borderRadius: 5,
                  marginLeft: 12,
                }}
                source={
                  workspace?.thumbnailURL
                    ? {uri: getFileURL(workspace.thumbnailURL)}
                    : require('@/files/blank_workspace.png')
                }
              />
            </TouchableOpacity>
          ),
          headerShown: showHeader(route),
        })}
      />
      <Stack.Screen
        name="Chat"
        component={Chat}
        options={{
          cardStyleInterpolator: CardStyleInterpolators.forHorizontalIOS,
          headerStyle: {
            borderBottomWidth: 1,
            borderBottomColor: Colors.grey300,
          },
        }}
      />
    </Stack.Navigator>
  );
}
