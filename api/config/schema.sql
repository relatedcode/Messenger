create table if not exists "channels"(
  "objectId" varchar(255) primary key,
  "createdBy" varchar(255) not null,
  "details" text,
  "isArchived" boolean not null default false,
  "lastMessageCounter" integer not null default 0,
  "lastMessageText" text,
  "lastTypingReset" timestamptz not null default now(),
  "members" text[] not null,
  "name" varchar(255) not null,
  "topic" text,
  "typing" text[],
  "workspaceId" varchar(255) not null,
  "isDeleted" boolean not null default false,
  "createdAt" timestamptz not null default now(),
  "updatedAt" timestamptz not null default now()
);

create table if not exists "details"(
  "objectId" varchar(255) primary key,
  "chatId" varchar(255) not null,
  "lastRead" integer not null default 0,
  "userId" varchar(255) not null,
  "workspaceId" varchar(255) not null,
  "createdAt" timestamptz not null default now(),
  "updatedAt" timestamptz not null default now()
);

create table if not exists "directs"(
  "objectId" varchar(255) primary key,
  "active" text[],
  "lastMessageCounter" integer not null default 0,
  "lastMessageText" text,
  "lastTypingReset" timestamptz not null default now(),
  "members" text[] not null,
  "typing" text[],
  "workspaceId" varchar(255) not null,
  "createdAt" timestamptz not null default now(),
  "updatedAt" timestamptz not null default now()
);

create table if not exists "messages"(
  "objectId" varchar(255) primary key,
  "chatId" varchar(255) not null,
  "chatType" varchar(255) not null,
  "counter" integer not null default 0,
  "fileName" varchar(255),
  "fileSize" integer,
  "fileType" varchar(255),
  "fileURL" varchar(255),
  "isDeleted" boolean not null default false,
  "isEdited" boolean not null default false,
  "mediaDuration" integer,
  "mediaHeight" integer,
  "mediaWidth" integer,
  "senderId" varchar(255) not null,
  "sticker" varchar(255),
  "text" text,
  "type" varchar(255) not null,
  "thumbnailURL" varchar(255),
  "workspaceId" varchar(255) not null,
  "createdAt" timestamptz not null default now(),
  "updatedAt" timestamptz not null default now()
);

create table if not exists "presences"(
  "objectId" varchar(255) primary key,
  "lastPresence" timestamptz not null default now(),
  "createdAt" timestamptz not null default now(),
  "updatedAt" timestamptz not null default now()
);

create table if not exists "users"(
  "objectId" varchar(255) primary key,
  "displayName" varchar(255),
  "email" varchar(255) not null unique,
  "fullName" varchar(255),
  "phoneNumber" varchar(255),
  "photoURL" varchar(255),
  "theme" varchar(255),
  "thumbnailURL" varchar(255),
  "title" varchar(255),
  "workspaces" text[],
  "createdAt" timestamptz not null default now(),
  "updatedAt" timestamptz not null default now()
);

create table if not exists "workspaces"(
  "objectId" varchar(255) primary key,
  "channelId" varchar(255) not null,
  "details" text,
  "isDeleted" boolean not null default false,
  "members" text[],
  "name" varchar(255) not null,
  "ownerId" varchar(255) not null,
  "photoURL" varchar(255),
  "thumbnailURL" varchar(255),
  "createdAt" timestamptz not null default now(),
  "updatedAt" timestamptz not null default now()
);

create table if not exists "reactions"(
  "objectId" varchar(255) primary key,
  "chatId" varchar(255) not null,
  "messageId" varchar(255) not null,
  "userId" varchar(255) not null,
  "workspaceId" varchar(255) not null,
  "reaction" varchar(255),
  "createdAt" timestamptz not null default now(),
  "updatedAt" timestamptz not null default now()
);