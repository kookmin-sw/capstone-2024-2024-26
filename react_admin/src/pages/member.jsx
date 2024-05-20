import React, { useEffect, useState } from 'react';
import axios from 'axios';
import Sidebar from './sideBar';
import Banner from './banner';
import '../styles/member.css';

const Member = () => {
  const [searchTerm, setSearchTerm] = useState('');
  const [members, setMembers] = useState([]);
  const [selectedMember, setSelectedMember] = useState(null);
  const [messageTitle, setMessageTitle] = useState('');
  const [messageContent, setMessageContent] = useState('');

  // 서버에서 회원 데이터를 가져오는 함수
  const fetchMembers = async () => {
    const userEmail = localStorage.getItem('userEmail');  // 로컬 스토리지에서 이메일 가져오기
    try {
      const response = await axios.get('http://localhost:3000/adminAuth/profile', {
        headers: { email: userEmail }  // 이메일을 요청 본문에 포함
      });
      if (response.status === 200) {
        console.log('Profiles:', response.data);
        setMembers(response.data.allUserData);  // 서버에서 보내준 데이터 구조에 맞춰 사용
        return response.data.allUserData;
      } else {
        throw new Error('Fetching profiles failed');
      }
    } catch (error) {
      console.error('Error fetching profiles:', error.response || error.message);
    }
  };

  useEffect(() => {
    fetchMembers(); // 컴포넌트 마운트 시 회원 정보 가져오기
  }, []);

  const filteredMembers = members.filter(member =>
    (member.name && member.name.toLowerCase().includes(searchTerm.toLowerCase())) ||
    (member.studentId && member.studentId.includes(searchTerm))
  );

  const handleNotify = (member) => {
    setSelectedMember(member);
  };

  const handleCloseModal = () => {
    setSelectedMember(null);
    setMessageTitle('');
    setMessageContent('');
  };

  const handleSendMessage = () => {
    handleCloseModal();
  };

  const MemberTable = ({ members }) => (
    <table className="table">
      <thead>
        <tr>
          <th className='name-header'>이름</th>
          <th className='number-header'>학번</th>
          <th className='faculty-header'>단과대</th>
          <th className='mail-header'>메일</th>
          <th className="contact-header">연락처</th>
          <th className="alert-header">알림보내기</th>
        </tr>
      </thead>
      <tbody>
        {members.map((member, index) => (
          <tr key={index}>
            <td>{member.name}</td>
            <td>{member.studentId}</td>
            <td>{member.faculty}</td>
            <td>{member.email}</td>
            <td>{member.phone}</td>
            <td><button className='member_notify_button' onClick={() => handleNotify(member)}>🔔알림</button></td>
          </tr>
        ))}
      </tbody>
    </table>
  );

  return (
    <div className="main-container">
      <Banner />
      <div className="sidebar-and-content">
        <Sidebar />
        <div className="main-content">
          <div className='member_container'>
            <div className='member_box'>
              <div className='member_button'>
                <p className='member_title'>회원관리</p>
                <input
                 type='text'
                 className='search_member'
                 placeholder='학번 또는 이름 검색'
                 value={searchTerm}
                 onChange={e => setSearchTerm(e.target.value)}
                 />
              </div>
              <hr></hr>
              <div className='memberTable_scroll'>
              <MemberTable members={filteredMembers} />
              </div>
            </div>
          </div>
        </div>
      </div>
      {selectedMember && (
        <div className="modal-backdrop">
          <div className="modal-content">
            <span className="close-button" onClick={handleCloseModal}>&times;</span>
            <h2 className="modal-title">알림 보내기</h2>
            <div className="modal-body">
              <div className="modal-row">
                <span className="modal-label">이름:</span>
                <span className="modal-data">{selectedMember.name}</span>
                <span className="modal-label">학번:</span>
                <span className="modal-data">{selectedMember.studentId}</span>
              </div>
              <div className="modal-row">
                <label className="modal-label">제목:</label>
                <input
                  type="text"
                  className="modal-input"
                  value={messageTitle}
                  onChange={e => setMessageTitle(e.target.value)}
                />
              </div>
              <div className="modal-row">
                <label className="modal-label">내용:</label>
                <textarea
                  className="modal-textarea"
                  value={messageContent}
                  onChange={e => setMessageContent(e.target.value)}
                />
              </div>
            </div>
            <button className="modal-send-button" onClick={handleSendMessage}>전송하기</button>
          </div>
        </div>
      )}
    </div>
  );
}

export default Member;