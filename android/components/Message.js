import MessageHoverMenu from '@/components/MessageHoverMenu';
import {useUser} from '@/contexts/UserContext';
import {useUserById} from '@/contexts/UsersContext';
import {convertMsToTime, removeHTML} from '@/lib/convert';
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
        justifyContent: 'center',
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
        <MaterialIcons name="pause" size={24} style={{color: Colors.white}} />
      )}
      {!status?.isPlaying && (
        <MaterialIcons
          name="play-arrow"
          size={24}
          style={{color: Colors.white}}
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
          color={Colors.white}
        />
        <Text style={{color: Colors.white, fontSize: 11, textAlign: 'left'}}>
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
          width: 500,
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

// function StickerViewer({chat}) {
//   return (
//     <Image
//       style={{
//         resizeMode: 'cover',
//         width: 250,
//         height: 250,
//         borderRadius: 10,
//       }}
//       defaultSource={require('@/files/placeholder_600.jpg')}
//       source={getStickerURI(chat?.sticker)}
//     />
//   );
// }

function Received({chat}) {
  const {value: recipient} = useUserById(chat?.senderId);

  const messageType = getMessageType(chat);
  const isText = messageType === 'text';
  const displayBubble =
    messageType !== 'picture' &&
    messageType !== 'sticker' &&
    messageType !== 'video';

  return (
    <View
      style={[
        styles.rowStyle,
        {
          alignItems: 'flex-end',
          marginRight: 'auto',
        },
      ]}>
      {/* PROFILE PICTURE */}
      <Image
        style={[
          styles.image,
          {
            marginLeft: 0,
            marginRight: 4,
          },
        ]}
        source={
          recipient?.thumbnailURL
            ? {uri: getFileURL(recipient?.thumbnailURL)}
            : require('@/files/blank_user.png')
        }
      />

      {/* MESSAGE BUBBLE */}
      <View
        style={
          displayBubble
            ? [
                styles.touchable,
                {
                  justifyContent: 'flex-start',
                  marginRight: 'auto',
                  backgroundColor: 'orange',
                },
              ]
            : {justifyContent: 'flex-start', marginRight: 'auto'}
        }>
        {messageType === 'picture' && <ImageViewer chat={chat} />}
        {messageType === 'video' && <VideoPlayer chat={chat} />}
        {messageType === 'audio' && <AudioPlayer chat={chat} />}
        {/* {messageType === 'sticker' && <StickerViewer chat={chat} />} */}
        {isText && <Text style={styles.text}>{removeHTML(chat?.text)}</Text>}
      </View>
    </View>
  );
}

function getMessageType(chat) {
  if (chat.fileType?.includes('image')) return 'picture';
  if (chat.fileType?.includes('video')) return 'video';
  if (chat.fileType?.includes('audio')) return 'audio';
  if (chat.sticker) return 'sticker';
  return 'text';
}

function Sent({chat}) {
  const {userdata} = useUser();

  const [visible, setVisible] = React.useState(false);
  const [position, setPosition] = React.useState({x: 0, y: 0});

  const messageType = getMessageType(chat);
  const isText = messageType === 'text';
  const displayBubble =
    messageType !== 'picture' &&
    messageType !== 'sticker' &&
    messageType !== 'video';

  return (
    <View
      style={[
        styles.rowStyle,
        {
          alignItems: 'flex-end',
          marginLeft: 'auto',
        },
      ]}>
      {/* MESSAGE BUBBLE */}
      <Pressable
        key={chat?.objectId}
        onLongPress={({nativeEvent}) => {
          setPosition({
            x: Number(nativeEvent.pageX.toFixed(2)),
            y: Number(nativeEvent.pageY.toFixed(2)),
          });
          setVisible(true);
        }}
        style={
          displayBubble
            ? [
                styles.touchable,
                {
                  justifyContent: 'flex-end',
                  marginLeft: 'auto',
                  backgroundColor: '#218aff',
                },
              ]
            : {justifyContent: 'flex-end', marginLeft: 'auto'}
        }>
        {messageType === 'picture' && (
          <ImageViewer
            chat={chat}
            setPosition={setPosition}
            setVisible={setVisible}
          />
        )}
        {messageType === 'video' && (
          <VideoPlayer
            chat={chat}
            setPosition={setPosition}
            setVisible={setVisible}
          />
        )}
        {messageType === 'audio' && (
          <AudioPlayer
            chat={chat}
            setPosition={setPosition}
            setVisible={setVisible}
          />
        )}
        {/* {messageType === 'sticker' && <StickerViewer chat={chat} />} */}
        {isText && <Text style={styles.text}>{removeHTML(chat?.text)}</Text>}
      </Pressable>

      {/* PROFILE PICTURE */}
      <View
        style={{
          alignItems: 'flex-end',
        }}>
        <Image
          style={[
            styles.image,
            {
              marginLeft: 4,
              marginRight: 0,
            },
          ]}
          source={
            userdata?.thumbnailURL
              ? {uri: getFileURL(userdata?.thumbnailURL)}
              : require('@/files/blank_user.png')
          }
        />
      </View>

      <MessageHoverMenu
        visible={visible}
        setVisible={setVisible}
        position={position}
        chat={chat}
      />
    </View>
  );
}

export default function Message({chat}) {
  const {user} = useUser();

  return chat?.senderId === user?.uid ? (
    <Sent chat={chat} />
  ) : (
    <Received chat={chat} />
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
    padding: 4,
    fontSize: 15,
    letterSpacing: 0,
    fontWeight: '400',
    textAlign: 'left',
    color: 'white',
  },
  image: {
    width: 25,
    height: 25,
    borderRadius: 50,
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
