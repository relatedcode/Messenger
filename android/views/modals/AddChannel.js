import {useParams} from '@/contexts/ParamsContext';
import {showAlert} from '@/lib/alert';
import {postData} from '@/lib/api-helpers';
import {modalStyles} from '@/styles/styles';
import {useNavigation} from '@react-navigation/native';
import {useFormik} from 'formik';
import {Modal, ScrollView, StyleSheet, View} from 'react-native';
import {Appbar, TextInput} from 'react-native-paper';

export default function AddChannelModal({open, setOpen}) {
  const {workspaceId, setChatId, setChatType} = useParams();
  const navigation = useNavigation();

  const {handleSubmit, handleChange, values, resetForm} = useFormik({
    initialValues: {
      name: '',
    },
    enableReinitialize: true,
    onSubmit: async val => {
      try {
        const {channelId} = await postData('/channels', {
          name: val.name,
          workspaceId,
        });
        setChatId(channelId);
        setChatType('Channel');
        navigation.navigate('Chat', {
          objectId: channelId,
        });
        showAlert('Channel created successfully');
        resetForm();
        setOpen(false);
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
            <Appbar.Content title="New channel" />
            <Appbar.Action icon="check" onPress={handleSubmit} />
          </Appbar.Header>
          <ScrollView
            style={{
              width: '100%',
              height: '100%',
              paddingHorizontal: 20,
            }}>
            <TextInput
              label="Channel name"
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
