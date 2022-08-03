import {useAllChannels} from '@/contexts/ChannelsContext';
import {useModal} from '@/contexts/ModalContext';
import {useParams} from '@/contexts/ParamsContext';
import {useUser} from '@/contexts/UserContext';
import {showAlert} from '@/lib/alert';
import {postData} from '@/lib/api-helpers';
import {globalStyles, modalStyles} from '@/styles/styles';
import AddChannelModal from '@/views/modals/AddChannel';
import Fontisto from '@expo/vector-icons/Fontisto';
import {useNavigation} from '@react-navigation/native';
import React from 'react';
import {FlatList, Modal, View} from 'react-native';
import {
  Appbar,
  Colors,
  Divider,
  Searchbar,
  Text,
  TouchableRipple,
} from 'react-native-paper';

function ChannelItem({item: channel}) {
  const {user} = useUser();
  const navigation = useNavigation();
  const {setOpenChannelBrowser: setOpen} = useModal();
  const {setChatType, setChatId} = useParams();

  const joinChannel = async () => {
    try {
      await postData(`/channels/${channel?.objectId}/members`, {
        email: user?.email,
      });
      setChatId(channel.objectId);
      setChatType('Channel');
      navigation.navigate('Chat', {
        objectId: channel.objectId,
      });
      setOpen(false);
    } catch (err) {
      showAlert(err.message);
    }
  };

  const unarchiveAndJoin = async () => {
    try {
      await postData(`/channels/${channel?.objectId}/unarchive`);
      setChatId(channel.objectId);
      setChatType('Channel');
      navigation.navigate('Chat', {
        objectId: channel.objectId,
      });
      setOpen(false);
    } catch (err) {
      showAlert(err.message);
    }
  };

  const isMember = channel?.members?.includes(user?.uid);
  const isArchived = channel?.isArchived;

  return (
    <TouchableRipple
      style={{
        paddingHorizontal: 20,
        paddingVertical: 10,
        height: 60,
        display: 'flex',
        flexDirection: 'row',
        alignItems: 'center',
      }}
      onPress={() => {
        if (!isMember && !isArchived) {
          joinChannel();
        } else if (isArchived) {
          unarchiveAndJoin();
        } else {
          setChatId(channel.objectId);
          setChatType('Channel');
          navigation.navigate('Chat', {
            objectId: channel.objectId,
          });
          setOpen(false);
        }
      }}>
      <View>
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
        <Text
          numberOfLines={1}
          style={{paddingHorizontal: 45, color: Colors.grey600}}>
          {!isMember && !isArchived && 'Join the channel'}
          {isArchived && 'Unarchive and join'}
          {isMember && !isArchived && 'You are a member'}
        </Text>
      </View>
    </TouchableRipple>
  );
}

export default function ChannelBrowserModal() {
  const {openChannelBrowser: open, setOpenChannelBrowser: setOpen} = useModal();

  const [searchQuery, setSearchQuery] = React.useState('');
  const onChangeSearch = query => setSearchQuery(query);

  const {value: channels} = useAllChannels();

  const filteredChannels = channels?.filter(channel =>
    channel.name?.toLowerCase().includes(searchQuery.toLowerCase()),
  );

  React.useEffect(() => {
    setSearchQuery('');
  }, [open]);

  const [addChannelOpen, setAddChannelOpen] = React.useState(false);

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
            <Appbar.Content title="Channel Browser" />
            <Appbar.Action
              icon="plus"
              onPress={() => setAddChannelOpen(true)}
            />
          </Appbar.Header>
          <View
            style={{
              width: '100%',
              height: '100%',
            }}>
            <Searchbar
              placeholder="Search channel..."
              onChangeText={onChangeSearch}
              value={searchQuery}
              style={{margin: 10}}
            />

            <FlatList
              style={{paddingHorizontal: 10}}
              overScrollMode="always"
              data={filteredChannels}
              ItemSeparatorComponent={() => <Divider />}
              renderItem={({item}) => <ChannelItem item={item} />}
              keyExtractor={item => item.objectId}
            />
          </View>

          {addChannelOpen && (
            <AddChannelModal
              open={addChannelOpen}
              setOpen={setAddChannelOpen}
            />
          )}
        </View>
      </View>
    </Modal>
  );
}
