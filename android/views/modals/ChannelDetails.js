import {useChannelById} from '@/contexts/ChannelsContext';
import {useModal} from '@/contexts/ModalContext';
import {useParams} from '@/contexts/ParamsContext';
import {useUser} from '@/contexts/UserContext';
import {useWorkspaceById} from '@/contexts/WorkspacesContext';
import {showAlert} from '@/lib/alert';
import {deleteData, postData} from '@/lib/api-helpers';
import {globalStyles, modalStyles} from '@/styles/styles';
import AddMemberChannelModal from '@/views/modals/AddMemberChannel';
import ChannelMemberList from '@/views/modals/ChannelMemberList';
import EditChannelDetailsModal from '@/views/modals/EditChannelDetails';
import Feather from '@expo/vector-icons/Feather';
import {useNavigation} from '@react-navigation/native';
import React from 'react';
import {Modal, ScrollView, View} from 'react-native';
import {Appbar, Colors, Text, TouchableRipple} from 'react-native-paper';

export default function ChannelDetailsModal() {
  const navigation = useNavigation();
  const {user} = useUser();
  const {chatId} = useParams();
  const {openChannelDetails: open, setOpenChannelDetails: setOpen} = useModal();

  const {value: channel} = useChannelById(chatId);
  const {value: workspace} = useWorkspaceById(channel?.workspaceId);

  const [openEditChannelDetails, setOpenEditChannelDetails] =
    React.useState(false);
  const [openChannelMemberList, setOpenChannelMemberList] =
    React.useState(false);
  const [openAddMemberChannel, setOpenAddMemberChannel] = React.useState(false);

  const leaveChannel = async () => {
    try {
      await deleteData(`/channels/${chatId}/members/${user?.uid}`);
      setOpen(false);
      navigation.navigate('Home');
    } catch (err) {
      showAlert(err.message);
    }
  };

  const archiveChannel = async () => {
    try {
      await postData(`/channels/${chatId}/archive`);
      setOpen(false);
      navigation.navigate('Home');
    } catch (err) {
      showAlert(err.message);
    }
  };

  const defaultChannel = workspace?.channelId === chatId;

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
            <Appbar.Content title="Channel details" />
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
                borderRadius: 5,
                borderWidth: 1,
                borderColor: Colors.grey200,
              }}>
              <View
                style={{
                  padding: 10,
                }}>
                <Text style={{fontSize: 20}} numberOfLines={1}>
                  # {channel?.name}
                </Text>
                <View style={{marginTop: 15}}>
                  <Text style={{fontSize: 14, fontWeight: '700'}}>
                    Description
                  </Text>
                  <Text
                    numberOfLines={2}
                    style={{
                      fontSize: 14,
                      color: Colors.grey800,
                      marginTop: 5,
                    }}>
                    {channel?.details || 'Not description yet'}
                  </Text>
                </View>
                <View style={{marginTop: 15}}>
                  <Text style={{fontSize: 14, fontWeight: '700'}}>Topic</Text>
                  <Text
                    numberOfLines={2}
                    style={{
                      fontSize: 14,
                      color: Colors.grey800,
                      marginTop: 5,
                    }}>
                    {channel?.topic || 'Not topic yet'}
                  </Text>
                </View>
              </View>
              <TouchableRipple
                onPress={() => setOpenEditChannelDetails(true)}
                style={{
                  borderTopWidth: 1,
                  borderTopColor: Colors.grey200,
                  marginTop: 10,
                  padding: 15,
                }}>
                <Text style={{color: Colors.blue500}}>EDIT</Text>
              </TouchableRipple>
            </View>
            <View
              style={{
                backgroundColor: Colors.white,
                marginVertical: 15,
                borderRadius: 5,
                borderWidth: 1,
                borderColor: Colors.grey200,
              }}>
              {/* Member list */}
              <TouchableRipple
                style={{
                  paddingHorizontal: 20,
                  paddingVertical: 10,
                }}
                onPress={() => setOpenChannelMemberList(true)}>
                <View style={globalStyles.alignStart}>
                  <Feather name="book" color={Colors.grey800} size={18} />
                  <Text
                    style={{
                      paddingHorizontal: 10,
                    }}>{`Member list (${channel?.members?.length})`}</Text>
                </View>
              </TouchableRipple>

              {/* Add people */}
              <TouchableRipple
                style={{
                  paddingHorizontal: 20,
                  paddingVertical: 10,
                  borderTopColor: Colors.grey200,
                  borderTopWidth: 1,
                }}
                onPress={() => setOpenAddMemberChannel(true)}>
                <View style={globalStyles.alignStart}>
                  <Feather name="user-plus" color={Colors.grey800} size={18} />
                  <Text style={{paddingHorizontal: 10}}>Add people</Text>
                </View>
              </TouchableRipple>

              {/* Leave channel */}
              {!defaultChannel && (
                <TouchableRipple
                  style={{
                    paddingHorizontal: 20,
                    paddingVertical: 10,
                    borderTopColor: Colors.grey200,
                    borderTopWidth: 1,
                  }}
                  onPress={leaveChannel}>
                  <View style={globalStyles.alignStart}>
                    <Feather name="log-out" color={Colors.grey800} size={18} />
                    <Text style={{paddingHorizontal: 10}}>Leave</Text>
                  </View>
                </TouchableRipple>
              )}

              {/* Archive channel */}
              {!defaultChannel && (
                <TouchableRipple
                  style={{
                    paddingHorizontal: 20,
                    paddingVertical: 10,
                    borderTopColor: Colors.grey200,
                    borderTopWidth: 1,
                  }}
                  onPress={archiveChannel}>
                  <View style={globalStyles.alignStart}>
                    <Feather name="archive" color={Colors.red600} size={18} />
                    <Text style={{paddingHorizontal: 10, color: Colors.red600}}>
                      Archive
                    </Text>
                  </View>
                </TouchableRipple>
              )}
            </View>
          </ScrollView>
          <EditChannelDetailsModal
            open={openEditChannelDetails}
            setOpen={setOpenEditChannelDetails}
          />
          <ChannelMemberList
            open={openChannelMemberList}
            setOpen={setOpenChannelMemberList}
          />
          <AddMemberChannelModal
            open={openAddMemberChannel}
            setOpen={setOpenAddMemberChannel}
          />
        </View>
      </View>
    </Modal>
  );
}
