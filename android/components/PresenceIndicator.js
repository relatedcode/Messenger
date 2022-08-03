import {View} from 'react-native';
import {Colors} from 'react-native-paper';

export default function PresenceIndicator({isPresent, absolute = true, style}) {
  return (
    <View
      style={{
        ...(absolute && {position: 'absolute'}),
        display: 'flex',
        alignItems: 'center',
        justifyContent: 'center',
        bottom: 0,
        right: 0,
        zIndex: 1,
        width: 12,
        height: 12,
        backgroundColor: Colors.white,
        borderRadius: 10,
        padding: 1,
        transform: [{translateX: +3}, {translateY: +3}],
        ...style,
      }}>
      <View
        style={{
          width: 9,
          height: 9,
          backgroundColor: isPresent ? Colors.green500 : Colors.white,
          borderRadius: 10,
          ...(!isPresent && {
            borderWidth: 1,
            borderColor: Colors.grey500,
          }),
        }}
      />
    </View>
  );
}
