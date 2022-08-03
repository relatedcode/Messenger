import {modalStyles} from '@/styles/styles';
import {Video} from 'expo-av';
import React from 'react';
import {ActivityIndicator, Modal, View} from 'react-native';
import {Appbar, Colors} from 'react-native-paper';

export default function VideoModal({open, setOpen, uri}) {
  const video = React.useRef(null);
  const [loading, setLoading] = React.useState(true);

  return (
    <Modal
      animationType="fade"
      transparent={true}
      visible={open}
      onRequestClose={() => {
        setOpen(!open);
      }}>
      <View style={modalStyles.centeredView}>
        <View style={modalStyles.modalView}>
          <Appbar.Header
            statusBarHeight={0}
            style={{
              width: '100%',
              backgroundColor: '#fff',
            }}>
            <Appbar.Action icon="window-close" onPress={() => setOpen(!open)} />
            <Appbar.Content title="" />
          </Appbar.Header>

          {loading && (
            <ActivityIndicator
              style={{position: 'absolute', top: 60}}
              size={30}
            />
          )}

          <Video
            ref={video}
            style={{flex: 1, width: '100%', backgroundColor: Colors.white}}
            shouldPlay
            source={{
              uri,
            }}
            onLoad={() => {
              setLoading(false);
            }}
            onError={err => {
              console.log('Loading error: ', err);
            }}
            useNativeControls
            resizeMode="contain"
          />
        </View>
      </View>
    </Modal>
  );
}
