import PresenceIndicator from '@/components/PresenceIndicator';
import {useDirectRecipient} from '@/contexts/DirectMessagesContext';
import {useModal} from '@/contexts/ModalContext';
import {useParams} from '@/contexts/ParamsContext';
import {showAlert} from '@/lib/alert';
import {postData} from '@/lib/api-helpers';
import {getFileURL} from '@/lib/storage';
import {usePresenceByUserId} from '@/lib/usePresence';
import {globalStyles, modalStyles} from '@/styles/styles';
import Feather from '@expo/vector-icons/Feather';
import {useNavigation} from '@react-navigation/native';
import {Image, Modal, ScrollView, View} from 'react-native';
import {Appbar, Colors, Text, TouchableRipple} from 'react-native-paper';

export default function DirectDetailsModal() {
  const navigation = useNavigation();
  const {chatId} = useParams();
  const {openDirectDetails: open, setOpenDirectDetails: setOpen} = useModal();

  const {value: otherUser} = useDirectRecipient(chatId);

  const {isPresent} = usePresenceByUserId(otherUser?.objectId);

  const closeConversation = async () => {
    try {
      await postData(`/directs/${chatId}/close`);
      setOpen(false);
      navigation.navigate('Home');
    } catch (err) {
      showAlert(err.message);
    }
  };

  return (
    <Modal
      animationType="slide"
      transparent={true}
      visible={open}
      onRequestClose={() => {
        setOpen(!open);
      }}>
      <View style={modalStyles.centeredView}>
        <View style={modalStyles.modalView}>
          <Appbar.Header
            statusBarHeight={0}
            style={{width: '100%', backgroundColor: '#fff'}}>
            <Appbar.Action icon="window-close" onPress={() => setOpen(!open)} />
            <Appbar.Content title={otherUser?.displayName} />
          </Appbar.Header>
          <ScrollView
            style={{
              width: '100%',
              height: '100%',
              paddingHorizontal: 20,
            }}>
            <View
              style={{
                backgroundColor: Colors.white,
                marginVertical: 15,
                padding: 10,
                borderRadius: 5,
                borderWidth: 1,
                borderColor: Colors.grey200,
              }}>
              <View style={globalStyles.alignStart}>
                <View style={{position: 'relative'}}>
                  <Image
                    style={{
                      width: 30,
                      height: 30,
                      borderRadius: 5,
                    }}
                    source={
                      otherUser?.thumbnailURL
                        ? {uri: getFileURL(otherUser.thumbnailURL)}
                        : require('@/files/blank_user.png')
                    }
                  />
                  <PresenceIndicator isPresent={isPresent} />
                </View>
                <View
                  style={{
                    paddingHorizontal: 15,
                    display: 'flex',
                    flexDirection: 'column',
                  }}>
                  <Text numberOfLines={1} style={{fontSize: 15}}>
                    {otherUser?.displayName}
                  </Text>
                  <Text numberOfLines={1} style={{fontSize: 12}}>
                    {otherUser?.fullName}
                  </Text>
                </View>
              </View>
            </View>
            <View
              style={{
                backgroundColor: Colors.white,
                marginVertical: 15,
                borderRadius: 5,
                borderWidth: 1,
                borderColor: Colors.grey200,
              }}>
              {/* Close conversation */}
              <TouchableRipple
                style={{
                  paddingHorizontal: 20,
                  paddingVertical: 10,
                }}
                onPress={closeConversation}>
                <View style={globalStyles.alignStart}>
                  <Feather name="log-out" color={Colors.grey800} size={18} />
                  <Text style={{paddingHorizontal: 10}}>
                    Close conversation
                  </Text>
                </View>
              </TouchableRipple>
            </View>
          </ScrollView>
        </View>
      </View>
    </Modal>
  );
}
