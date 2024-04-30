import React from 'react';
import Sidebar from './sideBar';
import Banner from './banner';
import '../styles/notification.css';

const Notification = () => {
    return (
        <div className="main-container">
          <Banner />
          <div className="sidebar-and-content">
            <Sidebar />
            <div className="main-content">
              <div className='notice_container'>
                <div className='notice'>
                  <div className='notice_box'>
                    <div className='notice_box_upper'>
                    <p className='notice_title'>전체 공지사항</p> <button className='notice_add_button'>+</button>
                    </div>
                    <hr></hr>
                  </div>
                  <div className='notice_box'>
                    <div className='notice_box_upper'>
                    <p className='notice_title'>개인 공지사항</p> <button className='notice_add_button'>+</button>
                    </div>
                    <hr></hr>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      );
    }

export default Notification;