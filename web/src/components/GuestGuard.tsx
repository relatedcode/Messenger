import LoadingScreen from "components/LoadingScreen";
import useAuth from "hooks/useAuth";
import React from "react";
import { Navigate } from "react-router-dom";

const GuestGuard = ({ children }: { children: React.ReactNode }) => {
  const { isInitialized, isAuthenticated } = useAuth();

  if (!isInitialized) return <LoadingScreen />;

  if (isAuthenticated) {
    return <Navigate to="/dashboard" />;
  }

  return <>{children}</>;
};

export default GuestGuard;
