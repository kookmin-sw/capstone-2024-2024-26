import React, { useState } from 'react';
import axios from 'axios';
import Sidebar from './sideBar';
import Banner from './banner';
import '../styles/pageManagement.css';


const PageManagement = () => {
  const initialRoomData = {
      roomName: '',
      available_Time: '',
      available_People: '',
      faculty: '',
      conferenceImage: null,
      preview: null,
  };

  const [showPopup, setShowPopup] = useState(false);
  const [roomData, setRoomData] = useState(initialRoomData);

  const handleInputChange = (e) => {
      const { name, value } = e.target;
      setRoomData((prevData) => ({ ...prevData, [name]: value }));
  };

  const handleFileChange = (e) => {
    const file = e.target.files[0];
    setRoomData((prevData) => ({ ...prevData, conferenceImage: file }));

    if (file) {
      const reader = new FileReader();
      reader.onloadend = () => {
        setRoomData((prevData) => ({ ...prevData, preview: reader.result }));
      };
      reader.readAsDataURL(file);
    }
  };

  const handleCreateRoom = async () => {
    if (roomData.conferenceImage) {
      const reader = new FileReader();
      reader.readAsDataURL(roomData.conferenceImage);
      reader.onload = async () => {
        try {
          const base64EncodedImage = reader.result.split(',')[1]; // 이미지 데이터만 추출
          const payload = {
            faculty: roomData.faculty,
            roomName: roomData.roomName,
            available_Time: roomData.available_Time,
            available_People: roomData.available_People,
            conferenceImage: base64EncodedImage, // Base64 인코딩된 이미지 데이터
          };

          console.log('Sending the following data to the server:', payload);

          const response = await axios.post('http://localhost:3000/adminRoom/create/room', payload, {
            headers: {
              'Content-Type': 'application/json',
            },
          });
          if (response.status === 200) {
            alert('강의실 생성 완료');
            resetRoomData();
            setShowPopup(false);
          }
        } catch (error) {
          console.error('Error creating room:', error);
          alert('강의실 생성 실패: 서버 오류가 발생했습니다');
        }
      };
      reader.onerror = error => {
        console.error('Error loading image:', error);
      };
    } else {
      alert('이미지를 추가해주세요.');
    }
  };

  const resetRoomData = () => {
      setRoomData(initialRoomData);
  };

  const handleClosePopup = () => {
      resetRoomData();
      setShowPopup(false);
  };

    return (
        <div className="main-container"> {/* 최상단 컨테이너 */}
          <Banner /> {/* 배너 컴포넌트를 최상단에 표시 */}
          <div className="sidebar-and-content"> {/* 사이드바와 내용을 담는 컨테이너 */}
            <Sidebar /> {/* 사이드바를 좌측에 표시 */}
            <div className="main-content">
              <div className='addition_container'>
                <div className='addition_box'>
                  <div className='addition_banner'>
                    <p className='addition_title'>강의실 관리</p>
                    <button className='addition_room_button' onClick={() => setShowPopup(true)}>강의실 추가</button>

                    {showPopup && (
                      <div className='popup'>
                        <div className='popup_inner'>
                          <div className='popup_inner_banner'>
                          <h2>강의실 생성</h2>
                          <button className='popup_inner_banner_back' onClick={handleClosePopup}>✖️</button>
                          </div>
                          <hr></hr>
                          <div className='popup_inner_input'>
                          <p className='popup_input_title'>단과대학</p>
                          <input
                            type='text'
                            name='faculty'
                            placeholder='단과대학'
                            value={roomData.faculty}
                            onChange={handleInputChange}
                          />
                          </div>
                          <div className='popup_inner_input'>
                          <p className='popup_input_title'>강의실 이름</p>
                          <input
                            type='text'
                            name='roomName'
                            placeholder='⬜⬜관 000호'
                            value={roomData.roomName}
                            onChange={handleInputChange}
                          />
                          </div>
                          <div className='popup_inner_input'>
                          <p className='popup_input_title'>사용가능 시간</p>
                          <input
                            type='text'
                            name='available_Time'
                            placeholder=" '00:00-00:00' "
                            value={roomData.available_Time}
                            onChange={handleInputChange}
                          />
                          </div>
                          <div className='popup_inner_input'>
                          <p className='popup_input_title'>수용 인원</p>
                          <input
                            type='text'
                            name='available_People'
                            placeholder='"00"'
                            value={roomData.available_People}
                            onChange={handleInputChange}
                          />
                          </div>
                          
                          <div className='popup_inner_input'>
                          {roomData.preview && (
                                                    <img
                                                        src={roomData.preview}
                                                        alt="미리보기"
                                                        className='image_preview'
                                                    />
                                                )}
                          <p className='popup_input_title'>사진 추가</p>
                          <input type='file' onChange={handleFileChange} />
                          </div>
                          </div>
                          <button onClick={handleCreateRoom}>생성하기</button>                          
                        </div>

                    )}

                  </div>
                  <hr></hr>
                  <div className='addition_chart'>
                    
                  </div>
                </div>
                <div className='blank'></div>
                <div className='addition_box'>
                  <div className='addition_banner'>
                    <p className='addition_title'>공유공간 관리</p>
                    <button className='addition_club_button'>공유공간 추가</button>
                  </div>
                  <hr></hr>
                  <div className='addition_chart'>
                  </div>
                </div>
              </div>
          </div>
          </div>
        </div>
      );
    }

export default PageManagement;