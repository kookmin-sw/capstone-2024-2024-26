import React, { useState, useEffect } from 'react';
import axios from 'axios';
import Sidebar from './sideBar';
import Banner from './banner';
import '../styles/traffic.css';

const Traffic = () => {
  const [showPopup, setShowPopup] = useState(false);
  const [cameras, setCameras] = useState([]);
  const [newCamera, setNewCamera] = useState({ building: '', location: '' });

  const fetchCameras = async () => {
    console.log("Fetching cameras from server..."); // 로깅 추가
    try {
      const response = await axios.get('http://localhost:3000/adminCamera/get');
      console.log("Response received:", response.data); // 응답 로깅
      if (response.data.cameras) {
        setCameras(response.data.cameras.map((camera, index) => ({
          id: index + 1,
          location: camera.location,
          status: null
        })));
      }
    } catch (error) {
      console.error('Failed to fetch cameras:', error);
      console.log("Error details:", error.response || error.message); // 오류 상세 로깅
    }
  };

  useEffect(() => {
    fetchCameras();
  }, []);

  const registerNewCamera = async () => {
    const userEmail = localStorage.getItem('userEmail');
    try {
      const response = await axios.post('http://localhost:3000/adminCamera/set', {
        headers: { email: userEmail },
        location: newCamera.location  // 바디 데이터
    }, {
      headers: { email: userEmail }  // 헤더 설정
    });
      if (response.status === 200) {
        setCameras([...cameras, { id: cameras.length + 1, location: newCamera.location, status: null }]);
        setShowPopup(false);
      } else {
        alert('Failed to add camera');
      }
    } catch (error) {
      console.error('Error creating camera:', error);
    }
  };

  const handleAddCamera = () => {
    setShowPopup(true);  // 팝업 또는 추가 폼을 표시할 수 있습니다.
  };

  const handleClosePopup = () => {
    setShowPopup(false);
};

const handleInputChange = (e) => {
  const { name, value } = e.target;
  setNewCamera(prevState => ({
    ...prevState,
    [name]: value
  }));
};

const handleCreateCamera = () => {
  const newId = cameras.length + 1; // 자동으로 ID 할당
  setCameras([...cameras, { ...newCamera, id: newId, status: null }]); // 새 카메라 정보 추가
  setShowPopup(false); // 팝업 닫기
  setNewCamera({ building: '', location: '' }); // 입력 필드 초기화
};

const handleButtonClick = () => {
  handleCreateCamera();
  registerNewCamera();
};


  const CameraTable = (
    <table>
      <thead>
        <tr>
          <th className='cameraTable_num'>카메라 번호</th>
          <th className='cameraTable_building'>건물 이름</th>
          <th className='cameraTable_location'>카메라 위치</th>
          <th className='cameraTable_status'>작동 여부</th>
          <th className='cameraTable_manage'>관리</th>
        </tr>
      </thead>
      <tbody>
        {cameras.map((camera) => (
          <tr key={camera.id}>
            <td>{camera.id}</td>
            <td>{camera.building}</td>
            <td>{camera.location}</td>
            <td>{camera.status || 'N/A'}</td>
            <td>
              <button >수정</button>
              <button onClick={() => alert('정말로 삭제하시겠습니까?')}>삭제</button>
            </td>
          </tr>
        ))}
      </tbody>
    </table>
  )
    return (
        <div className="main-container">
          <Banner />
          <div className="sidebar-and-content">
            <Sidebar />
            <div className="main-content">
                <div className='member_container'>
                    <div className='member_box'>
                        <div className='member_button'>
                        <p className='member_title'>혼잡도 카메라</p>
                        <button className='search_button' onClick={handleAddCamera}>+추가하기</button>
                        {showPopup && (
                          <div className='popup_camera'>
                            <div className='popup_inner'>
                              <div className='popup_inner_banner'>
                                <h2>카메라 등록</h2>
                                <button className='popup_inner_banner_back' onClick={handleClosePopup}>✖️</button>
                              </div>
                              <hr></hr>
                              <div className='popup_inner_input'>
                                <p className='popup_input_title'>건물이름</p>
                                <input
                                  type='text'
                                  name='building'
                                  placeholder='건물 이름'
                                  value={newCamera.building}
                                  onChange={handleInputChange}
                                />
                              </div>
                              <div className='popup_inner_input'>
                                <p className='popup_input_title'>카메라 위치</p>
                                <input
                                  type='text'
                                  name='location'
                                  placeholder='카메라 위치'
                                  value={newCamera.location}
                                  onChange={handleInputChange}
                                />
                              </div>
                              <button onClick={handleButtonClick}>생성하기</button>
                            </div>
                          </div>
                        )}
                        </div>
                        <hr></hr>
                        {CameraTable}
                    </div>
                    
                </div>
            </div>
          </div>
        </div>
      );
    }

export default Traffic;