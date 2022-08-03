import {useModal} from '@/contexts/ModalContext';
import {modalStyles} from '@/styles/styles';
import {Modal, View} from 'react-native';
import {Appbar} from 'react-native-paper';

export default function PreferencesModal() {
  const {openPreferences: open, setOpenPreferences: setOpen} = useModal();

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
            style={{
              width: '100%',
              backgroundColor: '#fff',
            }}>
            <Appbar.Action icon="window-close" onPress={() => setOpen(!open)} />
            <Appbar.Content title="Preferences" />
          </Appbar.Header>
        </View>
      </View>
    </Modal>
  );
}
