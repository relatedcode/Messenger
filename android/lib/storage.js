import {getIdToken} from '@/lib/auth';
import {env} from '@/config/env';
import axios from 'axios';

export async function uploadFile(bucketName, filePath, uri, type, name) {
  const body = new FormData();
  body.append('key', filePath);
  body.append('file', {
    uri,
    type,
    name,
  });

  const res = await axios.post(
    `${env.GQL_SERVER}/storage/b/${bucketName}/upload`,
    body,
    {
      headers: {
        Authorization: `Bearer ${await getIdToken()}`,
        'Content-Type': 'multipart/form-data',
      },
    },
  );

  return res.data.url;
}

export function getFileURL(path) {
  return `${env.GQL_SERVER}${path}`;
}
