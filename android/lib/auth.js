import {env} from '@/config/env';
import AsyncStorage from '@react-native-async-storage/async-storage';
import jwt_decode from 'jwt-decode';

const postData = async (url, data, addHeaders) => {
  const headers = {
    'Content-Type': 'application/json',
    ...addHeaders,
  };
  const res = await fetch(`${env.GQL_SERVER}${url}`, {
    method: 'post',
    headers,
    body: JSON.stringify(data || {}),
  });
  if (!res.ok) {
    const e = await res.json();
    const error = new Error(e.error.message);
    throw error;
  }
  const contentType = res.headers.get('content-type');
  if (contentType && contentType.indexOf('application/json') !== -1) {
    return await res.json();
  }
};

export const now = () => Math.floor(Date.now() / 1000);

let user = null;

export async function getIdToken(forceRefresh = false) {
  let currentIdToken = await AsyncStorage.getItem('idToken');
  const expires = await AsyncStorage.getItem('expires');

  if (!currentIdToken) return null;

  if ((expires && parseInt(expires) < now()) || forceRefresh) {
    console.log('Network request to refresh idToken');
    try {
      const {
        idToken,
        refreshToken,
        expires,
        uid: id,
      } = await postData('/auth/refresh', {
        refreshToken: await AsyncStorage.getItem('refreshToken'),
      });

      currentIdToken = idToken;
      await AsyncStorage.setItem('idToken', idToken);
      await AsyncStorage.setItem('refreshToken', refreshToken);
      await AsyncStorage.setItem('expires', String(now() + expires));
      await AsyncStorage.setItem('uid', id);
    } catch (err) {
      await AsyncStorage.clear();
      return null;
    }
  }

  return currentIdToken;
}

export async function getUser(forceRefresh = false) {
  const idToken = await getIdToken(forceRefresh);
  console.log('idToken', idToken);
  if (!idToken) return null;
  const decoded = jwt_decode(idToken);
  console.log('decoded', decoded.user);
  return decoded.user;
}

export async function updateUser(uid, payload) {
  const idToken = await getIdToken();
  if (!idToken) throw new Error('No user');
  await postData(`/auth/users/${uid}`, payload, {
    Authorization: `Bearer ${await getIdToken()}`,
  });
  return true;
}

export async function logout() {
  const refreshToken = await AsyncStorage.getItem('refreshToken');
  if (!refreshToken) {
    await AsyncStorage.clear();
    return true;
  }
  await postData(
    '/auth/logout',
    {
      refreshToken: await AsyncStorage.getItem('refreshToken'),
    },
    {
      Authorization: `Bearer ${await getIdToken()}`,
    },
  );
  await AsyncStorage.clear();
  user = null;
  return true;
}

export async function login(email, password) {
  const {idToken, refreshToken, expires, uid} = await postData('/auth/login', {
    email,
    password,
  });
  await AsyncStorage.setItem('idToken', idToken);
  await AsyncStorage.setItem('refreshToken', refreshToken);
  await AsyncStorage.setItem('expires', String(now() + expires));
  await AsyncStorage.setItem('uid', uid);
  user = await getUser();
  return user;
}

export async function createUser(email, password) {
  const {idToken, refreshToken, expires, uid} = await postData('/auth/users', {
    email,
    password,
  });
  await AsyncStorage.setItem('idToken', idToken);
  await AsyncStorage.setItem('refreshToken', refreshToken);
  await AsyncStorage.setItem('expires', String(now() + expires));
  await AsyncStorage.setItem('uid', uid);
  user = await getUser();
  return user;
}
