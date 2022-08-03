import {env} from '@/config/env';
import {getIdToken} from '@/lib/auth';

export const fetcher = async url => {
  const headers = {
    'Content-Type': 'application/json',
  };
  const idToken = await getIdToken();
  if (idToken) {
    headers.Authorization = `Bearer ${idToken}`;
  }

  const res = await fetch(`${env.API_URL}${url}`, {
    method: 'get',
    headers,
  });
  if (!res.ok) {
    const e = await res.json();
    const error = new Error(e.error.message);
    throw error;
  }
  return await res.json();
};

export const postData = async (url, data, addHeaders, warnIfError = true) => {
  const headers = {
    'Content-Type': 'application/json',
    ...addHeaders,
  };
  const idToken = await getIdToken();
  if (idToken) {
    headers.Authorization = `Bearer ${idToken}`;
  }

  const res = await fetch(`${env.API_URL}${url}`, {
    method: 'post',
    headers,
    body: JSON.stringify(data || {}),
  });
  if (!res.ok && warnIfError) {
    const e = await res.json();
    const error = new Error(e.error.message);
    throw error;
  } else {
    const contentType = res.headers.get('content-type');
    if (contentType && contentType.indexOf('application/json') !== -1)
      return await res.json();
  }
  return;
};

export const deleteData = async (url, addHeaders) => {
  const headers = {
    'Content-Type': 'application/json',
    ...addHeaders,
  };
  const idToken = await getIdToken();
  if (idToken) {
    headers.Authorization = `Bearer ${idToken}`;
  }

  const res = await fetch(`${env.API_URL}${url}`, {
    method: 'delete',
    headers,
  });
  if (!res.ok) {
    const e = await res.json();
    const error = new Error(e.error.message);
    throw error;
  }
  const contentType = res.headers.get('content-type');
  if (contentType && contentType.indexOf('application/json') !== -1)
    return await res.json();
};
