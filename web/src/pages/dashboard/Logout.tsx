import LoadingScreen from "components/LoadingScreen";
import { APP_NAME } from "config";
import useAuth from "hooks/useAuth";
import { useEffect } from "react";
import { Helmet } from "react-helmet-async";

export default function Logout() {
  const { logout } = useAuth();
  useEffect(() => {
    (async () => {
      localStorage.removeItem("theme");
      localStorage.removeItem("backgroundColor");
      await logout();
      window.location.replace("/authentication/login");
    })();
  }, []);

  return (
    <>
      <Helmet>
        <title>{APP_NAME}</title>
      </Helmet>
      <LoadingScreen />
    </>
  );
}
