import {useModal} from '@/contexts/ModalContext';
import {useUser} from '@/contexts/UserContext';
import {getFileURL} from '@/lib/storage';
import {globalStyles} from '@/styles/styles';
import ProfileModal from '@/views/modals/Profile';
import Feather from '@expo/vector-icons/Feather';
import {Image, ScrollView, View} from 'react-native';
import {Colors, Divider, Text, TouchableRipple} from 'react-native-paper';

export default function You() {
  const {userdata} = useUser();
  const {setOpenProfile, setOpenPreferences} = useModal();

  return (
    <ScrollView style={{flex: 1, backgroundColor: Colors.white}}>
      <TouchableRipple
        style={{marginTop: 7}}
        onPress={() => setOpenProfile(true)}>
        <View
          style={{
            display: 'flex',
            flexDirection: 'row',
            alignItems: 'center',
            justifyContent: 'flex-start',
            padding: 15,
          }}>
          <Image
            style={{
              width: 60,
              height: 60,
              borderRadius: 5,
            }}
            source={
              userdata?.photoURL
                ? {uri: getFileURL(userdata.photoURL)}
                : require('@/files/blank_user.png')
            }
          />
          <View style={{paddingVertical: 10, paddingHorizontal: 15}}>
            <Text numberOfLines={1} style={{fontWeight: 'bold', fontSize: 15}}>
              {userdata?.displayName}
            </Text>
            <Text style={{color: Colors.grey700}}>Active</Text>
          </View>
        </View>
      </TouchableRipple>

      <Divider style={{backgroundColor: Colors.grey400, marginVertical: 7}} />

      {/* <TouchableRipple
        style={{
          paddingHorizontal: 20,
          paddingVertical: 10,
        }}
        onPress={() => {}}>
        <View style={globalStyles.alignStart}>
          <Feather name="user" color={Colors.grey800} size={18} />
          <Text style={{paddingHorizontal: 10}}>View profile</Text>
        </View>
      </TouchableRipple> */}

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

      {/* MODALS */}
      <ProfileModal />
    </ScrollView>
  );
}
