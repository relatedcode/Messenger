import {env} from '@/config/env';
import {useModal} from '@/contexts/ModalContext';
import {useParams} from '@/contexts/ParamsContext';
import {showAlert} from '@/lib/alert';
import {postData} from '@/lib/api-helpers';
import {modalStyles} from '@/styles/styles';
import React from 'react';
import {FlatList, Image, Modal, TouchableOpacity, View} from 'react-native';
import {Appbar, Divider} from 'react-native-paper';

export default function StickersModal() {
  const {openStickers: open, setOpenStickers: setOpen} = useModal();
  const {chatId, workspaceId, chatType} = useParams();

  // create numbers usng useMemo
  const numbers = React.useMemo(
    () => Array.from(Array(78).keys()).map(i => `0${i + 1}`.slice(-2)),
    [],
  );
  const stickers = React.useMemo(
    () => numbers.map(i => `sticker${i}.png`),
    [numbers],
  );

  const sendSticker = async sticker => {
    try {
      postData('/messages', {
        chatId,
        workspaceId,
        chatType,
        sticker,
      });
      setOpen(false);
    } catch (err) {
      showAlert(err.message);
    }
  };

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
            <Appbar.Content title="Send stickers" />
          </Appbar.Header>
          <FlatList
            numColumns={2}
            horizontal={false}
            data={stickers}
            ListHeaderComponent={() => (
              <Divider style={{height: 10, opacity: 0}} />
            )}
            ListFooterComponent={() => (
              <Divider style={{height: 10, opacity: 0}} />
            )}
            renderItem={({item}) => (
              <TouchableOpacity
                onPress={() => sendSticker(item)}
                style={{padding: 5}}>
                <Image
                  style={{
                    resizeMode: 'cover',
                    width: 150,
                    height: 150,
                  }}
                  source={{uri: `${env.LINK_CLOUD_STICKER}/${item}`}}
                />
              </TouchableOpacity>
            )}
            keyExtractor={item => item}
          />
        </View>
      </View>
    </Modal>
  );
}
