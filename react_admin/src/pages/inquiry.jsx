import React, { useState, useEffect } from 'react';
import axios from 'axios';
import Sidebar from './sideBar';
import Banner from './banner';
import '../styles/inquiry.css';


//문의관리 관리자 웹
const Inquiry = () => {
  return (
    <div className="main-container">
      <Banner />
      <div className="sidebar-and-content">
        <Sidebar />
        <div className="main-content">
          <div className='member_container'>
            <div className='member_box'>
              <div className='member_button'>
                <p className='member_title'>문의 관리</p>
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

export default Inquiry;