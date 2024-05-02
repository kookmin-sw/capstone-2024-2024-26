import React, { useEffect, useState } from 'react';
import axios from 'axios';
import Sidebar from './sideBar';
import Banner from './banner';
import '../styles/member.css';

const Member = () => {
  const [searchTerm, setSearchTerm] = useState('');
  const [members, setMembers] = useState([]);

  // 서버에서 회원 데이터를 가져오는 함수
  const fetchMembers = async () => {
    try {
      const response = await axios.get('http://localhost:4000/adminAuth/users');
      console.log(response.data);  // 받아온 데이터 확인
      setMembers(response.data);
    } catch (error) {
      console.error('Error fetching members:', error);
      console.log(error.response); // 에러 응답도 확인
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
    // 팝업 로직을 구현하거나 알림 메시지 전송
  };

  const MemberTable = ({ members }) => (
    <table>
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
            <td><button onClick={() => handleNotify(member)}>알림</button></td>
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
                 placeholder='학번 또는 이름'
                 value={searchTerm}
                 onChange={e => setSearchTerm(e.target.value)}
                 />
                 <button className='search_button'>검색</button>
              </div>
              <hr></hr>
              <MemberTable members={filteredMembers} />
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}

export default Member;