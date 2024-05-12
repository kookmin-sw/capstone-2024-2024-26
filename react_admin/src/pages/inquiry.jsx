import React, { useState, useEffect } from 'react';
import axios from 'axios';
import Sidebar from './sideBar';
import Banner from './banner';
import '../styles/inquiry.css';


//문의관리 관리자 웹
const Inquiry = () => {
  const [searchDate, setSearchDate] = useState('');
  const [inquiries, setInquiries] = useState([]);

  useEffect(() => {
    const fetchInquiries = async () => {
      try {
        const response = await axios.get('http://localhost:3000/adminInquiry/get');
        setInquiries(response.data);
      } catch (error) {
        console.error('Error fetching inquiries:', error);
      }
    };
    fetchInquiries();
  }, []);

  const filteredInquiries = inquiries.filter(inquiry => inquiry.date >= searchDate);

  const InquiryTable = ({ inquiries }) => (
    <table>
      <thead>
        <tr>
          <th className='inq-numb-header'>번호</th>
          <th className='inq-date-header'>문의 날짜</th>
          <th className='inq-name-header'>이름</th>
          <th className='inq-inquiryId-header'>학번</th>
          <th className='inq-mail-header'>메일</th>
          <th className='inq-status-header'>답변 여부</th>
          <th className='inq-response-header'>답변하기</th>
        </tr>
      </thead>
      <tbody>
        {inquiries.map((inquiry, index) => (
          <tr key={index}>
            <td>{inquiry.number}</td>
            <td>{inquiry.date}</td>
            <td>{inquiry.name}</td>
            <td>{inquiry.inquiryId}</td>
            <td>{inquiry.email}</td>
            <td>{inquiry.status}</td>
            <td><button onClick={() => handleResponse(inquiry)}>답변 작성하기</button></td>
          </tr>
        ))}
      </tbody>
    </table>
  );

  const handleResponse = (inquiry) => {
    // 답변 팝업 로직 구현
  };

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
                <input
                  type='date'
                  className='search_member'
                  value={searchDate}
                  onChange={e => setSearchDate(e.target.value)}
                />
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