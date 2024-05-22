import React,{ useState, useEffect } from 'react';
import axios from 'axios';
import Sidebar from './sideBar';
import Banner from './banner';
import '../styles/club.css';

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
        const response = await axios.get(`http://3.35.96.145:3000/adminClub/reservationclubs/${faculty}/${startDate}/${endDate}`);
        if (response.data && response.data.reservations) {
          setReservations(response.data.reservations); // Assuming the data is under the reservations key
        }
      } catch (error) {
        
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
          <th className='club_date'>날짜</th>
          <th className='club_room'>방 이름</th>
          <th className='club_time'>사용시간</th>
          <th className='club_table'>테이블 번호</th>
          <th className='club_id'>학번</th>
          <th className='club_return'>반납사진</th>
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
                  </div>
                  <hr></hr>
                  <div className='club_table_box'>
                  <RenderTable/>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      );
    }

export default Club;