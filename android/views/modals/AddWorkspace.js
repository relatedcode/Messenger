import {useModal} from '@/contexts/ModalContext';
import {showAlert} from '@/lib/alert';
import {postData} from '@/lib/api-helpers';
import {modalStyles} from '@/styles/styles';
import {useNavigation} from '@react-navigation/native';
import {useFormik} from 'formik';
import {Modal, ScrollView, StyleSheet, View} from 'react-native';
import {Appbar, TextInput} from 'react-native-paper';

export default function AddWorkspaceModal({open, setOpen}) {
  const navigation = useNavigation();
  const {setOpenWorkspaceBrowser} = useModal();

  const {handleSubmit, handleChange, values, resetForm} = useFormik({
    initialValues: {
      name: '',
    },
    enableReinitialize: true,
    onSubmit: async val => {
      try {
        const {workspaceId} = await postData('/workspaces', {
          name: val.name,
        });
        navigation.navigate('Workspace', {
          objectId: workspaceId,
        });
        showAlert('Workspace created successfully');
        resetForm();
        setOpen(false);
        setOpenWorkspaceBrowser(false);
      } catch (err) {
        showAlert(err.message);
      }
    },
  });

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
            <Appbar.Content title="New workspace" />
            <Appbar.Action icon="check" onPress={handleSubmit} />
          </Appbar.Header>
          <ScrollView
            style={{
              width: '100%',
              height: '100%',
              paddingHorizontal: 20,
            }}>
            <TextInput
              label="Workspace name"
              style={styles.input}
              onChangeText={handleChange('name')}
              value={values.name}
              dense
            />
          </ScrollView>
        </View>
      </View>
    </Modal>
  );
}

const styles = StyleSheet.create({
  input: {
    marginTop: 10,
    backgroundColor: 'transparent',
    paddingHorizontal: 0,
  },
});
