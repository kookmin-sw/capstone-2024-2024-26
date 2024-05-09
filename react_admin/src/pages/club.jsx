import React from 'react';
import Sidebar from './sideBar';
import Banner from './banner';
import '../styles/notification.css';

const Club = () => {
    return (
        <div className="main-container">
          <Banner />
          <div className="sidebar-and-content">
            <Sidebar />
            <div className="main-content">
              <div className='member_container'>
                <div className='member_box'>
                  <div className='member_button'>
                    <p className='member_title'>공유공간 예약 관리</p>
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

export default Club;