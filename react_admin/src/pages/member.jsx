import React, { useEffect, useState } from 'react';
import firebase from 'firebase/compat/app';
import 'firebase/compat/app';
import 'firebase/compat/firestore';
import Sidebar from './sideBar';
import Banner from './banner';
import '../styles/member.css';

const Member = () => {
  const [searchTerm, setSearchTerm] = useState('');
  const [members, setMembers] = useState([]);

  const fetchData = async () => {
    const db = firebase.firestore();
    const usersCollection = await db.collection('users').get();
    return usersCollection.docs.map(doc => doc.data());
  };

  useEffect(() => {
    const fetchMembers = async () => {
      const fetchedMembers = await fetchData();
      setMembers(fetchedMembers);
    };

    fetchMembers();
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
          <th>이름</th>
          <th>학번</th>
          <th>단과대</th>
          <th>메일</th>
          <th>연락처</th>
          <th>알림보내기</th>
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
                <p className='member_title'>회원관리</p> <div className='date_select'>날짜 고르기</div> <button className='date_button'>검색</button>
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