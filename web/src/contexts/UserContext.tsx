import { useQuery, useSubscription } from "@apollo/client";
import * as queries from "graphql/queries";
import * as subscriptions from "graphql/subscriptions";
import useAuth from "hooks/useAuth";
import { createContext, useContext, useEffect, useState } from "react";

export const UserContext = createContext({
  user: null as any,
  userdata: null as any,
});

export const UserProvider = ({ children }: any) => {
  const { user: authUser, logout } = useAuth();

  const { data, error } = useQuery(queries.GET_USER, {
    variables: { objectId: authUser?.uid },
    skip: !authUser?.uid,
  });

  if (error?.message === "Cannot read property 'dataValues' of null") {
    logout();
  }

  const { data: dataPush } = useSubscription(subscriptions.USER, {
    variables: { objectId: authUser?.uid },
    skip: !authUser?.uid,
  });

  const [user, setUser] = useState(null);

  useEffect(() => {
    if (data) {
      setUser(data.getUser);
    }
  }, [data]);

  useEffect(() => {
    if (dataPush) {
      setUser(dataPush.onUpdateUser);
    }
  }, [dataPush]);

  return (
    <UserContext.Provider
      value={{
        user: authUser,
        userdata: user,
      }}
    >
      {children}
    </UserContext.Provider>
  );
};

export function useUser() {
  return useContext(UserContext);
}
