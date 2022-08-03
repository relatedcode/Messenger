import { GQL_SERVER_URL } from "lib/config";
import { fetcher, postData } from "utils";

export const verifyToken = async (token: string) => {
  const decoded = await fetcher(`${GQL_SERVER_URL}/auth/verify`, {
    Authorization: `Bearer ${token}`,
  });
  return decoded;
};

export const createGQLUser = async (params: any) => {
  const user = await postData(`${GQL_SERVER_URL}/auth/users`, params);
  return user;
};

export const updateGQLUser = async (
  token: string,
  uid: string,
  params: any
) => {
  await postData(`${GQL_SERVER_URL}/auth/users/${uid}`, params, {
    Authorization: `Bearer ${token}`,
  });
};
