import React, { useState, useEffect } from 'react';
import { Link } from 'react-router-dom';
import Sidebar from './sideBar';
import Banner from './banner';
import axios from 'axios';
import '../styles/main.css';
import { Bar } from 'react-chartjs-2';
import { Chart, registerables } from 'chart.js';
import 'chartjs-adapter-date-fns';

Chart.register(...registerables);

const Main = () => {
  const [loginData, setLoginData] = useState({});
  const [latestVisitorCount, setLatestVisitorCount] = useState(0); // 최신 방문자 수를 저장할 상태 추가
  const [reservationCounts, setReservationCounts] = useState({
    lectureRoom: 0,
    sharedSpace: 5, // 임시 값
    inquiry: 0 // 초기값을 0으로 설정
  });
  const [todayTaskCount, setTodayTaskCount] = useState(0); // 오늘 할 일 숫자 상태 추가

  useEffect(() => {
    const fetchLoginData = async () => {
      try {
        const response = await axios.get('http://localhost:3000/adminAuth/login-data');
        setLoginData(response.data);

        // 데이터를 날짜 키로 정렬하고, 가장 최신 데이터의 방문자 수를 업데이트합니다.
        const dates = Object.keys(response.data).sort();
        const mostRecentDate = dates[dates.length - 1];
        setLatestVisitorCount(response.data[mostRecentDate]);
      } catch (error) {
      }
    };

    fetchLoginData();

    // 로컬 스토리지에서 저장된 예약 개수를 가져옵니다.
    const pendingReservationsCount = parseInt(localStorage.getItem('pendingReservationsCount'), 10) || 0;
    const approvedReservationsCount = parseInt(localStorage.getItem('approvedReservationsCount'), 10) || 0;
    const inquiryCount = parseInt(localStorage.getItem('inquiryCount'), 10) || 0;

    setReservationCounts(prevCounts => ({
      ...prevCounts,
      lectureRoom: pendingReservationsCount,
      sharedSpace: approvedReservationsCount,
      inquiry: inquiryCount
    }));

    // 오늘 할 일 숫자 상태 업데이트
    setTodayTaskCount(pendingReservationsCount + inquiryCount);

  }, []);

  const loginChartData = {
    labels: Object.keys(loginData).map(date => new Date(date)), // 날짜 데이터를 Date 객체로 변환합니다.
    datasets: [
      {
        label: 'Daily Login Count',
        data: Object.values(loginData),
        backgroundColor: 'rgba(53, 162, 235, 0.5)',
      }
    ]
  };

  const loginChartOptions = {
    scales: {
      x: {
        type: 'time',  // 시간 축으로 설정
        time: {
          unit: 'day',
          tooltipFormat: 'yyyy-MM-dd',
          displayFormats: {
            day: 'yyyy-MM-dd'
          }
        },
        title: {
          display: true,
          text: 'Date'
        }
      },
      y: {
        beginAtZero: true,
        title: {
          display: true,
          text: 'Count'
        }
      }
    }
  };

  const reservationChartData = {
    labels: ['미승인 강의실', '승인 강의실', '문의'],
    datasets: [
      {
        label: 'Reservation Status',
        data: [reservationCounts.lectureRoom, reservationCounts.sharedSpace, reservationCounts.inquiry], // 로컬 스토리지에서 가져온 데이터 사용
        backgroundColor: 'rgba(75, 192, 192, 0.5)',
      }
    ]
  };

  const reservationChartOptions = {
    scales: {
      x: {
        title: {
          display: true,
          text: 'Category'
        }
      },
      y: {
        beginAtZero: true,
        title: {
          display: true,
          text: 'Count'
        }
      }
    }
  };

  return (
    <div className="main-container"> {/* 최상단 컨테이너 */}
      <Banner /> {/* 배너 컴포넌트를 최상단에 표시 */}
      <div className="sidebar-and-content"> {/* 사이드바와 내용을 담는 컨테이너 */}
        <Sidebar /> {/* 사이드바를 좌측에 표시 */}
        <div className="main-content">
          <div className='home_container'>
            <div className='todo_container'>
              <div className='todo_name'>
                <div className='todo_box1'>
                  <p className='name_todo1'>오늘의 할 일</p> <div className='todo_number1'>{todayTaskCount}</div>
                </div>
                <hr></hr>
                <div className='todo_function'>
                <div className='todo_box'>
                  <Link to="/Room">
                  <p className='name_todo'>미승인 강의실 예약</p>
                  </Link>
                  <div className='todo_number'>{reservationCounts.lectureRoom}</div>
                </div>
                <div className='todo_box'>
                  <Link to="/Room">
                  <p className='name_todo'>승인 강의실 예약</p>
                  </Link>
                  <div className='todo_number'>{reservationCounts.sharedSpace}</div>
                </div>
                <div className='todo_box'>
                <p className='name_todo'>어제 방문자 수</p> <div className='todo_number'>{latestVisitorCount}</div>
                </div>
                <div className='todo_box'>
                  <Link to="/Inquiry">
                  <p className='name_todo'>문의</p>
                  </Link>
                  <div className='todo_number'>{reservationCounts.inquiry}</div>
                </div>
                </div>
              </div>
            </div>
            <div className='graph_container'>
              <div className='graph1'>
                <p className='visitor_graph'>방문자 현황</p>
                <hr></hr>
                <Bar data={loginChartData} options={loginChartOptions} />
              </div>

              <div className='graph2'>
                <p className='todo_table'>예약 현황</p>
                <hr></hr>
                <Bar data={reservationChartData} options={reservationChartOptions} />
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}

export default Main;