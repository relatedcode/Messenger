import {createContext, useContext, useState} from 'react';

export const ParamsContext = createContext({
  workspaceId: '',
  setWorkspaceId: () => {},
  chatId: '',
  setChatId: () => {},
  chatType: '',
  setChatType: () => {},
});

export function ParamsProvider({children}) {
  const [workspaceId, setWorkspaceId] = useState('');
  const [chatId, setChatId] = useState('');
  const [chatType, setChatType] = useState('');

  return (
    <ParamsContext.Provider
      value={{
        workspaceId,
        setWorkspaceId,
        chatId,
        setChatId,
        chatType,
        setChatType,
      }}>
      {children}
    </ParamsContext.Provider>
  );
}
export function useParams() {
  return useContext(ParamsContext);
}
