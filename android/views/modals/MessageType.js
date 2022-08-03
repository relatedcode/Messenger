import {useParams} from '@/contexts/ParamsContext';
import {postData} from '@/lib/api-helpers';
import {now} from '@/lib/auth';
import {uploadFile} from '@/lib/storage';
import {MaterialIcons} from '@expo/vector-icons';
import * as ImagePicker from 'expo-image-picker';
import {
  Modal,
  Pressable,
  StyleSheet,
  Text,
  TouchableWithoutFeedback,
  View,
} from 'react-native';
import * as mime from 'react-native-mime-types';
import {Colors, TouchableRipple} from 'react-native-paper';
import {v4 as uuidv4} from 'uuid';

function Button({text, icon, onPress}) {
  return (
    <TouchableRipple onPress={onPress}>
      <View
        style={{
          display: 'flex',
          flexDirection: 'column',
          alignItems: 'center',
          justifyContent: 'center',
          padding: 7,
          width: 80,
          height: 80,
        }}>
        <MaterialIcons
          key={icon}
          name={icon}
          size={30}
          style={{color: Colors.grey900, marginBottom: 2}}
        />
        <Text style={{color: Colors.grey900, fontSize: 16}}>{text}</Text>
      </View>
    </TouchableRipple>
  );
}

export default function MessageTypeModal({open, setOpen, setAudioOpen}) {
  const {chatId, workspaceId, chatType} = useParams();

  const handlePickerResult = async result => {
    if (!result.cancelled) {
      // Get file name from URI
      const fileName = result.uri.split('/').pop();

      const fileType = mime.lookup(result.uri);

      const messageId = uuidv4();

      const filePath = await uploadFile(
        'messenger',
        `Message/${messageId}/${now()}_file`,
        result.uri,
        fileType,
        fileName,
      );

      await postData('/messages', {
        objectId: messageId,
        text: '',
        chatId,
        workspaceId,
        fileName,
        filePath,
        chatType,
      });
    }
  };

  const lauchCamera = async () => {
    setOpen(false);
    const result = await ImagePicker.launchCameraAsync({
      quality: 1,
      mediaTypes: ImagePicker.MediaTypeOptions.All,
    });
    await handlePickerResult(result);
  };

  const pickImage = async () => {
    setOpen(false);
    const result = await ImagePicker.launchImageLibraryAsync({
      mediaTypes: ImagePicker.MediaTypeOptions.Images,
      quality: 1,
    });
    await handlePickerResult(result);
  };

  const pickVideo = async () => {
    setOpen(false);
    const result = await ImagePicker.launchImageLibraryAsync({
      mediaTypes: ImagePicker.MediaTypeOptions.Videos,
      allowsEditing: true,
      quality: 1,
    });
    await handlePickerResult(result);
  };

  return (
    <Modal
      animationType="fade"
      transparent={true}
      visible={open}
      onRequestClose={() => {
        setOpen(!open);
      }}>
      <Pressable onPress={() => setOpen(false)} style={styles.centeredView}>
        <TouchableWithoutFeedback>
          <View style={styles.modalView}>
            <Button text="Camera" icon="camera-alt" onPress={lauchCamera} />
            <Button
              text="Voice"
              icon="keyboard-voice"
              onPress={() => {
                setOpen(false);
                setAudioOpen(true);
              }}
            />
            <Button text="Images" icon="image" onPress={pickImage} />
            <Button
              text="Videos"
              icon="play-circle-outline"
              onPress={pickVideo}
            />
          </View>
        </TouchableWithoutFeedback>
      </Pressable>
    </Modal>
  );
}

const styles = StyleSheet.create({
  centeredView: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor: 'rgba(0,0,0,0.3)',
  },
  modalView: {
    backgroundColor: Colors.grey100,
    alignItems: 'center',
    shadowColor: '#000',
    borderRadius: 10,
    shadowOffset: {
      width: 0,
      height: 2,
    },
    width: 180,
    height: 180,
    padding: 10,
    shadowOpacity: 0.25,
    shadowRadius: 4,
    elevation: 5,
    display: 'flex',
    flexDirection: 'row',
    flexWrap: 'wrap',
    justifyContent: 'center',
  },
});
