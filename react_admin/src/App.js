import React, { useState } from 'react';
import { BrowserRouter as Router, Route, Routes } from 'react-router-dom';
import Login from './pages/login.jsx';
import Main from './pages/main.jsx';
import Sidebar from './pages/sideBar.jsx';
import Inquiry from './pages/inquiry.jsx';
import PageManagement from './pages/pageManagement.jsx';
import Notification from './pages/notification.jsx';
import Member from './pages/member.jsx';


function App() {
  // 로그인 상태를 관리하는 상태 변수
  const [isLoggedIn, setIsLoggedIn] = useState(false);

  return (
      <div className="App">
        {/* 로그인 상태에 따라 Sidebar를 렌더링하는 조건부 렌더링 */}
        {isLoggedIn && <Sidebar />}
        <Routes>
          {/* 로그인 화면 */}
          <Route path='/' element={<Login setIsLoggedIn={setIsLoggedIn} />} />
          {/* 로그인 이후의 화면들 */}
          <Route path='/main' element={<Main />} />
          <Route path='/member' element={<Member />} />
          <Route path='/inquiry' element={<Inquiry />} />
          <Route path='/page-management' element={<PageManagement />} />
          <Route path='/notification' element={<Notification />} />
        </Routes>
      </div>
  );
}

export default App;