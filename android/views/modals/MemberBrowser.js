import {useModal} from '@/contexts/ModalContext';
import {useParams} from '@/contexts/ParamsContext';
import {useUsers} from '@/contexts/UsersContext';
import {showAlert} from '@/lib/alert';
import {postData} from '@/lib/api-helpers';
import {getFileURL} from '@/lib/storage';
import {globalStyles, modalStyles} from '@/styles/styles';
import AddMemberWorkspaceModal from '@/views/modals/AddMemberWorkspace';
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

function SearchItemUser({item: user}) {
  const navigation = useNavigation();
  const {workspaceId} = useParams();
  const {setOpenMemberBrowser: setOpen} = useModal();
  const {setChatType, setChatId} = useParams();

  const newMessage = async () => {
    try {
      const {directId} = await postData('/directs', {
        workspaceId,
        userId: user.objectId,
      });
      setChatId(directId);
      setChatType('Direct');
      navigation.navigate('Chat', {
        objectId: directId,
      });
      setOpen(false);
    } catch (err) {
      showAlert(err.message);
    }
  };

  return (
    <TouchableRipple
      style={{
        paddingHorizontal: 20,
        paddingVertical: 10,
        height: 50,
      }}
      onPress={newMessage}>
      <View style={globalStyles.alignStart}>
        <Image
          style={{
            width: 30,
            height: 30,
            borderRadius: 5,
          }}
          source={
            user?.thumbnailURL
              ? {uri: getFileURL(user.thumbnailURL)}
              : require('@/files/blank_user.png')
          }
        />
        <Text numberOfLines={1} style={{paddingLeft: 15, fontWeight: 'bold'}}>
          {user.displayName}
        </Text>
        <Text
          numberOfLines={1}
          style={{
            paddingHorizontal: 15,
            color: Colors.grey600,
          }}>
          {user.fullName}
        </Text>
      </View>
    </TouchableRipple>
  );
}

export default function MemberBrowserModal() {
  const {openMemberBrowser: open, setOpenMemberBrowser: setOpen} = useModal();

  const [searchQuery, setSearchQuery] = React.useState('');
  const onChangeSearch = query => setSearchQuery(query);

  const {value: users} = useUsers();

  const displayMembers = React.useMemo(
    () =>
      users.reduce((result, member) => {
        if (
          member?.fullName?.toLowerCase().includes(searchQuery.toLowerCase()) ||
          member?.displayName?.toLowerCase().includes(searchQuery.toLowerCase())
        )
          result.push(member);
        return result;
      }, []),
    [users, searchQuery],
  );

  React.useEffect(() => {
    setSearchQuery('');
  }, [open]);

  const [addMemberOpen, setAddMemberOpen] = React.useState(false);

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
            <Appbar.Content title="Member Browser" />
            <Appbar.Action icon="plus" onPress={() => setAddMemberOpen(true)} />
          </Appbar.Header>
          <View
            style={{
              width: '100%',
              height: '100%',
            }}>
            <Searchbar
              placeholder="Search member..."
              onChangeText={onChangeSearch}
              value={searchQuery}
              style={{margin: 10}}
            />

            <FlatList
              style={{paddingHorizontal: 10}}
              overScrollMode="always"
              data={displayMembers}
              renderItem={({item}) => <SearchItemUser item={item} />}
              keyExtractor={item => item.objectId}
            />
          </View>

          {addMemberOpen && (
            <AddMemberWorkspaceModal
              open={addMemberOpen}
              setOpen={setAddMemberOpen}
            />
          )}
        </View>
      </View>
    </Modal>
  );
}
