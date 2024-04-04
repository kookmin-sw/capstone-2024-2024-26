import React from 'react';
import { HashRouter as Router, Route, Routes } from 'react-router-dom';
import Login from './pages/login.jsx';
import Main from './pages/main.jsx';

function App() {
  return (
    <Routes>
      <Route path='/' element={<Login/>} />
      <Route path='/main' element={<Main/>} />
    </Routes>
  );
}

export default App;