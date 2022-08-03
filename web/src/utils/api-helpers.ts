import { getIdToken } from "gqlite-lib/dist/client/auth";
import { CLIENT_VERSION, getAPIUrl } from "config";

interface IError {
  error: {
    type: string;
    message: string;
    code?: string;
  };
}

export const fetcher = async (url: string) => {
  const headers: any = {
    "Content-Type": "application/json",
    "X-Client-Version": CLIENT_VERSION,
  };
  const idToken = await getIdToken();
  if (idToken) {
    headers.Authorization = `Bearer ${idToken}`;
  }

  const res = await fetch(`${getAPIUrl()}${url}`, {
    method: "get",
    headers,
  });
  if (!res.ok) {
    const e: IError = await res.json();
    const error = new Error(e.error.message);
    throw error;
  }
  return await res.json();
};

export const postData = async (
  url: string,
  data?: {},
  addHeaders?: {},
  warnIfError = true
) => {
  const headers: any = {
    "Content-Type": "application/json",
    "X-Client-Version": CLIENT_VERSION,
    ...addHeaders,
  };
  const idToken = await getIdToken();
  if (idToken) {
    headers.Authorization = `Bearer ${idToken}`;
  }

  const res = await fetch(`${getAPIUrl()}${url}`, {
    method: "post",
    headers,
    body: JSON.stringify(data || {}),
  });
  if (!res.ok && warnIfError) {
    const e: IError = await res.json();
    const error = new Error(e.error.message);
    throw error;
  } else {
    const contentType = res.headers.get("content-type");
    if (contentType && contentType.indexOf("application/json") !== -1)
      return await res.json();
  }
  return;
};

export const deleteData = async (url: string, addHeaders?: {}) => {
  const headers: any = {
    "Content-Type": "application/json",
    "X-Client-Version": CLIENT_VERSION,
    ...addHeaders,
  };
  const idToken = await getIdToken();
  if (idToken) {
    headers.Authorization = `Bearer ${idToken}`;
  }

  const res = await fetch(`${getAPIUrl()}${url}`, {
    method: "delete",
    headers,
  });
  if (!res.ok) {
    const e: IError = await res.json();
    const error = new Error(e.error.message);
    throw error;
  }
  const contentType = res.headers.get("content-type");
  if (contentType && contentType.indexOf("application/json") !== -1)
    return await res.json();
};
