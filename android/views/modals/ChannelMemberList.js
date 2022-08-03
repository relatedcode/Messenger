import {useChannelById} from '@/contexts/ChannelsContext';
import {useParams} from '@/contexts/ParamsContext';
import {useUserById, useUsers} from '@/contexts/UsersContext';
import {getFileURL} from '@/lib/storage';
import {globalStyles, modalStyles} from '@/styles/styles';
import React from 'react';
import {FlatList, Image, Modal, View} from 'react-native';
import {Appbar, Colors, Searchbar, Text} from 'react-native-paper';

function PeopleItem({item: user}) {
  const {value: otherUser} = useUserById(user?.objectId);

  return (
    <View
      style={[
        globalStyles.alignStart,
        {paddingHorizontal: 20, paddingVertical: 10, height: 50, width: '100%'},
      ]}>
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
        style={{paddingHorizontal: 15, color: Colors.grey600}}>
        {otherUser.fullName}
      </Text>
    </View>
  );
}

export default function ChannelMemberListModal({open, setOpen}) {
  const {chatId} = useParams();

  const {value: channel} = useChannelById(chatId);
  const {value: users} = useUsers();

  const [searchQuery, setSearchQuery] = React.useState('');
  const onChangeSearch = query => setSearchQuery(query);

  const filteredUsers = users?.filter(user => {
    const fullName = users?.find(u => u.objectId === user.objectId)?.fullName;
    const displayName = users?.find(
      u => u.objectId === user.objectId,
    )?.displayName;

    return (
      fullName?.toLowerCase().includes(searchQuery.toLowerCase()) ||
      displayName?.toLowerCase().includes(searchQuery.toLowerCase())
    );
  });

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
            <Appbar.Content title={`# ${channel?.name}`} />
          </Appbar.Header>

          <Searchbar
            placeholder="Search"
            onChangeText={onChangeSearch}
            value={searchQuery}
            style={{margin: 10}}
          />

          <FlatList
            style={{
              width: '100%',
              height: '100%',
            }}
            overScrollMode="always"
            data={filteredUsers.filter(u =>
              channel?.members.includes(u.objectId),
            )}
            renderItem={({item}) => <PeopleItem item={item} />}
            keyExtractor={item => item.objectId}
          />
        </View>
      </View>
    </Modal>
  );
}
