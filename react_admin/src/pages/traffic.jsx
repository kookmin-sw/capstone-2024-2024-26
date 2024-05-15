import React, { useState, useEffect } from 'react';
import axios from 'axios';
import Sidebar from './sideBar';
import Banner from './banner';
import '../styles/traffic.css';

const Traffic = () => {
  const [showPopup, setShowPopup] = useState(false);
  const [showEditPopup, setShowEditPopup] = useState(false);
  const [cameras, setCameras] = useState([]);
  const [newCamera, setNewCamera] = useState({ building: '', location: '' });
  const [selectedCamera, setSelectedCamera] = useState({});// 선택된 카메라 정보를 저장
  const [newLocation, setNewLocation] = useState('');  // 수정할 새 위치 정보


  //서버를 통해서 DB의 카메라 위치정보를 가져오는 이벤트 핸들러 함수
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


  //서버를 통해서 DB에 새로운 카메라 위치 정보를 등록하는 이벤트 핸들러 함수
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

  //팝업 관련 함수들
  const handleAddCamera = () => {
    setShowPopup(true);  // 팝업 또는 추가 폼을 표시할 수 있습니다.
    setNewCamera({ building: '', location: '' });
  };

  const handleEditCameraPopup = (camera) => {
    setSelectedCamera(camera);  // 현재 선택된 카메라 정보 설정
    setNewLocation(camera.location);  // 팝업에 현재 위치 정보를 기본값으로 설정
    setShowEditPopup(true);  // 수정 팝업 표시
  };

  const handleClosePopup = () => {
    setShowPopup(false);
    setShowEditPopup(false);
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



//서버를 통해서 DB의 카메라 위치 정보를 삭제하는 이벤트 핸들러 함수
const deleteCamera = async (event) => {
  const location = event.target.getAttribute('data-location');
  console.log("target location!:", location);
  try {
    const response = await axios.delete(`http://localhost:3000/adminCamera/delete/${location}`);
    if (response.status === 200) {
      console.log(response.data.message); // 성공 메시지 로깅
      alert('Camera location deleted successfully'); // 사용자에게 성공 알림
      setCameras(prevCameras => prevCameras.filter(camera => camera.location !== location)); // 상태에서 카메라 삭제
    }
  } catch (error) {
    console.error('Error:', error);
    alert('Failed to delete the camera location'); // 에러 발생시 사용자에게 알림
  }
};

const updateCameraLocation = async () => {
  try {
    const response = await axios.patch(`http://localhost:3000/adminCamera/update/${selectedCamera.location}`, {
      location: newLocation
    });

    if (response.status === 200) {
      console.log(response.data.message);
      alert('Camera location updated successfully');
      fetchCameras(); // 카메라 목록을 다시 불러옵니다
      setShowEditPopup(false);  // 수정 팝업 닫기
    } else {
      throw new Error('Failed to update camera location');
    }
  } catch (error) {
    console.error('Error updating camera location:', error);
    alert('Failed to update camera location');
  }
};

  const CameraTable = (
    <table>
      <thead>
        <tr>
          <th className='cameraTable_num'>카메라 번호</th>
          <th className='cameraTable_location'>카메라 위치</th>
          <th className='cameraTable_status'>작동 여부</th>
          <th className='cameraTable_manage'>관리</th>
        </tr>
      </thead>
      <tbody>
        {cameras.map((camera) => (
          <tr key={camera.id}>
            <td>{camera.id}</td>
            <td>{camera.location}</td>
            <td>{camera.status || 'N/A'}</td>
            <td>
              <button className='traffic_edit_button' data-location={camera.location} onClick={() => handleEditCameraPopup(camera)}>수정</button>
              <button className='traffic_delete_button' data-location={camera.location} onClick={deleteCamera}>삭제</button>
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
                        <button className='traffic_button' onClick={handleAddCamera}>추가하기</button>
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
                        {showEditPopup && (
                          <div className='popup_camera'>
                            <div className='popup_inner'>
                            <div className='popup_inner_banner'>
                              <h2>카메라 등록</h2>
                              <button className='popup_inner_banner_back' onClick={handleClosePopup}>✖️</button>
                              </div>
                              <hr></hr>
                              <div className='popup_inner_input'>
                                <p className='popup_input_title'>카메라 위치 수정</p>
                                <input
                                  type='text'
                                  name='building'
                                  placeholder='Enter new location'
                                  value={newLocation}
                                  onChange={(e) => setNewLocation(e.target.value)}
                                />
                              </div>
                              <button onClick={updateCameraLocation}>수정하기</button>
                            </div>
                          </div>
                        )}
                    </div>
                    
                </div>
            </div>
          </div>
        </div>
      );
    }

export default Traffic;