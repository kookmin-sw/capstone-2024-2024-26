import React from 'react';
import { useNavigate } from "react-router-dom";
import { authService } from '../firebase/fbInstance';
import Sidebar from './sideBar';


const Main = () => {
  const navigate = useNavigate(); // useHistory 훅을 사용하여 history 객체 생성

  // 로그아웃 함수
  const handleLogout = async () => {
    try {
      await authService.signOut(); // Firebase의 signOut 메서드를 사용하여 로그아웃
      navigate('/'); // 로그아웃 후 login 페이지로 이동
    } catch (error) {
      console.error('로그아웃 에러:', error);
    }
  };

  return (
    <div>
    
      <Sidebar/>
    </div>
  );
}

export default Main;