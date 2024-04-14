import React from 'react';
import Sidebar from './sideBar';
import Banner from './banner';

const Reserve = () => {

    return (
        <div className="main-container"> {/* 최상단 컨테이너 */}
          <Banner /> {/* 배너 컴포넌트를 최상단에 표시 */}
          <div className="sidebar-and-content"> {/* 사이드바와 내용을 담는 컨테이너 */}
            <Sidebar /> {/* 사이드바를 좌측에 표시 */}
            <div className="main-content"> {/* 메인 작업물을 표시하는 컨테이너 */}
            </div>
          </div>
        </div>
      );
    }
export default Reserve;