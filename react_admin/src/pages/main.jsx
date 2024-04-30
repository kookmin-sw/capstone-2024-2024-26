import React from 'react';
import Sidebar from './sideBar';
import Banner from './banner';
import '../styles/main.css';

const Main = () => {


  return (
    <div className="main-container"> {/* 최상단 컨테이너 */}
      <Banner /> {/* 배너 컴포넌트를 최상단에 표시 */}
      <div className="sidebar-and-content"> {/* 사이드바와 내용을 담는 컨테이너 */}
        <Sidebar /> {/* 사이드바를 좌측에 표시 */}
        <div className="main-content">
          <div className='home_container'>
            <div className='todo_container'>
              <div className='todo_name'>
                <p className='name_todo'>오늘의 할 일</p>
                <hr></hr>
                <div className='todo_function'></div>
              </div>
            </div>
            <div className='graph_container'>
              <div className='graph1'>
                <p className='name_todo'>방문자 현황</p>
                <hr></hr>
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