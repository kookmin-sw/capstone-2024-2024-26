import React from 'react';
import { useNavigate } from "react-router-dom";
import { authService } from '../firebase/fbInstance';
import logo_white from '../image/logo_white.png';
import '../styles/banner.css';

function Banner() {
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
    <div className="banner-container">
      <img src={logo_white} alt="K-SharePlace Logo" className="banner_title"/>
      <button className="logout_button" onClick={handleLogout}>로그아웃</button>
    </div>
  );
}

export default Banner;