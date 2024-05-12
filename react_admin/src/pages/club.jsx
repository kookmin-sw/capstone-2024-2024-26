import React,{ useState, useEffect } from 'react';
import axios from 'axios';
import Sidebar from './sideBar';
import Banner from './banner';
import '../styles/notification.css';

//구현 기능 : 동아리방 예약 조회 + 반납 사진 받아야함
const Club = () => {
  const [reservations, setReservations] = useState([]);

  //공유공간(동아리방) 예약 정보 사이드 이펙트 실행 함수
  useEffect(() => {
    const fetchReservations = async () => {
      const faculty = localStorage.getItem('faculty');
      const today = new Date();
      const oneMonthAgo = new Date(today.getFullYear(), today.getMonth() - 1, today.getDate());
      const oneMonthLater = new Date(today.getFullYear(), today.getMonth() + 1, today.getDate());

      const startDate = oneMonthAgo.toISOString().split('T')[0];
      const endDate = oneMonthLater.toISOString().split('T')[0];

      try {
        const response = await axios.get(`http://localhost:3000/adminClub/reservationclubs/${faculty}/${startDate}/${endDate}`);
        console.log('Data fetched successfully:', response.data);
        if (response.data && response.data.reservations) {
          setReservations(response.data.reservations); // Assuming the data is under the reservations key
        }
      } catch (error) {
        console.error('Failed to fetch reservations:', error);
      }
    };

    fetchReservations();
  }, []);

  const findTableKey = (tableData) => {
    for (const key in tableData) {
      if (key.startsWith('T') && tableData[key] === true) {
        return key; // 예: "T3"
      }
    }
    return 'No Table'; // 해당하는 키가 없는 경우
  };
//불러온 데이터를 이용한 동적 테이블 생성 함수
const RenderTable = () => {
  return (
    <table className="reservations-table">
      <thead>
        <tr>
          <th>날짜</th>
          <th>방 이름</th>
          <th>사용시간</th>
          <th>테이블 번호</th>
          <th>학번</th>
          <th>반납사진</th>
        </tr>
      </thead>
      <tbody>
        {reservations.map((reservation, index) => (
          <tr key={index}>
            <td>{reservation.date}</td>
            <td>{reservation.roomName}</td>
            <td>{`${reservation.startTime} ~ ${reservation.endTime}`}</td>
            <td>{reservation.tableData ? findTableKey(reservation.tableData) : 'No data'}</td>
            <td>{reservation.tableData && reservation.tableData.studentId}</td>
            <td>
              {reservation.tableData && reservation.tableData.image ? (
                <img src={`data:image/jpeg;base64,${reservation.tableData.image}`} alt="반납 사진" style={{width: "100px"}} />
              ) : 'No image'}
            </td>
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
                    <p className='member_title'>공유공간 예약 관리</p>
                    <button className='search_button'>검색</button>
                  </div>
                  <hr></hr>
                  <RenderTable/>
                </div>
              </div>
            </div>
          </div>
        </div>
      );
    }

export default Club;