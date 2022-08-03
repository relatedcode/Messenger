import {useParams} from '@/contexts/ParamsContext';
import {postData} from '@/lib/api-helpers';
import {debounce} from 'lodash';
import React from 'react';
import {StyleSheet, TextInput} from 'react-native';
import {Colors} from 'react-native-paper';

const resetTyping = debounce(setTyping => {
  setTyping(false);
}, 3000);

const Input = ({text, setText, isSubmitting}) => {
  const {chatId, chatType} = useParams();
  const [typing, setTyping] = React.useState(false);

  const resetTypingDebounce = React.useCallback(() => {
    resetTyping(setTyping);
  }, []);

  React.useEffect(() => {
    let interval;
    const type = chatType === 'Direct' ? 'directs' : 'channels';
    const id = chatId;

    if (typing && !isSubmitting) {
      postData(
        `/${type}/${id}/typing_indicator`,
        {
          isTyping: true,
        },
        {},
        false,
      );
      interval = setInterval(() => {
        postData(
          `/${type}/${id}/typing_indicator`,
          {
            isTyping: true,
          },
          {},
          false,
        );
      }, 3000);
    } else {
      setTyping(false);
      clearInterval(interval);
      postData(
        `/${type}/${id}/typing_indicator`,
        {
          isTyping: false,
        },
        {},
        false,
      );
    }
    return () => clearInterval(interval);
  }, [typing, isSubmitting]);

  React.useEffect(() => {
    const type = chatType === 'Direct' ? 'directs' : 'channels';
    const id = chatId;
    return () => {
      setTyping(false);
      postData(
        `/${type}/${id}/typing_indicator`,
        {
          isTyping: false,
        },
        {},
        false,
      );
    };
  }, []);

  return (
    <TextInput
      value={text}
      onChangeText={t => {
        setText('text', t);
        setTyping(true);
        resetTypingDebounce();
      }}
      style={styles.textInput}
      placeholder="Aa"
      multiline
      placeholderTextColor={Colors.grey400}
    />
  );
};

const styles = StyleSheet.create({
  textInput: {
    width: '75%',
    minHeight: 40,
    maxHeight: 100,
    margin: 0,
    padding: 12,
    paddingTop: 0,
    paddingBottom: 0,
    fontSize: 17,
    letterSpacing: 0,
    fontWeight: '400',
    alignItems: 'center',
  },
});

export default Input;
