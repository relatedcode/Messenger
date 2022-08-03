import OpenSearchButton from '@/components/OpenSearchButton';
import {useDetailByChat} from '@/contexts/DetailsContext';
import {
  useDirectMessages,
  useDirectRecipient,
} from '@/contexts/DirectMessagesContext';
import {useModal} from '@/contexts/ModalContext';
import {useParams} from '@/contexts/ParamsContext';
import {removeHtml} from '@/lib/removeHtml';
import {getFileURL} from '@/lib/storage';
import {globalStyles} from '@/styles/styles';
import Feather from '@expo/vector-icons/Feather';
import {useNavigation} from '@react-navigation/native';
import {Image, ScrollView, View} from 'react-native';
import {
  ActivityIndicator,
  Colors,
  Text,
  TouchableRipple,
} from 'react-native-paper';

function Direct({direct}) {
  const navigation = useNavigation();
  const {setChatType, setChatId} = useParams();

  const {value: detail} = useDetailByChat(direct?.objectId);

  const notifications = direct
    ? direct.lastMessageCounter - (detail?.lastRead || 0)
    : 0;

  const {value: otherUser, isMe} = useDirectRecipient(direct?.objectId);

  return (
    <TouchableRipple
      style={{
        paddingHorizontal: 20,
        paddingVertical: 10,
      }}
      onPress={() => {
        setChatId(direct.objectId);
        setChatType('Direct');
        navigation.navigate('Chat', {
          objectId: direct.objectId,
        });
      }}>
      <View style={globalStyles.alignStart}>
        <Image
          style={{
            width: 50,
            height: 50,
            borderRadius: 5,
          }}
          source={
            otherUser?.photoURL
              ? {uri: getFileURL(otherUser.photoURL)}
              : require('@/files/blank_user.png')
          }
        />
        <View
          style={{
            display: 'flex',
            flexDirection: 'column',
            alignItems: 'flex-start',
            justifyContent: 'flex-start',
          }}>
          <Text
            numberOfLines={1}
            style={{
              paddingHorizontal: 15,
              fontSize: 17,
              fontWeight: notifications > 0 ? 'bold' : 'normal',
            }}>
            {`${otherUser?.displayName}${isMe ? ' (you)' : ''}`}
          </Text>
          <Text
            style={{paddingHorizontal: 15, color: Colors.grey600}}
            numberOfLines={2}>
            {removeHtml(direct.lastMessageText) || 'No message yet'}
          </Text>
        </View>
      </View>
    </TouchableRipple>
  );
}

export default function DMs() {
  const {value, loading} = useDirectMessages();
  const {setOpenMemberBrowser} = useModal();

  if (loading) return <ActivityIndicator />;

  return (
    <ScrollView
      style={{
        flex: 1,
        width: '100%',
        height: '100%',
        backgroundColor: Colors.white,
      }}>
      <OpenSearchButton />
      <TouchableRipple
        style={{
          paddingHorizontal: 20,
          paddingVertical: 10,
        }}
        onPress={() => setOpenMemberBrowser(true)}>
        <View style={globalStyles.alignStart}>
          <Feather name="plus-circle" color={Colors.grey800} size={18} />
          <Text style={{paddingHorizontal: 10}}>Add members</Text>
        </View>
      </TouchableRipple>
      {value.map(dm => (
        <Direct key={dm.objectId} direct={dm} />
      ))}
    </ScrollView>
  );
}
