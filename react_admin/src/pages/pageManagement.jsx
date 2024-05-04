import React from 'react';
import axios from 'axios';
import Sidebar from './sideBar';
import Banner from './banner';
import '../styles/pageManagement.css';

const PageManagement = () => {
    return (
        <div className="main-container"> {/* 최상단 컨테이너 */}
          <Banner /> {/* 배너 컴포넌트를 최상단에 표시 */}
          <div className="sidebar-and-content"> {/* 사이드바와 내용을 담는 컨테이너 */}
            <Sidebar /> {/* 사이드바를 좌측에 표시 */}
            <div className="main-content">
              <div className='addition_container'>
                <div className='addition_box'>
                  <div className='addition_banner'>
                    <p className='addition_title'>강의실 관리</p>
                    <button className='addition_room_button'>강의실 추가</button>
                  </div>
                  <hr></hr>
                  <div className='addition_chart'>
                  </div>
                </div>
                <div className='blank'></div>
                <div className='addition_box'>
                  <div className='addition_banner'>
                    <p className='addition_title'>공유공간 관리</p>
                    <button className='addition_club_button'>공유공간 추가</button>
                  </div>
                  <hr></hr>
                  <div className='addition_chart'>
                  </div>
                </div>
              </div>
          </div>
          </div>
        </div>
      );
    }

export default PageManagement;