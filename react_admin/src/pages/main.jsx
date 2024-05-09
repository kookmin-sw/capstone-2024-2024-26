import React, { useState, useEffect } from 'react';
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

  useEffect(() => {
    const fetchLoginData = async () => {
      try {
        const response = await axios.get('http://localhost:3000/adminAuth/login-data');
        setLoginData(response.data);
        console.log("Login data fetched successfully:", response.data);

        // 데이터를 날짜 키로 정렬하고, 가장 최신 데이터의 방문자 수를 업데이트합니다.
        const dates = Object.keys(response.data).sort();
        const mostRecentDate = dates[dates.length - 1];
        setLatestVisitorCount(response.data[mostRecentDate]);
      } catch (error) {
        console.error('Failed to fetch login data:', error);
      }
    };

    fetchLoginData();
  }, []);

  const data = {
    labels: Object.keys(loginData).map(date => new Date(date)), // 날짜 데이터를 Date 객체로 변환합니다.
    datasets: [
      {
        label: 'Daily Login Count',
        data: Object.values(loginData),
        backgroundColor: 'rgba(53, 162, 235, 0.5)',
      }
    ]
  };

  const options = {
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
                  <p className='name_todo1'>오늘의 할 일</p> <div className='todo_number1'>14</div>
                </div>
                <hr></hr>
                <div className='todo_function'>
                <div className='todo_box'>
                  <p className='name_todo'>강의실 예약</p> <div className='todo_number'>10</div>
                </div>
                <div className='todo_box'>
                  <p className='name_todo'>공유공간 예약</p> <div className='todo_number'>5</div>
                </div>
                <div className='todo_box'>
                <p className='name_todo'>어제 방문자 수</p> <div className='todo_number'>{latestVisitorCount}</div>
                </div>
                <div className='todo_box'>
                  <p className='name_todo'>문의</p> <div className='todo_number'>4</div>
                </div>
                </div>
              </div>
            </div>
            <div className='graph_container'>
              <div className='graph1'>
                <p className='name_todo'>방문자 현황</p>
                <hr></hr>
                <Bar data={data} options={options} />
              </div>

              <div className='graph2'>
                <p className='name_todo'>예약 현황</p>
                <hr></hr>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}

export default Main;