import { BrowserRouter as Router, Routes, Route } from "react-router-dom";
import SignInPage from "../pages/SignInPage";
// import RegularDashboard from '../pages/RegularDashboard';
// import AdminDashboard from '../pages/AdminDashboard';

const AppRoutes = () => (
  <Router>
    <Routes>
      <Route path="/" element={<SignInPage />} />
      {/* <Route path="/regular" element={<RegularDashboard />} />
      <Route path="/admin" element={<AdminDashboard />} /> */}
    </Routes>
  </Router>
);

export default AppRoutes;
