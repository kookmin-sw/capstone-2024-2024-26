import React, { useState, useEffect } from 'react';
import axios from 'axios';
import Sidebar from './sideBar';
import Banner from './banner';
import '../styles/room.css';

//구현 기능 : 강의실 예약내역불러오기, 강의실 신청 승인, 강의실 예약 삭제, 
const Room = () => {
  const [approvedReservations, setApprovedReservations] = useState([]);
  const [pendingReservations, setPendingReservations] = useState([]);

  //승인, 미승인 강의실 예약 데이터 사이드 이펙트 실행 함수
  useEffect(() => {
    const fetchApprovedReservations = async () => {
      const faculty = localStorage.getItem('faculty');
      const today = new Date();
      const oneMonthAgo = new Date(today.getFullYear(), today.getMonth() - 1, today.getDate());
      const oneMonthLater = new Date(today.getFullYear(), today.getMonth() + 1, today.getDate());

      const startDate = oneMonthAgo.toISOString().split('T')[0];
      const endDate = oneMonthLater.toISOString().split('T')[0];

      try {
        const response = await axios.get(`http://localhost:3000/adminRoom/reservations/${faculty}/${startDate}/${endDate}`);
        console.log('Data1 fetched successfully:', response.data);
        if (response.data && response.data.reservations) {
          setApprovedReservations(response.data.reservations);
        }
      } catch (error) {
        console.error('Failed to fetch approved reservations:', error);
      }
    };

    const fetchPendingReservations = async () => {
      const faculty = localStorage.getItem('faculty');
      const today = new Date();
      const oneMonthAgo = new Date(today.getFullYear(), today.getMonth() - 1, today.getDate());
      const oneMonthLater = new Date(today.getFullYear(), today.getMonth() + 1, today.getDate());

      const startDate = oneMonthAgo.toISOString().split('T')[0];
      const endDate = oneMonthLater.toISOString().split('T')[0];

      try {
        const response = await axios.get(`http://localhost:3000/adminRoom/reservationQueues/${faculty}/${startDate}/${endDate}`);
        console.log('Data2 fetched successfully:', response.data);
        if (response.data && response.data.reservations) {
          setPendingReservations(response.data.reservations);
        }
      } catch (error) {
        console.error('Failed to fetch pending reservations:', error);
      }
    };

    fetchApprovedReservations();
    fetchPendingReservations();
  }, []);

  //승인 강의실 예약 데이터 관련 테이블 함수
  const ApprovedTable = ({ reservations, onDelete }) => {
    return (
      <table className="reservations-table">
        <thead>
          <tr>
            <th>날짜</th>
            <th>대표자 이름</th>
            <th>대표자 학번</th>
            <th>강의실 이름</th>
            <th>예약 시간</th>
            <th>신청서</th>
            <th>삭제</th>
          </tr>
        </thead>
        <tbody>
          {reservations.map((reservation, index) => (
            <tr key={index}>
              <td>{reservation.date}</td>
              <td>{reservation.mainName}</td>
              <td>{reservation.mainStudentId}</td>
              <td>{reservation.roomName}</td>
              <td>{`${reservation.startTime} ~ ${reservation.endTime}`}</td>
              <td>
                <button className="request-button">
                  신청서 보기
                </button>
              </td>
              <td>
                <button className="delete-button" onClick={() => onDelete(reservation)}>
                  삭제하기
                </button>
              </td>
            </tr>
          ))}
        </tbody>
      </table>
    );
  };
  
  //미승인 강의실 예약 데이터 관련 테이블 함수
  const DynamicTable = ({ reservations }) => {
    return (
      <table className="reservations-table">
        <thead>
          <tr>
            <th>날짜</th>
            <th>대표자 이름</th>
            <th>대표자 학번</th>
            <th>강의실 이름</th>
            <th>예약 시간</th>
            <th>신청서</th>
          </tr>
        </thead>
        <tbody>
          {reservations.map((reservation, index) => (
            <tr key={index}>
              <td>{reservation.date}</td>
              <td>{reservation.mainName}</td>
              <td>{reservation.mainStudentId}</td>
              <td>{reservation.roomName}</td>
              <td>{`${reservation.startTime} ~ ${reservation.endTime}`}</td>
              <td>
                <button className="request-button">
                  신청서 보기
                </button>
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
          <div className='classRoom_container'>
            <div className='classRoom'>
              <div className='classRoom_box'>
                <div className='classRoom_box_inner'>
                <p className='classRoom_title'>승인 강의실 예약내역</p> <button className='classRoom_add_button'>강의실 예약 추가하기</button>
                </div>
                <div className='classRoom_table'>
                <ApprovedTable reservations={approvedReservations}/>
                </div>
              </div>
              <div className='classRoom_box'>
                <div className='classRoom_box_inner'>
                <p className='classRoom_title'>미승인 강의실 예약내역</p>
                </div>
                <div className='classRoom_table'>
                <DynamicTable reservations={pendingReservations}/>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}

export default Room;