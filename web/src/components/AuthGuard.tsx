import LoadingScreen from "components/LoadingScreen";
import useAuth from "hooks/useAuth";
import React, { useEffect } from "react";
import { Navigate } from "react-router-dom";

export default function AuthGuard({ children }: { children: React.ReactNode }) {
  const { user, isInitialized, isAuthenticated } = useAuth();

  useEffect(() => {
    if (isInitialized && !isAuthenticated) {
      localStorage.removeItem("theme");
      localStorage.removeItem("backgroundColor");
    }
  }, [user]);

  if (!isInitialized) return <LoadingScreen />;

  if (!isAuthenticated) return <Navigate to="/authentication/login" />;

  return <>{children}</>;
}
