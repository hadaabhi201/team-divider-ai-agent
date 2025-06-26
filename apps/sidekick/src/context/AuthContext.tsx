import React, { createContext, useState } from "react";

type UserType = "regular" | "admin" | null;

interface AuthContextType {
  userType: UserType;
  setUserType: (type: UserType) => void;
}

const AuthContext = createContext<AuthContextType>({
  userType: null,
  setUserType: () => {},
});

export const AuthProvider: React.FC<{ children: React.ReactNode }> = ({
  children,
}) => {
  const [userType, setUserType] = useState<UserType>(null);
  return (
    <AuthContext.Provider value={{ userType, setUserType }}>
      {children}
    </AuthContext.Provider>
  );
};

export default AuthContext;
