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
            <td><button className='member_noitfy_button' onClick={() => handleNotify(member)}>🔔알림</button></td>
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
              <MemberTable members={filteredMembers} />
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}

export default Member;