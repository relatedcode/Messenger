import {showAlert} from '@/lib/alert';
import {deleteData} from '@/lib/api-helpers';
import * as Clipboard from 'expo-clipboard';
import {Menu} from 'react-native-paper';

export default function MessageHoverMenu({
  visible,
  setVisible,
  position,
  chat,
}) {
  const copyToClipboard = async () => {
    await Clipboard.setStringAsync(chat.text);
    setVisible(false);
  };

  const deleteMessage = async () => {
    try {
      setVisible(false);
      await deleteData(`/messages/${chat?.objectId}`);
    } catch (err) {
      showAlert(err.message);
    }
  };

  return (
    <Menu
      visible={visible}
      onDismiss={() => setVisible(false)}
      anchor={position}>
      {chat?.type === 'text' && (
        <Menu.Item onPress={copyToClipboard} title="Copy" />
      )}
      <Menu.Item onPress={deleteMessage} title="Delete" />
    </Menu>
  );
}
