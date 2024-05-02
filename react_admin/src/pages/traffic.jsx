import React from 'react';
import Sidebar from './sideBar';
import Banner from './banner';
import '../styles/traffic.css';

const Traffic = () => {
    return (
        <div className="main-container">
          <Banner />
          <div className="sidebar-and-content">
            <Sidebar />
            <div className="main-content">
                <div className='member_container'>
                    <div className='member_box'>
                        <div className='member_button'>
                        <p className='member_title'>혼잡도 카메라</p>
                        <button className='search_button'>+추가하기</button>
                        </div>
                        <hr></hr>
                    </div>
                    
                </div>
            </div>
          </div>
        </div>
      );
    }

export default Traffic;