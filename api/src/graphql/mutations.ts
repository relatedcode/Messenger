import { gql } from "graphql-request";

export const CREATE_CHANNEL = gql`
  mutation CreateChannel($input: CreateChannelInput!) {
    createChannel(input: $input) {
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

export const UPDATE_CHANNEL = gql`
  mutation UpdateChannel($input: UpdateChannelInput!) {
    updateChannel(input: $input) {
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

export const CREATE_DETAIL = gql`
  mutation CreateDetail($input: CreateDetailInput!) {
    createDetail(input: $input) {
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

export const UPDATE_DETAIL = gql`
  mutation UpdateDetail($input: UpdateDetailInput!) {
    updateDetail(input: $input) {
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

export const CREATE_DIRECT = gql`
  mutation CreateDirect($input: CreateDirectInput!) {
    createDirect(input: $input) {
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

export const UPDATE_DIRECT = gql`
  mutation UpdateDirect($input: UpdateDirectInput!) {
    updateDirect(input: $input) {
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

export const CREATE_MESSAGE = gql`
  mutation CreateMessage($input: CreateMessageInput!) {
    createMessage(input: $input) {
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
      type
      thumbnailURL
      workspaceId
      createdAt
      updatedAt
    }
  }
`;

export const UPDATE_MESSAGE = gql`
  mutation UpdateMessage($input: UpdateMessageInput!) {
    updateMessage(input: $input) {
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
      type
      thumbnailURL
      workspaceId
      createdAt
      updatedAt
    }
  }
`;

export const CREATE_PRESENCE = gql`
  mutation CreatePresence($input: CreatePresenceInput!) {
    createPresence(input: $input) {
      objectId
      lastPresence
      updatedAt
      createdAt
    }
  }
`;

export const UPDATE_PRESENCE = gql`
  mutation UpdatePresence($input: UpdatePresenceInput!) {
    updatePresence(input: $input) {
      objectId
      lastPresence
      updatedAt
      createdAt
    }
  }
`;

export const CREATE_USER = gql`
  mutation CreateUser($input: CreateUserInput!) {
    createUser(input: $input) {
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

export const UPDATE_USER = gql`
  mutation UpdateUser($input: UpdateUserInput!) {
    updateUser(input: $input) {
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

export const CREATE_WORKSPACE = gql`
  mutation CreateWorkspace($input: CreateWorkspaceInput!) {
    createWorkspace(input: $input) {
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

export const UPDATE_WORKSPACE = gql`
  mutation CreateWorkspace($input: UpdateWorkspaceInput!) {
    updateWorkspace(input: $input) {
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

export const CREATE_REACTION = gql`
  mutation CreateReaction($input: CreateReactionInput!) {
    createReaction(input: $input) {
      objectId
      chatId
      messageId
      userId
      workspaceId
      reaction
      createdAt
      updatedAt
    }
  }
`;

export const UPDATE_REACTION = gql`
  mutation UpdateReaction($input: UpdateReactionInput!) {
    updateReaction(input: $input) {
      objectId
      chatId
      messageId
      userId
      workspaceId
      reaction
      createdAt
      updatedAt
    }
  }
`;
