import OpenSearchButton from '@/components/OpenSearchButton';
import PresenceIndicator from '@/components/PresenceIndicator';
import {useChannels} from '@/contexts/ChannelsContext';
import {useDetailByChat} from '@/contexts/DetailsContext';
import {
  useDirectMessages,
  useDirectRecipient,
} from '@/contexts/DirectMessagesContext';
import {useModal} from '@/contexts/ModalContext';
import {useParams} from '@/contexts/ParamsContext';
import {getFileURL} from '@/lib/storage';
import {usePresenceByUserId} from '@/lib/usePresence';
import Fontisto from '@expo/vector-icons/Fontisto';
import {useNavigation} from '@react-navigation/native';
import React from 'react';
import {Image, ScrollView, View} from 'react-native';
import {Colors, List} from 'react-native-paper';

function ChannelItem({channel}) {
  const navigation = useNavigation();
  const {setChatId, setChatType} = useParams();

  const {value: detail} = useDetailByChat(channel?.objectId);

  const notifications = channel
    ? channel.lastMessageCounter - (detail?.lastRead || 0)
    : 0;

  return (
    <List.Item
      key={channel.objectId}
      title={channel.name}
      titleStyle={{
        color: Colors.grey800,
        fontWeight: notifications > 0 ? 'bold' : 'normal',
      }}
      left={props => (
        <List.Icon
          {...props}
          icon={() => <Fontisto name="hashtag" size={15} />}
        />
      )}
      onPress={() => {
        setChatId(channel.objectId);
        setChatType('Channel');
        navigation.navigate('Chat', {
          objectId: channel.objectId,
        });
      }}
    />
  );
}

function DirectMessageItem({direct}) {
  const navigation = useNavigation();
  const {setChatId, setChatType} = useParams();
  const {value: otherUser, isMe} = useDirectRecipient(direct?.objectId);
  const {isPresent} = usePresenceByUserId(otherUser?.objectId);

  const {value: detail} = useDetailByChat(direct?.objectId);

  const notifications = direct
    ? direct.lastMessageCounter - (detail?.lastRead || 0)
    : 0;

  return (
    <List.Item
      key={direct.objectId}
      title={`${otherUser?.displayName}${isMe ? ' (you)' : ''}`}
      titleStyle={{
        color: Colors.grey800,
        fontWeight: notifications > 0 ? 'bold' : 'normal',
      }}
      left={props => (
        <List.Icon
          {...props}
          icon={() => (
            <View style={{position: 'relative'}}>
              <Image
                style={{
                  width: 30,
                  height: 30,
                  borderRadius: 5,
                }}
                source={
                  otherUser?.thumbnailURL
                    ? {uri: getFileURL(otherUser.thumbnailURL)}
                    : require('@/files/blank_user.png')
                }
              />
              <PresenceIndicator isPresent={isPresent} />
            </View>
          )}
        />
      )}
      onPress={() => {
        setChatId(direct.objectId);
        setChatType('Direct');
        navigation.navigate('Chat', {
          objectId: direct.objectId,
        });
      }}
    />
  );
}

export default function Home() {
  const {value: channels} = useChannels();
  const {value: directs} = useDirectMessages();
  const {setOpenChannelBrowser, setOpenMemberBrowser} = useModal();

  const [channelsExpanded, setChannelsExpanded] = React.useState(true);
  const [directsExpanded, setDirectsExpanded] = React.useState(true);

  return (
    <ScrollView style={{flex: 1, backgroundColor: Colors.white}}>
      <OpenSearchButton />
      <List.Section title="">
        <List.Accordion
          title="Channels"
          expanded={channelsExpanded}
          style={{backgroundColor: Colors.white}}
          titleStyle={{color: Colors.grey800}}
          onPress={() => setChannelsExpanded(!channelsExpanded)}>
          {channels.map(channel => (
            <ChannelItem key={channel.objectId} channel={channel} />
          ))}
          <List.Item
            key="Add channels"
            title="Add channels"
            titleStyle={{color: Colors.grey800}}
            left={props => (
              <List.Icon
                {...props}
                icon={() => <Fontisto name="plus-a" size={15} />}
              />
            )}
            onPress={() => setOpenChannelBrowser(true)}
          />
        </List.Accordion>
        <List.Accordion
          title="Direct messages"
          expanded={directsExpanded}
          style={{backgroundColor: Colors.white}}
          titleStyle={{color: Colors.grey800}}
          onPress={() => setDirectsExpanded(!directsExpanded)}>
          {directs.map(direct => (
            <DirectMessageItem key={direct.objectId} direct={direct} />
          ))}
          <List.Item
            key="Add members"
            title="Add members"
            titleStyle={{color: Colors.grey800}}
            left={props => (
              <List.Icon
                {...props}
                icon={() => <Fontisto name="plus-a" size={15} />}
              />
            )}
            onPress={() => setOpenMemberBrowser(true)}
          />
        </List.Accordion>
      </List.Section>
    </ScrollView>
  );
}
