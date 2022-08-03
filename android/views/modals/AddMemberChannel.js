import {useParams} from '@/contexts/ParamsContext';
import {showAlert} from '@/lib/alert';
import {postData} from '@/lib/api-helpers';
import {modalStyles} from '@/styles/styles';
import {useFormik} from 'formik';
import {Modal, ScrollView, StyleSheet, View} from 'react-native';
import {Appbar, TextInput} from 'react-native-paper';

export default function AddMemberChannelModal({open, setOpen}) {
  const {chatId} = useParams();

  const {handleSubmit, handleChange, values, resetForm} = useFormik({
    initialValues: {
      email: '',
    },
    enableReinitialize: true,
    onSubmit: async val => {
      try {
        await postData(`/channels/${chatId}/members`, {
          email: val.email,
        });
        showAlert('Member added successfully');
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
            <Appbar.Content title="Add people" />
            <Appbar.Action icon="plus" onPress={handleSubmit} />
          </Appbar.Header>
          <ScrollView
            style={{
              width: '100%',
              height: '100%',
              paddingHorizontal: 20,
            }}>
            <TextInput
              label="Email address"
              keyboardType="email-address"
              autoCapitalize="none"
              autoComplete="email"
              style={styles.input}
              onChangeText={handleChange('email')}
              value={values.email}
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
