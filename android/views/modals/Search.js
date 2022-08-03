import {useChannels} from '@/contexts/ChannelsContext';
import {
  useDirectMessages,
  useDirectRecipient,
} from '@/contexts/DirectMessagesContext';
import {useModal} from '@/contexts/ModalContext';
import {useParams} from '@/contexts/ParamsContext';
import {useUser} from '@/contexts/UserContext';
import {useUsers} from '@/contexts/UsersContext';
import {getFileURL} from '@/lib/storage';
import {globalStyles, modalStyles} from '@/styles/styles';
import Fontisto from '@expo/vector-icons/Fontisto';
import {useNavigation} from '@react-navigation/native';
import React from 'react';
import {FlatList, Image, Modal, View} from 'react-native';
import {
  Appbar,
  Colors,
  Searchbar,
  Text,
  TouchableRipple,
} from 'react-native-paper';

function SearchItemChannel({item: channel}) {
  const navigation = useNavigation();
  const {setOpenSearch: setOpen} = useModal();
  const {setChatType, setChatId} = useParams();
  return (
    <TouchableRipple
      style={{
        paddingHorizontal: 20,
        paddingVertical: 10,
        height: 50,
        display: 'flex',
        flexDirection: 'row',
        alignItems: 'center',
      }}
      onPress={() => {
        setChatId(channel.objectId);
        setChatType('Channel');
        navigation.navigate('Chat', {
          objectId: channel.objectId,
        });
        setOpen(false);
      }}>
      <View style={globalStyles.alignStart}>
        <Fontisto
          style={{paddingHorizontal: 5, color: Colors.grey700}}
          name="hashtag"
          size={15}
        />
        <Text
          numberOfLines={1}
          style={{paddingHorizontal: 20, fontWeight: 'bold'}}>
          {channel.name}
        </Text>
      </View>
    </TouchableRipple>
  );
}

function SearchItemDirect({item: direct}) {
  const navigation = useNavigation();
  const {setOpenSearch: setOpen} = useModal();
  const {setChatType, setChatId} = useParams();

  const {value: otherUser} = useDirectRecipient(direct?.objectId);

  return (
    <TouchableRipple
      style={{
        paddingHorizontal: 20,
        paddingVertical: 10,
        height: 50,
      }}
      onPress={() => {
        setChatId(direct.objectId);
        setChatType('Direct');
        navigation.navigate('Chat', {
          objectId: direct.objectId,
        });
        setOpen(false);
      }}>
      <View style={globalStyles.alignStart}>
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
        <Text numberOfLines={1} style={{paddingLeft: 15, fontWeight: 'bold'}}>
          {otherUser.displayName}
        </Text>
        <Text
          numberOfLines={1}
          style={{
            paddingHorizontal: 15,
            color: Colors.grey600,
          }}>
          {otherUser.fullName}
        </Text>
      </View>
    </TouchableRipple>
  );
}

export default function SearchModal() {
  const {openSearch: open, setOpenSearch: setOpen} = useModal();

  const [searchQuery, setSearchQuery] = React.useState('');
  const onChangeSearch = query => setSearchQuery(query);

  const {user} = useUser();
  const {value: channels} = useChannels();
  const {value: directs} = useDirectMessages();
  const {value: users} = useUsers();

  const filteredChannels = channels?.filter(channel =>
    channel.name?.toLowerCase().includes(searchQuery.toLowerCase()),
  );

  const filteredDirects = directs?.filter(direct => {
    const isMe =
      direct?.members?.length === 1 && direct?.members[0] === user?.uid;
    const otherUserId = isMe
      ? user?.uid
      : direct?.members.find(m => m !== user?.uid);

    const fullName = users?.find(u => u.objectId === otherUserId)?.fullName;
    const displayName = users?.find(
      u => u.objectId === otherUserId,
    )?.displayName;

    return (
      fullName?.toLowerCase().includes(searchQuery.toLowerCase()) ||
      displayName?.toLowerCase().includes(searchQuery.toLowerCase())
    );
  });

  const data = [...filteredChannels, ...filteredDirects];

  React.useEffect(() => {
    setSearchQuery('');
  }, [open]);

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
            <Appbar.Content title="Search" />
          </Appbar.Header>
          <View
            style={{
              width: '100%',
              height: '100%',
            }}>
            <Searchbar
              placeholder="Jump to..."
              onChangeText={onChangeSearch}
              value={searchQuery}
              style={{margin: 10}}
            />

            <FlatList
              style={{paddingHorizontal: 10}}
              overScrollMode="always"
              data={data}
              renderItem={({item}) =>
                item?.name ? (
                  <SearchItemChannel item={item} />
                ) : (
                  <SearchItemDirect item={item} />
                )
              }
              keyExtractor={item => item.objectId}
            />
          </View>
        </View>
      </View>
    </Modal>
  );
}
