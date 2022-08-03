import {useModal} from '@/contexts/ModalContext';
import {useUser} from '@/contexts/UserContext';
import {useAllWorkspaces} from '@/contexts/WorkspacesContext';
import {showAlert} from '@/lib/alert';
import {postData} from '@/lib/api-helpers';
import {getFileURL} from '@/lib/storage';
import {globalStyles, modalStyles} from '@/styles/styles';
import AddWorkspaceModal from '@/views/modals/AddWorkspace';
import {useNavigation} from '@react-navigation/native';
import React from 'react';
import {FlatList, Image, Modal, View} from 'react-native';
import {
  Appbar,
  Colors,
  Divider,
  Searchbar,
  Text,
  TouchableRipple,
} from 'react-native-paper';

function WorkspaceItem({item: workspace}) {
  const {user} = useUser();
  const {setOpenWorkspaceBrowser: setOpen} = useModal();
  const navigation = useNavigation();

  const isMember = workspace?.members?.includes(user?.uid);

  const joinWorkspace = async () => {
    try {
      if (isMember) {
        navigation.navigate('Workspace', {
          objectId: workspace.objectId,
        });
        setOpen(false);
        return;
      }

      await postData(`/workspaces/${workspace.objectId}/members`, {
        email: user?.email,
      });
      navigation.navigate('Workspace', {
        objectId: workspace.objectId,
      });
      setOpen(false);
    } catch (err) {
      showAlert(err.message);
      setOpen(false);
    }
  };

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
      onPress={joinWorkspace}>
      <View style={globalStyles.alignStart}>
        <Image
          style={{
            width: 30,
            height: 30,
            borderRadius: 5,
          }}
          source={
            workspace?.thumbnailURL
              ? {uri: getFileURL(workspace.thumbnailURL)}
              : require('@/files/blank_workspace.png')
          }
        />
        <View
          style={{
            display: 'flex',
            flexDirection: 'column',
            alignItems: 'flex-start',
            justifyContent: 'center',
            paddingHorizontal: 20,
          }}>
          <Text numberOfLines={1} style={{fontWeight: 'bold'}}>
            {workspace.name}
          </Text>
          <Text numberOfLines={1} style={{color: Colors.grey600, fontSize: 13}}>
            {!isMember && 'Join the workspace'}
            {isMember && 'You are a member'}
          </Text>
        </View>
      </View>
    </TouchableRipple>
  );
}

export default function WorkspaceBrowserModal() {
  const {openWorkspaceBrowser: open, setOpenWorkspaceBrowser: setOpen} =
    useModal();

  const [searchQuery, setSearchQuery] = React.useState('');
  const onChangeSearch = query => setSearchQuery(query);

  const {value: workspaces} = useAllWorkspaces();

  const filteredWorkspaces = workspaces?.filter(w =>
    w.name?.toLowerCase().includes(searchQuery.toLowerCase()),
  );

  React.useEffect(() => {
    setSearchQuery('');
  }, [open]);

  const [addWorkspaceOpen, setAddWorkspaceOpen] = React.useState(false);

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
            <Appbar.Content title="Workspace Browser" />
            <Appbar.Action
              icon="plus"
              onPress={() => setAddWorkspaceOpen(true)}
            />
          </Appbar.Header>
          <View
            style={{
              width: '100%',
              height: '100%',
            }}>
            <Searchbar
              placeholder="Search workspace..."
              onChangeText={onChangeSearch}
              value={searchQuery}
              style={{margin: 10}}
            />

            <FlatList
              style={{paddingHorizontal: 10}}
              overScrollMode="always"
              data={filteredWorkspaces}
              ItemSeparatorComponent={() => <Divider />}
              renderItem={({item}) => <WorkspaceItem item={item} />}
              keyExtractor={item => item.objectId}
            />
          </View>

          {addWorkspaceOpen && (
            <AddWorkspaceModal
              open={addWorkspaceOpen}
              setOpen={setAddWorkspaceOpen}
            />
          )}
        </View>
      </View>
    </Modal>
  );
}
