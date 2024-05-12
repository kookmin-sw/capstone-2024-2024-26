import React from 'react';
import axios from 'axios';
import Sidebar from './sideBar';
import Banner from './banner';
import '../styles/notification.css';

//구현 기능 : 강의실 예약내역불러오기, 강의실 신청 승인, 강의실 예약 삭제, 
const Room = () => {
    return (
        <div className="main-container">
          <Banner />
          <div className="sidebar-and-content">
            <Sidebar />
            <div className="main-content">
              <div className='member_container'>
                <div className='member_box'>
                  <div className='member_button'>
                    <p className='member_title'>강의실 예약 관리</p>
                    <button className='search_button'>검색</button>
                  </div>
                  <hr></hr>
                </div>
              </div>
            </div>
          </div>
        </div>
      );
    }

export default Room;