import {modalStyles} from '@/styles/styles';
import {Image, Modal, View} from 'react-native';
import {Appbar} from 'react-native-paper';

export default function FullScreenPictureModal({
  open,
  setOpen,
  uri,
  width,
  height,
}) {
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
          <View
            style={{flex: 1, alignItems: 'center', justifyContent: 'center'}}>
            <Image
              style={{
                resizeMode: 'contain',
                width,
                maxWidth: '100%',
                height,
                maxHeight: '100%',
              }}
              defaultSource={require('@/files/placeholder_600.jpg')}
              source={{uri}}
            />
          </View>
        </View>
      </View>
    </Modal>
  );
}
