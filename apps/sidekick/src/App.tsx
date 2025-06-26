import React from "react";
import { Container } from "react-bootstrap";
import SignInPage from "./pages/SignInPage";

const App: React.FC = () => {
  return (
    <Container className="d-flex justify-content-center align-items-center vh-100">
      <SignInPage />
    </Container>
  );
};

export default App;
