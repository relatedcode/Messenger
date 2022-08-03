import icon from '@/components/icon';
import {useModal} from '@/contexts/ModalContext';
import {useUser} from '@/contexts/UserContext';
import {showAlert} from '@/lib/alert';
import {postData} from '@/lib/api-helpers';
import {now} from '@/lib/auth';
import {getFileURL, uploadFile} from '@/lib/storage';
import {modalStyles} from '@/styles/styles';
import {useActionSheet} from '@expo/react-native-action-sheet';
import * as ImagePicker from 'expo-image-picker';
import {useFormik} from 'formik';
import React from 'react';
import {Image, Modal, ScrollView, StyleSheet, View} from 'react-native';
import * as mime from 'react-native-mime-types';
import {Appbar, TextInput, TouchableRipple} from 'react-native-paper';

export default function ProfileModal() {
  const {openProfile: open, setOpenProfile: setOpen} = useModal();
  const {userdata} = useUser();
  const [image, setImage] = React.useState(null);
  const {showActionSheetWithOptions} = useActionSheet();

  const selectAction = () => {
    showActionSheetWithOptions(
      {
        icons: [icon('insert-photo'), icon('camera-alt'), icon('close')],
        options: ['Pick an image', 'Take a picture', 'Cancel'],
        cancelButtonIndex: 2,
        useModal: true,
      },
      buttonIndex => {
        if (buttonIndex === 0) {
          pickImage();
        } else if (buttonIndex === 1) {
          lauchCamera();
        } else if (buttonIndex === 2) {
          // cancel
        }
      },
    );
  };

  const {handleSubmit, handleChange, values, resetForm} = useFormik({
    initialValues: {
      fullName: userdata?.fullName,
      displayName: userdata?.displayName,
      title: userdata?.title,
      phoneNumber: userdata?.phoneNumber,
    },
    enableReinitialize: true,
    onSubmit: async val => {
      await postData(`/users/${userdata.objectId}`, {
        fullName: val.fullName,
        displayName: val.displayName,
        title: val.title,
        phoneNumber: val.phoneNumber,
      });
      showAlert('Profile updated successfully');
      setOpen(false);
    },
  });

  const handlePickerResult = async result => {
    if (!result.cancelled) {
      // Get file name from URI
      const fileName = result.uri.split('/').pop();

      const fileType = mime.lookup(result.uri);

      const filePath = await uploadFile(
        'messenger',
        `User/${userdata.objectId}/${now()}_photo`,
        result.uri,
        fileType,
        fileName,
      );

      await postData(`/users/${userdata?.objectId}`, {
        photoPath: filePath,
      });

      showAlert('Photo updated successfully');
    }
  };

  const pickImage = async () => {
    const result = await ImagePicker.launchImageLibraryAsync({
      mediaTypes: ImagePicker.MediaTypeOptions.Images,
      allowsEditing: true,
      aspect: [3, 3],
      quality: 1,
    });
    await handlePickerResult(result);
  };

  const lauchCamera = async () => {
    const result = await ImagePicker.launchCameraAsync({
      mediaTypes: ImagePicker.MediaTypeOptions.Images,
      allowsEditing: true,
      aspect: [3, 3],
      quality: 1,
    });
    await handlePickerResult(result);
  };

  React.useEffect(() => {
    resetForm();
    setImage(null);
  }, [open]);

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
            <Appbar.Content title="Edit Profile" />
            <Appbar.Action icon="check" onPress={handleSubmit} />
          </Appbar.Header>
          <ScrollView
            style={{
              width: '100%',
              height: '100%',
              paddingHorizontal: 20,
            }}>
            <TouchableRipple
              onPress={selectAction}
              style={{
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'center',
                width: '100%',
                marginVertical: 20,
              }}>
              <Image
                style={{
                  width: 80,
                  height: 80,
                  borderRadius: 50,
                }}
                source={
                  userdata?.photoURL || image
                    ? {uri: image || getFileURL(userdata?.photoURL)}
                    : require('@/files/blank_user.png')
                }
              />
            </TouchableRipple>

            <TextInput
              label="Full name"
              style={styles.input}
              onChangeText={handleChange('fullName')}
              value={values.fullName}
              dense
            />

            <TextInput
              label="Display name"
              style={styles.input}
              onChangeText={handleChange('displayName')}
              value={values.displayName}
              dense
            />

            <TextInput
              label="What I do"
              style={styles.input}
              onChangeText={handleChange('title')}
              value={values.title}
              dense
            />

            <TextInput
              label="Phone Number"
              style={styles.input}
              value={values.phoneNumber}
              onChangeText={handleChange('phoneNumber')}
              keyboardType="numeric"
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
