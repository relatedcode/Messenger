import {useChannelById} from '@/contexts/ChannelsContext';
import {useParams} from '@/contexts/ParamsContext';
import {showAlert} from '@/lib/alert';
import {postData} from '@/lib/api-helpers';
import {modalStyles} from '@/styles/styles';
import {useFormik} from 'formik';
import {Modal, ScrollView, StyleSheet, View} from 'react-native';
import {Appbar, TextInput} from 'react-native-paper';

export default function EditChannelDetailsModal({open, setOpen}) {
  const {chatId} = useParams();

  const {value: channel} = useChannelById(chatId);

  const {handleSubmit, handleChange, values, resetForm} = useFormik({
    initialValues: {
      topic: channel?.topic,
      details: channel?.details,
    },
    enableReinitialize: true,
    onSubmit: async val => {
      await postData(`/channels/${chatId}`, {
        topic: val.topic,
        details: val.details,
      });
      showAlert('Channel updated successfully');
      resetForm();
      setOpen(false);
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
            <Appbar.Content title="Edit channel" />
            <Appbar.Action icon="check" onPress={handleSubmit} />
          </Appbar.Header>
          <ScrollView
            style={{
              width: '100%',
              height: '100%',
              paddingHorizontal: 20,
            }}>
            <TextInput
              label="Description"
              style={styles.input}
              onChangeText={handleChange('details')}
              value={values.details}
              dense
            />
            <TextInput
              label="Topic"
              style={styles.input}
              onChangeText={handleChange('topic')}
              value={values.topic}
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
