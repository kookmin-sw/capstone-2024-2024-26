import React from 'react';
import { useNavigate } from "react-router-dom";
import { authService } from '../firebase/fbInstance';
import Sidebar from './sideBar';
import Banner from './banner';
import '../styles/main.css';

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
    <div className="main-container"> {/* 최상단 컨테이너 */}
      <Banner /> {/* 배너 컴포넌트를 최상단에 표시 */}
      <div className="sidebar-and-content"> {/* 사이드바와 내용을 담는 컨테이너 */}
        <Sidebar /> {/* 사이드바를 좌측에 표시 */}
        <div className="main-content"> {/* 메인 작업물을 표시하는 컨테이너 */}

          <div className='main_test'>어디에 나타나냐</div>
        </div>
      </div>
    </div>
  );
}

export default Main;