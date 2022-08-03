import {MaterialIcons} from '@expo/vector-icons';
import React from 'react';
import {Colors} from 'react-native-paper';

export default function icon(name) {
  return (
    <MaterialIcons
      key={name}
      name={name}
      size={24}
      style={{color: Colors.grey900}}
    />
  );
}
