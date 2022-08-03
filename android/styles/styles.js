import {StyleSheet} from 'react-native';
import {Colors} from 'react-native-paper';

export const globalStyles = StyleSheet.create({
  input: {
    backgroundColor: 'transparent',
    paddingHorizontal: 0,
  },
  divider: {
    backgroundColor: Colors.grey600,
  },
  alignStart: {
    display: 'flex',
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'flex-start',
  },
});

export const buttonStyles = StyleSheet.create({
  divider: {
    paddingVertical: 12,
    paddingHorizontal: 12,
    borderBottomWidth: 0.5,
    borderBottomColor: Colors.grey400,
  },
  label: {
    color: Colors.grey900,
    textTransform: 'none',
    letterSpacing: 0.3,
    fontWeight: '600',
  },
  iconRightView: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
  },
});

export const modalStyles = StyleSheet.create({
  centeredView: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
  },
  modalView: {
    backgroundColor: '#f8fafc',
    alignItems: 'center',
    shadowColor: '#000',
    shadowOffset: {
      width: 0,
      height: 2,
    },
    width: '100%',
    height: '100%',
    shadowOpacity: 0.25,
    shadowRadius: 4,
    elevation: 5,
  },
});
