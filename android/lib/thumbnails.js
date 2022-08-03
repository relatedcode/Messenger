import {getFileURL} from '@/lib/storage';
import AsyncStorage from '@react-native-async-storage/async-storage';
import * as FileSystem from 'expo-file-system';
import * as VideoThumbnails from 'expo-video-thumbnails';
import {v4 as uuidv4} from 'uuid';

export async function generateThumbnail(videoURI, key) {
  const thumbnail = await AsyncStorage.getItem(key);
  const result = await FileSystem.getInfoAsync(thumbnail || '');

  if (result.exists) {
    console.log('Video thumbnail exists:', thumbnail);
    return thumbnail;
  } else {
    const {uri} = await VideoThumbnails.getThumbnailAsync(videoURI, {
      time: 0,
      quality: 0.5,
    });
    console.log('Video thumbnail was generated:', uri);
    await AsyncStorage.setItem(key, uri);
    return uri;
  }
}

export async function downloadVideo(videoURI, key) {
  const video = await AsyncStorage.getItem(key);
  const result = await FileSystem.getInfoAsync(video || '');

  if (result.exists) {
    console.log('Video exists:', video);
    return video;
  } else {
    const {uri} = await FileSystem.downloadAsync(
      videoURI,
      FileSystem.cacheDirectory + uuidv4() + '.mp4',
    );
    console.log('Video was downloaded:', uri);
    await AsyncStorage.setItem(key, uri);
    return uri;
  }
}

export async function cacheThumbnails(chat) {
  try {
    const videoUri = await downloadVideo(
      getFileURL(chat?.fileURL),
      `video_${chat?.objectId}`,
    );

    return await generateThumbnail(videoUri, chat?.objectId);
  } catch (err) {
    console.log(err.message);
  }
}
