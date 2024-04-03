import { BrowserRouter as Router, Routes, Route } from 'react-router-dom';

import Login from './pages/login.jsx';
import Main from './pages/main.jsx';

function App() {
  return (
    <Router>
      <Routes>
        <Route path="/" element={<Login />} />
        <Route path="/main" element={<Main />} />
      </Routes>
    </Router>
  );
}

export default App;