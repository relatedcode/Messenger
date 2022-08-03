import MessageHoverMenu from '@/components/MessageHoverMenu';
import {env} from '@/config/env';
import {useUser} from '@/contexts/UserContext';
import {useUserById} from '@/contexts/UsersContext';
import {convertMsToTime} from '@/lib/convert';
import {removeHtml} from '@/lib/removeHtml';
import {getFileURL} from '@/lib/storage';
import {cacheThumbnails} from '@/lib/thumbnails';
import FullScreenPictureModal from '@/views/modals/FullScreenPicture';
import VideoModal from '@/views/modals/Video';
import {MaterialIcons} from '@expo/vector-icons';
import {Audio} from 'expo-av';
import React from 'react';
import {
  Image,
  ImageBackground,
  Pressable,
  StyleSheet,
  Text,
  View,
} from 'react-native';
import {Colors, ProgressBar} from 'react-native-paper';

function AudioPlayer({chat, setPosition, setVisible}) {
  const [sound, setSound] = React.useState(null);
  const [status, setStatus] = React.useState(null);

  async function loadAndPlaySound() {
    const {sound: soundSource} = await Audio.Sound.createAsync({
      uri: getFileURL(chat?.fileURL),
    });
    soundSource.setOnPlaybackStatusUpdate(stat => setStatus(() => stat));
    soundSource.setProgressUpdateIntervalAsync(200);
    setSound(soundSource);
    await soundSource.playAsync();
  }

  function unloadSound() {
    setSound(null);
    setStatus(null);
    sound.unloadAsync();
  }

  async function pauseSound() {
    await sound.pauseAsync();
  }

  async function playSound() {
    await sound.playAsync();
  }

  React.useEffect(() => {
    return sound
      ? () => {
          unloadSound();
        }
      : undefined;
  }, []);

  React.useEffect(() => {
    if (status?.didJustFinish) {
      unloadSound();
    }
  }, [status]);

  const positionMillis = status?.positionMillis || 0;
  const durationMillis = status?.durationMillis || chat?.mediaDuration || 0;
  const progress = positionMillis / durationMillis;

  return (
    <Pressable
      style={{
        display: 'flex',
        flexDirection: 'row',
        alignItems: 'center',
      }}
      onLongPress={
        setPosition && setVisible
          ? ({nativeEvent}) => {
              setPosition({
                x: Number(nativeEvent.pageX.toFixed(2)),
                y: Number(nativeEvent.pageY.toFixed(2)),
              });
              setVisible(true);
            }
          : null
      }
      onPress={() => {
        if (status?.isPlaying) {
          pauseSound();
        } else if (sound) {
          playSound();
        } else {
          loadAndPlaySound();
        }
      }}>
      {status?.isPlaying && (
        <MaterialIcons name="pause" size={24} style={{color: Colors.black}} />
      )}
      {!status?.isPlaying && (
        <MaterialIcons
          name="play-arrow"
          size={24}
          style={{color: Colors.black}}
        />
      )}
      <View
        style={{
          display: 'flex',
          flexDirection: 'column',
          alignItems: 'flex-start',
          justifyContent: 'center',
          marginLeft: 5,
        }}>
        <ProgressBar
          style={{width: 100, marginBottom: 2}}
          progress={progress || 0}
          color={Colors.grey700}
        />
        <Text style={{color: Colors.black, fontSize: 11, textAlign: 'left'}}>
          {convertMsToTime(
            positionMillis === 0
              ? Math.floor(chat?.mediaDuration * 1000)
              : positionMillis,
          )}
        </Text>
      </View>
    </Pressable>
  );
}

function VideoPlayer({chat, setPosition, setVisible}) {
  const [file, setFile] = React.useState('');
  const [open, setOpen] = React.useState(false);

  React.useEffect(() => {
    if (chat?.fileURL) {
      (async () => {
        const uri = await cacheThumbnails(chat);
        setFile(uri);
      })();
    }
  }, [chat?.fileURL]);

  return (
    <Pressable
      style={{
        width: 285,
        height: 285,
        maxWidth: '100%',
      }}
      onPress={() => setOpen(true)}
      onLongPress={
        setPosition && setVisible
          ? ({nativeEvent}) => {
              setPosition({
                x: Number(nativeEvent.pageX.toFixed(2)),
                y: Number(nativeEvent.pageY.toFixed(2)),
              });
              setVisible(true);
            }
          : null
      }>
      <ImageBackground
        imageStyle={{
          resizeMode: 'cover',
          borderRadius: 10,
          width: 285,
          height: 285,
        }}
        style={{
          alignItems: 'center',
          justifyContent: 'center',
          height: '100%',
        }}
        defaultSource={require('@/files/placeholder_600.jpg')}
        source={file ? {uri: file} : require('@/files/placeholder_600.jpg')}>
        <MaterialIcons
          name="play-arrow"
          size={60}
          style={{color: Colors.white}}
        />
      </ImageBackground>
      {open && (
        <VideoModal
          open={open}
          setOpen={setOpen}
          uri={getFileURL(chat?.fileURL)}
        />
      )}
    </Pressable>
  );
}

function ImageViewer({chat, setPosition, setVisible}) {
  const [open, setOpen] = React.useState(false);
  return (
    <Pressable
      onPress={() => setOpen(true)}
      onLongPress={
        setPosition && setVisible
          ? ({nativeEvent}) => {
              setPosition({
                x: Number(nativeEvent.pageX.toFixed(2)),
                y: Number(nativeEvent.pageY.toFixed(2)),
              });
              setVisible(true);
            }
          : null
      }>
      <Image
        style={{
          resizeMode: 'cover',
          borderRadius: 10,
          overlayColor: Colors.white,
          width: 300,
          maxWidth: '100%',
          height: (chat?.mediaHeight * 300) / chat?.mediaWidth,
        }}
        defaultSource={require('@/files/placeholder_600.jpg')}
        source={{uri: getFileURL(chat?.fileURL)}}
      />
      {open && (
        <FullScreenPictureModal
          open={open}
          setOpen={setOpen}
          uri={getFileURL(chat?.fileURL)}
          width={chat?.mediaWidth}
          height={chat?.mediaHeight}
        />
      )}
    </Pressable>
  );
}

function StickerViewer({chat}) {
  return (
    <Image
      style={{
        resizeMode: 'cover',
        width: 150,
        height: 150,
        borderRadius: 5,
      }}
      defaultSource={require('@/files/placeholder_200.jpg')}
      source={{uri: `${env.LINK_CLOUD_STICKER}/${chat?.sticker}`}}
    />
  );
}

function getMessageType(chat) {
  if (chat?.text) return 'text';
  if (chat.fileType?.includes('image')) return 'picture';
  if (chat.fileType?.includes('video')) return 'video';
  if (chat.fileType?.includes('audio')) return 'audio';
  if (chat.sticker) return 'sticker';
  return 'file';
}

export default function Message({
  chat,
  previousSameSender,
  previousMessageDate,
  index,
  children,
}) {
  const {userdata, user} = useUser();

  const senderIsUser = chat?.senderId === user?.uid;
  const {value: recipient} = useUserById(chat?.senderId);

  const sender = senderIsUser ? userdata : recipient;

  const [visible, setVisible] = React.useState(false);
  const [position, setPosition] = React.useState({x: 0, y: 0});

  const messageType = getMessageType(chat);
  const isText = messageType === 'text';

  const prevCreatedAt = new Date(previousMessageDate);
  const createdAt = new Date(chat?.createdAt);
  const displayProfilePicture = React.useMemo(
    () =>
      !previousSameSender ||
      (index + 1) % 30 === 0 ||
      (previousSameSender &&
        prevCreatedAt &&
        createdAt &&
        createdAt?.getTime() - prevCreatedAt?.getTime() > 600000),
    [previousSameSender, index, prevCreatedAt, createdAt],
  );

  return (
    <View>
      {children}
      <Pressable
        key={chat?.objectId}
        onLongPress={
          senderIsUser
            ? ({nativeEvent}) => {
                setPosition({
                  x: Number(nativeEvent.pageX.toFixed(2)),
                  y: Number(nativeEvent.pageY.toFixed(2)),
                });
                setVisible(true);
              }
            : undefined
        }
        style={{display: 'flex', flexDirection: 'row', marginTop: 8}}>
        {/* PROFILE PICTURE LEFT PART */}
        <View
          style={{
            width: 55,
            display: 'flex',
            alignItems: 'flex-start',
            justifyContent: 'flex-start',
          }}>
          {displayProfilePicture && (
            <Image
              style={[styles.image]}
              source={
                sender?.thumbnailURL
                  ? {uri: getFileURL(sender?.thumbnailURL)}
                  : require('@/files/blank_user.png')
              }
            />
          )}
        </View>

        {/* MESSAGE RIGHT PART */}
        <View style={{flex: 1}}>
          {/* MESSAGE HEADER */}
          {displayProfilePicture && (
            <View
              style={{
                display: 'flex',
                flexDirection: 'row',
                alignItems: 'flex-end',
                ...(messageType !== 'text' && {paddingBottom: 8}),
              }}>
              <Text
                style={{
                  paddingRight: 5,
                  fontWeight: 'bold',
                  fontSize: 15,
                  color: Colors.black,
                }}>
                {sender?.displayName}
              </Text>
              <Text style={{fontSize: 12, paddingBottom: 2}}>
                {new Date(chat?.createdAt)
                  ?.toLocaleTimeString()
                  .replace(/:\d+ /, ' ')
                  .slice(0, -3)}
              </Text>
            </View>
          )}

          {messageType === 'picture' && (
            <ImageViewer
              chat={chat}
              {...(senderIsUser && {setPosition, setVisible})}
            />
          )}
          {messageType === 'video' && (
            <VideoPlayer
              chat={chat}
              {...(senderIsUser && {setPosition, setVisible})}
            />
          )}
          {messageType === 'audio' && (
            <AudioPlayer
              chat={chat}
              {...(senderIsUser && {setPosition, setVisible})}
            />
          )}
          {messageType === 'sticker' && <StickerViewer chat={chat} />}
          {isText && <Text style={styles.text}>{removeHtml(chat?.text)}</Text>}
          {messageType === 'file' && (
            <Text style={styles.textItalic}>
              {chat?.fileName} cannot be displayed on mobile.
            </Text>
          )}
        </View>
      </Pressable>

      <MessageHoverMenu
        visible={visible}
        setVisible={setVisible}
        position={position}
        chat={chat}
      />
    </View>
  );
}

const styles = StyleSheet.create({
  rowStyle: {
    margin: 0,
    width: '77%',
    marginVertical: 5,
    flexDirection: 'row',
    justifyContent: 'center',
  },
  text: {
    fontSize: 15,
    letterSpacing: 0,
    fontWeight: '400',
    textAlign: 'left',
    color: Colors.black,
  },
  textItalic: {
    fontSize: 15,
    letterSpacing: 0,
    fontWeight: '400',
    textAlign: 'left',
    color: Colors.grey600,
    fontStyle: 'italic',
  },
  image: {
    width: 38,
    height: 38,
    marginLeft: 5,
    borderRadius: 5,
    alignItems: 'center',
    justifyContent: 'center',
  },
  touchable: {
    padding: 4,
    paddingHorizontal: 8,
    minWidth: 10,
    elevation: 2,
    height: 'auto',
    maxWidth: '100%',
    marginRight: 0,
    borderRadius: 10,
    flexDirection: 'row',
    alignItems: 'center',
  },
});
