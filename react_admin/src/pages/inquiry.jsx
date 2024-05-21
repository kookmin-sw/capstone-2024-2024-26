import React, { useState, useEffect } from 'react';
import axios from 'axios';
import Sidebar from './sideBar';
import Banner from './banner';
import '../styles/inquiry.css';
import Swal from 'sweetalert2';

//문의관리 관리자 웹
const Inquiry = () => {
  const [inquiries, setInquiries] = useState([]);
  const [isModalOpen, setModalOpen] = useState(false);
  const [currentInquiry, setCurrentInquiry] = useState(null);
  const [responseText, setResponseText] = useState(''); // 답변 텍스트 상태

  useEffect(() => {
    const fetchInquiries = async () => {
      const faculty = localStorage.getItem('faculty');
      const today = new Date();
      const oneMonthAgo = new Date(today.getFullYear(), today.getMonth() - 1, today.getDate());
      const oneMonthLater = new Date(today.getFullYear(), today.getMonth() + 1, today.getDate());

      const startDate = oneMonthAgo.toISOString().split('T')[0];
      const endDate = oneMonthLater.toISOString().split('T')[0];

      try {
        const response = await axios.get(`http://localhost:3000/adminInquiry/list/${faculty}/${startDate}/${endDate}`);
        console.log('Data fetched successfully:', response.data);
        if (response.data && response.data.inquiries) {
          setInquiries(response.data.inquiries);
          localStorage.setItem('inquiryCount', response.data.inquiries.length);
        }
      } catch (error) {
        console.error('Failed to fetch inquiries:', error);
      }
    };

    fetchInquiries();
  }, []);

  const handleInquiryClick = (inquiry) => {
    setCurrentInquiry(inquiry);
    setModalOpen(true);
    setResponseText(''); // 모달이 열릴 때 입력 필드 초기화
  };

  const handleCloseModal = () => {
    setModalOpen(false);
  };

  const getCurrentTimeFormatted = () => {
    const now = new Date();
    const year = now.getFullYear();
    const month = String(now.getMonth() + 1).padStart(2, '0'); // 월은 0부터 시작하므로 1을 더해줍니다.
    const day = String(now.getDate()).padStart(2, '0');
    // 반환되는 문자열 형식을 "YYYY-MM-DD"으로 조정합니다.
    return `${year}-${month}-${day}`;
  };

  const handleResponseSubmit = async () => {
    const currentTime = getCurrentTimeFormatted();
    console.log('Student ID:', currentInquiry.studentId);
    console.log('Date:', currentTime);
    console.log('Time:', currentInquiry.date);
    console.log('Response:', responseText);
    try {
      const response = await axios.post('http://localhost:3000/adminInquiry/', {
        studentId: currentInquiry.studentId,
        date: currentTime,
        time: currentInquiry.date,
        response: responseText
      });

      console.log('Response submitted successfully:', response.data);
      Swal.fire({
          icon: "success",
          title: "등록 성공!",
          text: "답변이 성공적으로 등록되었습니다",
      });
      handleCloseModal();
    } catch (error) {
      console.error('Failed to submit response:', error);
      Swal.fire({
        icon: "error",
        title: "등록 실패!",
        text: "답변등록에 실패하였습니다",
    });
    }
  };

  const InquiryTable = ({ inquiries }) => {
    const renderResponseStatus = (status) => {
      return status ? '답변 완료' : '답변 미완료';
    };

    return (
      <table>
        <thead>
          <tr>
            <th className='inquiry_date'>날짜</th>
            <th className='inquiry_name'>이름</th>
            <th className='inquiry_id'>학번</th>
            <th className='inquiry_faculty'>단과대학</th>
            <th className='inquiry_status'>답변 여부</th>
            <th className='inquiry_contents'>문의 내용</th>
          </tr>
        </thead>
        <tbody>
          {inquiries.map((inquiry, index) => (
            <tr key={index}>
              <td>{inquiry.date}</td>
              <td>{inquiry.name}</td>
              <td>{inquiry.studentId}</td>
              <td>{inquiry.faculty}</td>
              <td>{renderResponseStatus(inquiry.responseStatus)}</td>
              <td><button className='inquiry_content_button' onClick={() => handleInquiryClick(inquiry)}>문의 내용 확인</button></td>
            </tr>
          ))}
        </tbody>
      </table>
    );
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
              </div>
              <hr></hr>
              <InquiryTable inquiries={inquiries} />
              {isModalOpen && (
                <div className="modal">
                  <div className="modal-content">
                    <span className="close" onClick={handleCloseModal}>&times;</span>
                    <h2>제목: {currentInquiry?.title}</h2>
                    <h4>문의 내용 </h4>
                    <p className='inquiry_content_box'>{currentInquiry?.content}</p>
                    <textarea
                      value={responseText}
                      onChange={e => setResponseText(e.target.value)}
                      placeholder="답변 작성"
                      style={{ width: '100%', height: '100px' }}
                    />
                    <button className="reply-button" onClick={handleResponseSubmit}>답변하기</button>
                  </div>
                </div>
              )}
            </div>
          </div>
        </div>
      </div>
    </div>
  );
};

export default Inquiry;