import React, { useState, useEffect } from 'react';
import axios from 'axios';
import Sidebar from './sideBar';
import Banner from './banner';
import '../styles/pageManagement.css';
import Swal from 'sweetalert2';


const PageManagement = () => {
  //강의실 데이터 초기화
  const initialRoomData = {
    roomName: '',
    available_Time: '',
    available_People: '',
    available_Table: '',
    faculty: '',
    conferenceImage: null,
    conferenceImagePreview: null,
    clubRoomImage: null,
    clubRoomDesignImage: null,
    preview: null,
    clubRoomImagePreview: null,
    clubRoomDesignImagePreview: null
  };

  const [showRoomPopup, setShowRoomPopup] = useState(false);
  const [showClubPopup, setShowClubPopup] = useState(false);
  const [roomData, setRoomData] = useState(initialRoomData);
  const [conferenceInfo, setConferenceInfo] = useState([]);
  const [clubRoomInfo, setClubRoomInfo] = useState([]);
  const [tableSeats, setTableSeats] = useState([]);
  const [tableImages, setTableImages] = useState([]);

  //추가된 강의실 정보 사이드 이펙트 실행 함수 : 리액트 컴포넌트가 랜더링 된 뒤에 작업이 이루어짐
  useEffect(() => {
    const fetchConferenceInfo = async () => {
      const faculty = localStorage.getItem('faculty');
      try {
        const response = await axios.get(`http://localhost:3000/adminRoom/conferenceInfo/${faculty}`);
        if (response.status === 200) {
          setConferenceInfo(response.data.allConferenceInfo);
        } else {
          console.error('Failed to fetch conference info');
        }
      } catch (error) {
        console.error('Error while fetching conference info:', error);
      }
    };

    if (localStorage.getItem('faculty')) {
      fetchConferenceInfo();
    }
  }, []);

  //공유공간(동아리방) 정보 사이드 이펙트 실행 함수 : 리액트 컴포넌트가 랜더링 된 뒤에 작업이 이루어짐
  useEffect(() => {
    const fetchClubRoomInfo = async () => {
      const faculty = localStorage.getItem('faculty'); // 로컬 스토리지에서 faculty 정보 가져오기
      if (faculty) {
        try {
          const response = await axios.get(`http://localhost:3000/adminClub/clubRoomInfo/${faculty}`);
          if (response.status === 200) {
            setClubRoomInfo(response.data.allClubRoomInfo); // 상태 업데이트
          } else {
            console.error('Failed to fetch club room info');
          }
        } catch (error) {
          console.error('Error while fetching club room info:', error);
        }
      }
    };

    fetchClubRoomInfo();
  }, []);


  const handleInputChange = (e) => {
      const { name, value } = e.target;
      setRoomData((prevData) => ({ ...prevData, [name]: value }));
  };

  const handleFileChange = (e) => {
    const { name, files } = e.target;
    const file = files[0];
    if (file) {
      const reader = new FileReader();
      reader.onloadend = () => {
        setRoomData(prevData => ({ ...prevData, [name]: file, [`${name}Preview`]: reader.result }));
      };
      reader.readAsDataURL(file);
    } else {
      setRoomData(prevData => ({ ...prevData, [`${name}Preview`]: null }));
    }
  };

  //강의실 생성 이벤트 핸들러 함수
  const handleCreateRoom = async () => {
    if (roomData.conferenceImage) {
      const reader = new FileReader();
      reader.readAsDataURL(roomData.conferenceImage);
      reader.onload = async () => {
        try {
          const base64EncodedImage = reader.result.split(',')[1]; // 이미지 데이터만 추출
          const payload = {
            faculty: roomData.faculty, //단과대학
            roomName: roomData.roomName, //건물,강의실번호
            available_Time: roomData.available_Time, //사용가능 시간
            available_People: roomData.available_People, //사용가능 인원 수
            conferenceImage: base64EncodedImage, // Base64 인코딩된 이미지 데이터
          };

          localStorage.setItem('faculty', roomData.faculty); //로컬 스토리지에 단과대학 저장 : 강의실 불러올때 사용할 데이터
          console.log('Sending the following data to the server:', payload);

          const response = await axios.post('http://localhost:3000/adminRoom/create/room', payload, {
            headers: {
              'Content-Type': 'application/json',
            },
          });
          if (response.status === 200) {
            Swal.fire({
              icon: "success",
              title: "생성 완료!",
              text: "강의실이 성공적으로 등록되었습니다",
          });
            resetRoomData();
            setShowRoomPopup(false);
          }
        } catch (error) {
          console.error('Error creating room:', error);
          Swal.fire({
            icon: "error",
            title: "생성 실패!",
            text: "서버에 오류가 발생하였습니다",
        });
        }
      };
      reader.onerror = error => {
        console.error('Error loading image:', error);
      };
    } else {
      Swal.fire({
        icon: "question",
        title: "생성 실패!",
        text: "이미지를 올바르게 등록해주세요",
    });
    }
  };

  const resetRoomData = () => {
      setRoomData(initialRoomData);
  };

  const handleCloseRoomPopup = () => {
    resetRoomData();
    setShowRoomPopup(false);
};

const handleCloseClubPopup = () => {
    resetRoomData();
    setShowClubPopup(false);
};

  //강의실 삭제 이벤트 핸들러 함수 : 버튼 클릭시 저장된 Uid를 통해서 서버에 요청을 보냄
  const handleDeleteRoom = async (roomName, faculty) => {
    try {
      const response = await axios.delete('http://localhost:3000/adminRoom/delete/conferenceInfo', {
        data: { faculty, roomName }
      });
  
      if (response.status === 200) {
        Swal.fire({
          icon: "success",
          title: "삭제 성공!",
          text: "강의실이 성공적으로 삭제되었습니다",
      });
        setConferenceInfo(conferenceInfo.filter(info => info.roomName !== roomName));
      }
    } catch (error) {
      console.error('Error deleting room:', error);
      Swal.fire({
        icon: "error",
        title: "삭제 실패!",
        text: "강의실 삭제에 실패하였습니다",
    });
    }
  };


  const handleTableImageChange = (index, file) => {
    const reader = new FileReader();
    reader.onloadend = () => {
      const newImages = [...tableImages];
      newImages[index] = reader.result;
      setTableImages(newImages);
    };
    reader.readAsDataURL(file);
  };


  //공유공간 관련 함수 시작 구간
  //공유공간 추가 이벤트 핸들러 함수 : 사진 2개 인코딩(공유공간사진, 공유공간도안)
  const handleCreateClub = async () => {
    if (roomData.clubRoomImage && roomData.clubRoomDesignImage) {
      try {
        const reader1 = new FileReader();
        const reader2 = new FileReader();
  
        reader1.readAsDataURL(roomData.clubRoomImage);
        reader2.readAsDataURL(roomData.clubRoomDesignImage);
  
        reader1.onload = async () => {
          const clubRoomImageEncoded = reader1.result.split(',')[1];
          reader2.onload = async () => {
            const clubRoomDesignImageEncoded = reader2.result.split(',')[1];
  
            const tableList = tableSeats.map((seat, index) => ({
              available: seat,
              table_name: `T${index + 1}`,
              table_status: 'true',
            }));
  
            const payload = {
              faculty: roomData.faculty,
              roomName: roomData.roomName,
              available_Table: roomData.available_Table,
              tableList: tableList,
              available_People: roomData.available_People,
              available_Time: roomData.available_Time,
              clubRoomImage: clubRoomImageEncoded,
              clubRoomDesignImage: clubRoomDesignImageEncoded,
            };
  
            const response = await axios.post('http://localhost:3000/adminClub/create/room', payload, {
              headers: {
                'Content-Type': 'application/json'
              }
            });
  
            if (response.status === 200) {
              Swal.fire({
                icon: "success",
                title: "등록 성공!",
                text: "공유공간이 성공적으로 등록되었습니다",
            });
              setClubRoomInfo(prev => [...prev, response.data]);
              resetRoomData();
              setShowClubPopup(false);
            }
          };
        };
      } catch (error) {
        console.error('Error creating club room:', error);
        Swal.fire({
          icon: "error",
          title: "등록 실패!",
          text: "공유공간 등록에 실패하였습니다",
      });
      }
    } else {
      Swal.fire({
        icon: "error",
        title: "등록 실패!",
        text: "이미지 2개를 모두 등록해주세요",
    });
    }
  };

  // 테이블 개수 입력 변경 핸들러
const handleTableCountChange = (e) => {
  const { value } = e.target;
  setRoomData((prevData) => ({ ...prevData, available_Table: value }));
};

// 입력 버튼 클릭 핸들러
const handleTableCountSubmit = () => {
  const count = parseInt(roomData.available_Table, 10);
  if (!isNaN(count) && count > 0) {
    setTableSeats(Array(count).fill(''));
  } else {
    setTableSeats([]);
  }
};

// 테이블 좌석 수 입력 변경 핸들러
const handleTableSeatChange = (index, value) => {
  const newSeats = [...tableSeats];
  newSeats[index] = value;
  setTableSeats(newSeats);
};

  //공유공간(동아리방)삭제 이벤트 핸들러 함수 : 버튼에 있는 Uid값으로 요청을 보냄
  const handleDeleteClubRoom = async (faculty, roomName) => {
    try {
      const response = await axios.delete('http://localhost:3000/adminClub/delete/clubRoomInfo', {
        data: { faculty, roomName },
      });
  
      if (response.status === 200) {
        Swal.fire({
          icon: "success",
          title: "삭제 성공!",
          text: "공유공간을 삭제했습니다",
      });
        // 삭제 후 상태 업데이트
        setClubRoomInfo(prev => prev.filter(info => info.roomName !== roomName || info.faculty !== faculty));
      }
    } catch (error) {
      console.error('Error deleting club room:', error);
      Swal.fire({
        icon: "error",
        title: "삭제 실패!",
        text: "공유공간 삭제에 실패하였습니다",
    });
    }
  };


    return (
        <div className="main-container">
          <Banner />
          <div className="sidebar-and-content">
            <Sidebar />
            <div className="main-content">
              <div className='addition_container'>
                <div className='addition_box'>
                  <div className='addition_banner'>
                    <p className='addition_title'>강의실 관리</p>
                    <button className='addition_room_button' onClick={() => setShowRoomPopup(true)}>추가하기</button>

                    {showRoomPopup && (
                      <div className='popup_class_background'>
                      <div className='popup_class'>
                        <div className='popup_inner'>
                          <div className='popup_inner_banner'>
                          <h2 className='popup_room_banner_title'>강의실 생성</h2>
                          <button className='popup_room_banner_back' onClick={handleCloseRoomPopup}>닫기</button>
                          </div>
                          <hr className='divide_line'></hr>
                          <div className='popup_inner_Club'>
                          <div className='popup_inner_input'>
                          <p className='popup_input_title'>단과대학</p>
                          <input
                            className='room_inputdata'
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
                            className='room_inputdata'
                            type='text'
                            name='roomName'
                            placeholder='00관 000호'
                            value={roomData.roomName}
                            onChange={handleInputChange}
                          />
                          </div>
                          <div className='popup_inner_input'>
                          <p className='popup_input_title'>사용가능 시간</p>
                          <input
                            className='room_inputdata'
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
                            className='room_inputdata'
                            type='text'
                            name='available_People'
                            placeholder='"00"'
                            value={roomData.available_People}
                            onChange={handleInputChange}
                          />
                          </div>
                          <div className='popup_inner_input'>
                          {roomData.conferenceImagePreview && (
                                                    <img
                                                        src={roomData.conferenceImagePreview}
                                                        alt="미리보기"
                                                        className='image_preview'
                                                    />
                                                )}
                          <p className='popup_input_title'>사진 추가</p>
                          <input type='file' name='conferenceImage' onChange={handleFileChange} />
                          </div>
                          </div>
                          </div>
                          <button className='popup_creatRoom_button' onClick={handleCreateRoom}>생성하기</button>                          
                        </div>
                        </div>

                    )}

                  </div>
                  <hr className='divide_line'></hr>
                  <div className='addition_chart'>
                  {conferenceInfo.length > 0 ? (
                  <ul>
                    {conferenceInfo.map((info, index) => (
                      <li key={index}>
                        <div className='addition_chart_element'>
                          <div className='chart_element_image'>
                          {info.conferenceImage && <img src={`data:image/jpeg;base64,${info.conferenceImage}`} alt="Conference Room" className="roomImage_preview" />}
                          </div>
                          <div className='chart_element_data'>
                            <p>{info.faculty}</p>
                            <p>강의실: {info.roomName}</p>
                            <p>사용가능 시간: {info.available_Time}</p>
                            <p>사용가능 인원: {info.available_People}</p>
                            <button className='room_delete_button' onClick={() => handleDeleteRoom(info.roomName, info.faculty)}>삭제</button>
                          </div>
                        </div>
                        </li>
                    ))}
                  </ul>
                ) : (
                  <p>No conference information available.</p>
                )}
                  </div>
                </div>
                <div className='blank'></div>
                <div className='addition_box'>
                  <div className='addition_banner'>
                    <p className='addition_title'>공유공간 관리</p>
                    <button className='addition_club_button' onClick={() => setShowClubPopup(true)}>추가하기</button>
                    {showClubPopup && (
                      <div className='popup_room_background'>
                      <div className='popup_room'>
                        <div className='popup_inner'>
                          <div className='popup_inner_banner'>
                          <h2 className='popup_club_banner_title'>공유공간 생성</h2>
                          <button className='popup_club_banner_back' onClick={handleCloseClubPopup}>닫기</button>
                          </div>
                          <hr className='divide_line'></hr>
                          <div className='popup_inner_box'>
                          <div className='popup_inner_input_data'>
                          <div className='popup_inner_input'>
                          <p className='popup_input_title'>단과대학</p>
                          <input
                            className='room_inputdata'
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
                            className='room_inputdata'
                            type='text'
                            name='roomName'
                            placeholder='00관 000호'
                            value={roomData.roomName}
                            onChange={handleInputChange}
                          />
                          <div className='popup_inner_input'>
                          <p className='popup_input_title'>사용가능 테이블</p>
                          <input
                            className='room_inputdata'
                            type='text'
                            name='available_Table'
                            placeholder=" '00' "
                            value={roomData.available_Table}
                            onChange={handleTableCountChange}
                          />
                          <button onClick={handleTableCountSubmit}>입력</button>
                          </div>
                          {tableSeats.map((seat, index) => (
  <div className='popup_inner_input' key={index}>
    <p className='popup_input_title'>T{index + 1} 좌석 수</p>
    <input
      className='room_inputdata'
      type='text'
      value={seat}
      onChange={(e) => handleTableSeatChange(index, e.target.value)}
      placeholder='좌석 수 입력'
    />
    <p className='popup_input_title'>T{index + 1} 테이블 이미지</p>
    {tableImages[index] && (
                                    <img
                                      src={tableImages[index]}
                                      alt={`미리보기 T${index + 1}`}
                                      className='image_preview'
                                    />
                                  )}                          
    <input
      type='file'
      onChange={(e) => handleTableImageChange(index, e.target.files[0])}
    />
  </div>
))}
                          </div>
                          <div className='popup_inner_input'>
                          <p className='popup_input_title'>수용 인원</p>
                          <input
                            className='room_inputdata'
                            type='text'
                            name='available_People'
                            placeholder='"00"'
                            value={roomData.available_People}
                            onChange={handleInputChange}
                          />
                          </div>
                          <div className='popup_inner_input'>
                          <p className='popup_input_title'>사용가능 시간</p>
                          <input
                            className='room_inputdata'
                            type='text'
                            name='available_Time'
                            placeholder=" '00:00-00:00' "
                            value={roomData.available_Time}
                            onChange={handleInputChange}
                          />
                          </div>
                          </div>
                          <div className='popup_inner_input_image'>
                          <div className='popup_inner_input_image1'>
                          {roomData.clubRoomImagePreview && (
                                                    <img
                                                        src={roomData.clubRoomImagePreview}
                                                        alt="미리보기"
                                                        className='image_preview'
                                                    />
                                                )}
                          <p className='popup_input_title'>공유공간 사진</p>
                          <input type='file' name="clubRoomImage" onChange={handleFileChange} />
                          </div>

                          <div className='popup_inner_input_image2'>
                          {roomData.clubRoomDesignImagePreview && (
                                                    <img
                                                        src={roomData.clubRoomDesignImagePreview}
                                                        alt="미리보기"
                                                        className='image_preview'
                                                    />
                                                )}
                          <p className='popup_input_title'>공유공간 도안</p>
                          </div>
                          <input type='file' name="clubRoomDesignImage" onChange={handleFileChange} />
                          </div>
                          </div>
                          <button className='popup_createClub_button' onClick={handleCreateClub}>생성하기</button>                          
                        </div>
                        </div>
                        </div>

                    )}

                  </div>
                  <hr className='divide_line'></hr>
                  <div className='addition_chart'>
                  {clubRoomInfo.length > 0 ? (
          <ul>
            {clubRoomInfo.map((room, index) => (
        <li key={index}>
          <div className='addition_chart_element'>
            <div className='chart_element_image'>
              {room.clubRoomImage ? (
                <img src={`data:image/jpeg;base64,${room.clubRoomImage}`} alt="Club Room" className="roomImage_preview" />
              ) : (
                <p>No Image Available</p>
              )}
            </div>
            <div className='chart_element_data'>
              <p>{room.faculty}</p>
              <p>강의실: {room.roomName}</p>
              <p>사용가능 시간: {room.available_Time}</p>
              <p>사용가능 인원: {room.available_People}</p>
              <p>테이블 개수: {room.available_Table}</p>
              <button className='club_delete_button' onClick={() => handleDeleteClubRoom(room.faculty, room.roomName)}>삭제하기</button>
            </div>
          </div>
        </li>
      ))}
    </ul>
  ) : (
    <p>No club room information available.</p>
  )}
                  </div>
                </div>
              </div>
          </div>
          </div>
        </div>
      );
    }

export default PageManagement;