import React, { useState, useEffect } from 'react';
import firebase from 'firebase/compat/app';
import 'firebase/compat/app';
import 'firebase/compat/firestore';
import Sidebar from './sideBar';
import Banner from './banner';
import '../styles/inquiry.css';

const Inquiry = () => {
  const [searchDate, setSearchDate] = useState('');
  const [inquiries, setInquiries] = useState([]);

  const fetchData = async () => {
    const db = firebase.firestore();
    const inquiryCollection = await db.collection('inquiries').get();
    return inquiryCollection.docs.map(doc => ({ id: doc.id, ...doc.data() }));
  };

  useEffect(() => {
    const fetchInquiries = async () => {
      const fetchedInquiries = await fetchData();
      setInquiries(fetchedInquiries);
    };
    fetchInquiries();
  }, []);

  const filteredInquiries = inquiries.filter(inquiry =>
    inquiry.date >= searchDate // 간단한 예시, 날짜 검색 로직 추가 필요
  );

  const InquiryTable = ({ inquiries }) => (
    <table>
      <thead>
        <tr>
          <th className='inq-numb-header'>문의 번호</th>
          <th className='inq-date-header'>신청 날짜</th>
          <th className='inq-mail-header'>메일</th>
          <th className='inq-contact-header'>연락처</th>
          <th className='inq-response-header'>답변 작성</th>
        </tr>
      </thead>
      <tbody>
        {inquiries.map((inquiry, index) => (
          <tr key={index}>
            <td>{inquiry.inquiryId}</td>
            <td>{inquiry.date}</td>
            <td>{inquiry.email}</td>
            <td>{inquiry.phone}</td>
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
              <InquiryTable inquiries={filteredInquiries} />
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}

export default Inquiry;