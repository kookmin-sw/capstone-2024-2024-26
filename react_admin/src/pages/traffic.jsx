import React, { useState, useEffect } from 'react';
import axios from 'axios';
import Sidebar from './sideBar';
import Banner from './banner';
import '../styles/traffic.css';
import Swal from 'sweetalert2';

const Traffic = () => {
  const [showPopup, setShowPopup] = useState(false);
  const [cameras, setCameras] = useState([]);
  const [newCamera, setNewCamera] = useState({ locationName: '', location: '' });


  //서버를 통해서 DB의 카메라 위치정보를 가져오는 이벤트 핸들러 함수
  const fetchCameras = async () => {
    console.log("Fetching cameras from server..."); // 로깅 추가
    try {
      const response = await axios.get('http://localhost:3000/adminCamera/get');
      console.log("Response received:", response.data); // 응답 로깅
      if (response.data.cameras) {
        setCameras(response.data.cameras.map((camera, index) => ({
          id: index + 1,
          locationName: camera.locationName,
          location: camera.location,
          state: camera.state,
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
    try {
      const requestData = {
        locationName: newCamera.location,
        location: newCamera.locationName  // 바디 데이터
      };
      console.log('Sending request data:', requestData);
      const response = await axios.post('http://localhost:3000/adminCamera/set', {
        locationName: newCamera.location,
        location: newCamera.locationName,  // 바디 데이터
    },);
      if (response.status === 200) {
        setCameras([...cameras, { id: cameras.length + 1, location: newCamera.locationName, locationName: newCamera.location}]);
        Swal.fire({
          icon: "success",
          title: "등록 성공!",
          text: "카메라가 성공적으로 등록되었습니다",
      });
        setShowPopup(false);
      } else {
        Swal.fire({
          icon: "error",
          title: "등록 실패!",
          text: "카메라 등록에 실패하였습니다",
      });
      }
    } catch (error) {
      console.error('Error creating camera:', error);
    }
  };

  //팝업 관련 함수들
  const handleAddCamera = () => {
    setShowPopup(true);  // 팝업 또는 추가 폼을 표시할 수 있습니다.
    setNewCamera({ locationName: '', location: '' });
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
  setNewCamera({ locationName: '', location: '' }); // 입력 필드 초기화
};

const handleButtonClick = () => {
  handleCreateCamera();
  registerNewCamera();
};



//서버를 통해서 DB의 카메라 위치 정보를 삭제하는 이벤트 핸들러 함수
const deleteCamera = async (event) => {
  const locationName = event.target.getAttribute('data-locationName');
  console.log("target locationName!:", locationName);
  try {
    const response = await axios.delete(`http://localhost:3000/adminCamera/delete/${locationName}`);
    if (response.status === 200) {
      console.log(response.data.message); // 성공 메시지 로깅
      Swal.fire({
        icon: "success",
        title: "삭제 성공!",
        text: "카메라를 성공적으로 삭제하였습니다",
    });
      setCameras(prevCameras => prevCameras.filter(camera => camera.locationName !== locationName)); // 상태에서 카메라 삭제
    }
  } catch (error) {
    console.error('Error:', error);
    Swal.fire({
      icon: "error",
      title: "삭제 실패!",
      text: "카메라 삭제에 실패하였습니다",
  });
  }
};


  const CameraTable = (
    <table>
      <thead>
        <tr>
          <th className='cameraTable_num'>카메라 번호</th>
          <th className='cameraTable_locationName'>건물</th>
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
            <td>{camera.locationName}</td>
            <td>{camera.state === "1" ? '작동 중' : '미작동 중'}</td>
            <td>
              <button className='traffic_delete_button' data-locationName={camera.locationName} onClick={deleteCamera}>삭제</button>
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
                          <div className='popup_camera_background'>
                          <div className='popup_camera'>
                            <div className='popup_camera_inner'>
                              <div className='popup_inner_banner'>
                                <h2>카메라 등록</h2>
                                <button className='popup_traffic_banner_back' onClick={handleClosePopup}>닫기</button>
                              </div>
                              <hr></hr>
                              <div className='popup_inner_input'>
                                <p className='camera_input_title'>건물이름</p>
                                <input
                                  className='camera_input_data'
                                  type='text'
                                  name='locationName'
                                  placeholder='건물 이름'
                                  value={newCamera.locationName}
                                  onChange={handleInputChange}
                                />
                              </div>
                              <div className='popup_inner_input'>
                                <p className='camera_input_title'>카메라 위치</p>
                                <input
                                  className='camera_input_data'
                                  type='text'
                                  name='location'
                                  placeholder='카메라 위치'
                                  value={newCamera.location}
                                  onChange={handleInputChange}
                                />
                              </div>
                              <button className='traffic_add_button' onClick={handleButtonClick}>생성하기</button>
                            </div>
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