import {useModal} from '@/contexts/ModalContext';
import {Colors, Text, TouchableRipple} from 'react-native-paper';

export default function OpenSearchButton() {
  const {setOpenSearch} = useModal();
  return (
    <TouchableRipple
      onPress={() => setOpenSearch(true)}
      borderless
      style={{
        margin: 10,
        borderRadius: 5,
      }}>
      <Text
        style={{
          color: Colors.grey600,
          borderWidth: 0.5,
          borderRadius: 5,
          padding: 8,
          borderColor: Colors.grey400,
          backgroundColor: Colors.white,
        }}>
        Jump to...
      </Text>
    </TouchableRipple>
  );
}
