import React from 'react';
import Sidebar from './sideBar';
import Banner from './banner';
import '../styles/notification.css';

//알림관리 관리자 웹 - 개인 공지는 회원관리의 알림 보내기 기능으로 통합
const Notification = () => {
    return (
        <div className="main-container">
          <Banner />
          <div className="sidebar-and-content">
            <Sidebar />
            <div className="main-content">
              <div className='notice_container'>
                  <div className='notice_box'>
                    <div className='notice_box_button'>
                      <p className='notice_title'>공지사항</p> 
                      <button className='notice_add_button'>+</button>
                    </div>
                    <hr></hr>
                  </div>
              </div>
            </div>
          </div>
        </div>
      );
    }

export default Notification;