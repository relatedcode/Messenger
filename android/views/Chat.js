import Input from '@/components/Input';
import Message from '@/components/Message';
import PresenceIndicator from '@/components/PresenceIndicator';
import {env} from '@/config/env';
import {useChannelById} from '@/contexts/ChannelsContext';
import {useDetailByChat} from '@/contexts/DetailsContext';
import {
  useDirectMessageById,
  useDirectRecipient,
} from '@/contexts/DirectMessagesContext';
import {useModal} from '@/contexts/ModalContext';
import {useParams} from '@/contexts/ParamsContext';
import {useUser} from '@/contexts/UserContext';
import {useUsers} from '@/contexts/UsersContext';
import {useMessagesByChat} from '@/hooks/useMessages';
import {showAlert} from '@/lib/alert';
import {postData} from '@/lib/api-helpers';
import {usePresenceByUserId} from '@/lib/usePresence';
import AudioModal from '@/views/modals/Audio';
import ChannelDetailsModal from '@/views/modals/ChannelDetails';
import DirectDetailsModal from '@/views/modals/DirectDetails';
import MessageTypeModal from '@/views/modals/MessageType';
import StickersModal from '@/views/modals/Stickers';
import {useFormik} from 'formik';
import React from 'react';
import {
  FlatList,
  Pressable,
  SafeAreaView,
  StyleSheet,
  View,
} from 'react-native';
import {
  ActivityIndicator,
  Colors,
  Divider,
  IconButton,
  Text,
} from 'react-native-paper';
import {v4 as uuidv4} from 'uuid';

function ChannelHeader({channel}) {
  const {setOpenChannelDetails} = useModal();
  return (
    <Pressable
      onPress={() => setOpenChannelDetails(true)}
      style={{
        flex: 1,
        flexDirection: 'row',
        justifyContent: 'center',
        alignItems: 'center',
      }}>
      <View>
        <Text style={{fontSize: 20, fontWeight: 'bold'}}># {channel.name}</Text>
        <Text style={{fontSize: 14, color: Colors.grey600}}>
          {channel.members.length} members
        </Text>
      </View>
    </Pressable>
  );
}

function DirectHeader({otherUser, isMe}) {
  const {setOpenDirectDetails} = useModal();
  const {isPresent} = usePresenceByUserId(otherUser?.objectId);

  return (
    <Pressable
      onPress={() => setOpenDirectDetails(true)}
      style={{
        flex: 1,
        flexDirection: 'row',
        justifyContent: 'center',
        alignItems: 'center',
      }}>
      <View>
        <View
          style={{
            display: 'flex',
            flexDirection: 'row',
            alignItems: 'center',
          }}>
          <PresenceIndicator isPresent={isPresent} absolute={false} />
          <Text
            style={{fontSize: 20, fontWeight: 'bold', paddingHorizontal: 10}}>
            {otherUser.displayName}
            {isMe ? ' (you)' : ''}
          </Text>
        </View>
        <Text style={{fontSize: 14, color: Colors.grey600}}>View details</Text>
      </View>
    </Pressable>
  );
}

export default function Chat({navigation}) {
  const {user} = useUser();
  const {chatId, chatType, workspaceId} = useParams();
  const {openChannelDetails, openDirectDetails, openStickers, setOpenStickers} =
    useModal();

  // CHANNELS ------------------------------------------------------------
  const {value: channel} = useChannelById(chatId);

  React.useLayoutEffect(() => {
    if (channel) {
      navigation.setOptions({
        headerTitle: () => <ChannelHeader channel={channel} />,
        headerRight: () => (
          <IconButton
            icon="sticker-emoji"
            color={Colors.grey800}
            size={25}
            onPress={() => setOpenStickers(true)}
          />
        ),
      });
    }
  }, [channel]);
  // ---------------------------------------------------------------------

  // DIRECTS -------------------------------------------------------------
  const {value: directMessage} = useDirectMessageById(chatId);
  const {value: otherUser, isMe} = useDirectRecipient(chatId);

  React.useLayoutEffect(() => {
    if (otherUser) {
      navigation.setOptions({
        headerTitle: () => <DirectHeader otherUser={otherUser} isMe={isMe} />,
        headerRight: () => (
          <IconButton
            icon="sticker-emoji"
            color={Colors.grey800}
            size={25}
            onPress={() => setOpenStickers(true)}
          />
        ),
      });
    }
  }, [otherUser]);
  // ---------------------------------------------------------------------

  // LAST READ -----------------------------------------------------------
  const {value: detail} = useDetailByChat(chatId);

  const chatDoc = channel || directMessage;

  const [lastRead, setLastRead] = React.useState(null);
  const [hasNew, setHasNew] = React.useState(false);

  React.useEffect(() => {
    setLastRead(null);
    setHasNew(false);
  }, [chatId]);

  React.useEffect(() => {
    if (chatDoc && chatDoc.lastMessageCounter !== detail?.lastRead) {
      postData(`/users/${user?.uid}/read`, {
        chatType: chatType,
        chatId: chatId,
      });
      if (!hasNew) {
        setLastRead(detail?.lastRead || 0);
        setHasNew(true);
      }
    }
  }, [chatDoc?.lastMessageCounter]);
  // ---------------------------------------------------------------------

  // LOAD DATA AND PAGINATION --------------------------------------------
  const [page, setPage] = React.useState(1);
  const {value: messages, loading} = useMessagesByChat(chatId, page);

  React.useEffect(() => {
    setPage(1);
  }, [chatId]);
  // --------------------------------------------------------------------

  const [messageTypeOpen, setMessageTypeOpen] = React.useState(false);
  const [audioOpen, setAudioOpen] = React.useState(false);

  // FORM ----------------------------------------------------------------
  const {handleSubmit, setFieldValue, values, isSubmitting, resetForm} =
    useFormik({
      initialValues: {
        text: '',
      },
      enableReinitialize: true,
      onSubmit: async val => {
        try {
          const messageId = uuidv4();
          await postData('/messages', {
            objectId: messageId,
            text: `<p>${val.text}</p>`,
            chatId,
            workspaceId,
            chatType,
          });
          resetForm();
        } catch (err) {
          showAlert(err.message);
        }
      },
    });
  // ---------------------------------------------------------------------

  // TYPING INDICATOR ----------------------------------------------------
  const {value: users} = useUsers();
  const typingArray = chatDoc?.typing?.filter(typ => typ !== user?.uid);

  // memoize the typing users
  const typingUsers = React.useMemo(
    () =>
      users?.filter(user => {
        return typingArray?.includes(user.objectId);
      }),
    [users, typingArray],
  );

  const typingText = typingUsers
    ?.map(user => `${user.displayName} is typing...`)
    .join(' ');

  React.useEffect(() => {
    const type = chatType === 'Direct' ? 'directs' : 'channels';
    const id = chatId;

    postData(
      `/${type}/${id}/typing_indicator`,
      {
        isTyping: false,
      },
      {},
      false,
    );

    postData(`/${type}/${id}/reset_typing`, {}, {}, false);
    const interval = setInterval(() => {
      postData(`/${type}/${id}/reset_typing`, {}, {}, false);
    }, 30000);

    return () => {
      clearInterval(interval);
      postData(
        `/${type}/${id}/typing_indicator`,
        {
          isTyping: false,
        },
        {},
        false,
      );
      postData(`/${type}/${id}/reset_typing`, {}, {}, false);
    };
  }, [chatId]);
  // ---------------------------------------------------------------------

  return (
    <SafeAreaView
      style={{flex: 1, flexDirection: 'column', backgroundColor: Colors.white}}>
      {loading && <ActivityIndicator style={{paddingVertical: 10}} />}

      {/* MESSAGES */}
      <FlatList
        style={{paddingHorizontal: 10}}
        overScrollMode="always"
        ListHeaderComponent={() => (
          <Text
            style={{
              paddingBottom: 5,
              paddingHorizontal: 5,
              color: Colors.grey600,
              fontSize: 12,
            }}
            numberOfLines={1}>
            {typingText}
          </Text>
        )}
        ListFooterComponent={() => (
          <Divider style={{paddingTop: 15, opacity: 0}} />
        )}
        onEndReached={
          !loading &&
          messages?.length > 0 &&
          messages?.length === page * env.MESSAGES_PER_PAGE
            ? () => {
                setPage(page + 1);
              }
            : null
        }
        onEndReachedThreshold={0.1}
        data={messages}
        inverted
        renderItem={({item, index}) => (
          // MESSAGE ITEM
          <Message
            chat={item}
            index={index}
            previousSameSender={
              index !== messages?.length
                ? messages[index + 1]?.senderId === item?.senderId
                : false
            }
            previousMessageDate={messages[index + 1]?.createdAt}>
            {/* NEW MESSAGE INDICATOR */}
            {lastRead !== null &&
              lastRead + 1 === item?.counter &&
              chatDoc &&
              lastRead !== chatDoc?.lastMessageCounter &&
              item?.senderId !== user?.uid && (
                <View
                  style={{
                    display: 'flex',
                    flexDirection: 'row',
                    alignItems: 'center',
                    justifyContent: 'flex-start',
                  }}>
                  <View
                    style={{
                      marginTop: 5,
                      height: 1,
                      width: '90%',
                      backgroundColor: Colors.red600,
                    }}
                  />
                  <Text style={{color: Colors.red600, paddingHorizontal: 5}}>
                    New
                  </Text>
                </View>
              )}
          </Message>
        )}
        keyExtractor={item => item.objectId}
      />

      {/* BOTTOM SECTION */}
      <View style={styles.inputContainer}>
        <IconButton
          icon="plus"
          color={Colors.grey800}
          size={25}
          onPress={() => setMessageTypeOpen(true)}
        />
        <Input
          text={values.text}
          setText={setFieldValue}
          isSubmitting={isSubmitting}
        />
        <IconButton
          icon="send"
          color={Colors.grey800}
          size={25}
          disabled={!values.text || isSubmitting}
          onPress={handleSubmit}
        />
      </View>

      {/* MODALS */}
      {messageTypeOpen && (
        <MessageTypeModal
          open={messageTypeOpen}
          setOpen={setMessageTypeOpen}
          setAudioOpen={setAudioOpen}
        />
      )}
      {openStickers && <StickersModal />}
      {openChannelDetails && <ChannelDetailsModal />}
      {openDirectDetails && <DirectDetailsModal />}
      <AudioModal open={audioOpen} setOpen={setAudioOpen} />
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  inputContainer: {
    display: 'flex',
    flexDirection: 'row',
    minHeight: 60,
    maxHeight: 120,
    alignItems: 'center',
    borderWidth: 1,
    borderColor: Colors.grey200,
    borderLeftWidth: 0,
    borderRightWidth: 0,
    borderBottomWidth: 0,
  },
});
