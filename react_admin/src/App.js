import React, { useState } from 'react';
import { BrowserRouter as Router, Route, Routes } from 'react-router-dom';
import Login from './pages/login.jsx';
import Main from './pages/main.jsx';
import Banner from './pages/banner.jsx';
import Sidebar from './pages/sideBar.jsx';
import Inquiry from './pages/inquiry.jsx';
import PageManagement from './pages/pageManagement.jsx';
import Notification from './pages/notification.jsx';
import Member from './pages/member.jsx';
import Reserve from './pages/reserve.jsx';
import Traffic from './pages/traffic.jsx';
import Club from './pages/club.jsx';
import Room from './pages/room.jsx';


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
        <Route
          path='/main'
          element={<Main sidebar={<Sidebar />} banner={<Banner />} />} // Main 컴포넌트에 Sidebar와 Banner를 props로 전달
        />
        <Route path='/member' element={<Member sidebar={<Sidebar />} banner={<Banner />} />} />
        <Route path='/inquiry' element={<Inquiry sidebar={<Sidebar />} banner={<Banner />} />} />
        <Route path='/page-management' element={<PageManagement sidebar={<Sidebar />} banner={<Banner />} />} />
        <Route path='/notification' element={<Notification sidebar={<Sidebar />} banner={<Banner />} />} />
        <Route path='/reserve' element={<Reserve sidebar={<Sidebar />} banner={<Banner />} />} />
        <Route path='/traffic' element={<Traffic sidebar={<Sidebar />} banner={<Banner />} />} />
        <Route path='/club' element={<Club sidebar={<Sidebar />} banner={<Banner />} />} />
        <Route path='/room' element={<Room sidebar={<Sidebar />} banner={<Banner />} />} />
      </Routes>
    </div>
  );
}

export default App;