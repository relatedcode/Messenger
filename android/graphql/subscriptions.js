import {gql} from '@apollo/client';

export const CHANNEL = gql`
  subscription OnUpdateChannel($objectId: String, $workspaceId: String) {
    onUpdateChannel(objectId: $objectId, workspaceId: $workspaceId) {
      objectId
      createdBy
      details
      isArchived
      isDeleted
      lastMessageCounter
      lastMessageText
      members
      name
      topic
      typing
      workspaceId
      createdAt
      updatedAt
    }
  }
`;

export const USER = gql`
  subscription OnUpdateUser($objectId: String) {
    onUpdateUser(objectId: $objectId) {
      objectId
      displayName
      email
      fullName
      phoneNumber
      photoURL
      theme
      thumbnailURL
      title
      workspaces
      createdAt
      updatedAt
    }
  }
`;

export const WORKSPACE = gql`
  subscription OnUpdateWorkspace($objectId: String) {
    onUpdateWorkspace(objectId: $objectId) {
      objectId
      channelId
      details
      isDeleted
      members
      name
      ownerId
      photoURL
      thumbnailURL
      createdAt
      updatedAt
    }
  }
`;

export const PRESENCE = gql`
  subscription OnUpdatePresence($objectId: String) {
    onUpdatePresence(objectId: $objectId) {
      objectId
      lastPresence
      updatedAt
      createdAt
    }
  }
`;

export const DETAIL = gql`
  subscription OnUpdateDetail(
    $objectId: String
    $workspaceId: String
    $userId: String
  ) {
    onUpdateDetail(
      objectId: $objectId
      workspaceId: $workspaceId
      userId: $userId
    ) {
      objectId
      chatId
      lastRead
      userId
      workspaceId
      createdAt
      updatedAt
    }
  }
`;

export const DIRECT = gql`
  subscription OnUpdateDirect($objectId: String, $workspaceId: String) {
    onUpdateDirect(objectId: $objectId, workspaceId: $workspaceId) {
      objectId
      active
      lastMessageCounter
      lastMessageText
      lastTypingReset
      members
      typing
      workspaceId
      createdAt
      updatedAt
    }
  }
`;

export const MESSAGE = gql`
  subscription OnUpdateMessage($objectId: String, $chatId: String) {
    onUpdateMessage(objectId: $objectId, chatId: $chatId) {
      objectId
      chatId
      chatType
      counter
      fileName
      fileSize
      fileType
      fileURL
      isDeleted
      isEdited
      mediaDuration
      mediaHeight
      mediaWidth
      senderId
      sticker
      text
      thumbnailURL
      workspaceId
      createdAt
      updatedAt
    }
  }
`;
