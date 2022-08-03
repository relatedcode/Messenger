import AuthContext from "contexts/AuthContext";
import { useContext } from "react";

const useAuth = () => useContext(AuthContext);

export default useAuth;
