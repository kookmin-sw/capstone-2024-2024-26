import React, { useState, useEffect } from 'react';
import axios from 'axios';
import Sidebar from './sideBar';
import Banner from './banner';
import '../styles/room.css';

//구현 기능 : 강의실 예약내역불러오기, 강의실 신청 승인, 강의실 예약 삭제, 
const Room = () => {

  const [approvedReservations, setApprovedReservations] = useState([]);
  const [pendingReservations, setPendingReservations] = useState([]);
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [currentReservation, setCurrentReservation] = useState(null);
  const [showApproveButton, setShowApproveButton] = useState(true);
  const [isReservationModalOpen, setIsReservationModalOpen] = useState(false);

  const handleOpenReservationModal = () => {
    setIsReservationModalOpen(true);
  };

  const handleCloseReservationModal = () => {
    setIsReservationModalOpen(false);
  };

  //새로운 강의실 예약 생성 이벤트 핸들러함수
  const handleAddReservation = async (reservationData) => {
    console.log("Sending reservation data to server:", reservationData);
    try {
      const response = await axios.post('http://localhost:3000/adminRoom/reserve', reservationData);
      if (response.status === 201) {
        alert('예약이 성공적으로 추가되었습니다.');
        // 예약 목록을 새로 고침
      } else {
        throw new Error('Failed to add reservation');
      }
    } catch (error) {
      console.error('예약 추가에 실패했습니다:', error);
      alert('예약 추가에 실패했습니다.');
    }
    handleCloseReservationModal();
  };

  const handleOpenModal = (reservation, isApproved = false) => {
    setCurrentReservation(reservation);
    setIsModalOpen(true);
    setShowApproveButton(!isApproved); // 승인된 내역이면 false, 아니면 true
  };

  const handleCloseModal = () => {
    setIsModalOpen(false);
  };


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
        if (response.data && response.data.confirmReservations) {  // 응답 데이터의 키를 확인하고 조정
          setApprovedReservations(response.data.confirmReservations);  // 변경된 키 사용
          localStorage.setItem('approvedReservationsCount', response.data.confirmReservations.length);
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
        if (response.data && response.data.notConfirmReservations) {
          const filteredReservations = response.data.notConfirmReservations.filter(reservation => !reservation.boolAgree);
          setPendingReservations(filteredReservations);
          localStorage.setItem('pendingReservationsCount', filteredReservations.length);
        }
      } catch (error) {
        console.error('Failed to fetch pending reservations:', error);
      }
    };

    fetchApprovedReservations();
    fetchPendingReservations();
  }, []);


  //미승인 강의실 예약 승인 이벤트 핸들러 함수
  //예약 시간의 간격에 따라 케이스 분리 : 파이어스토어가 한시간 단위로 처리해서
  const handleApproveReservation = async (reservation) => {
    // reservation 객체에서 필요한 데이터 추출
    const { mainStudentId, roomName, date, startTime, endTime } = reservation;
    console.log("Preparing to send data to server:", { mainStudentId, roomName, date, startTime, endTime });

    // 시간 처리를 위한 로직
    const startTimeHour = parseInt(startTime.split(":")[0]);
    const endTimeHour = parseInt(endTime.split(":")[0]);

    try {
      for (let hour = startTimeHour; hour < endTimeHour; hour++) {
        const start = hour.toString(); // '11:00' 대신 '11'로 표현
        const end = (hour + 1).toString(); // '12:00' 대신 '12'로 표현

        console.log("Sending data to server for time slot:", { studentId: mainStudentId, roomName, date, start, end });

        const response = await axios.post('http://localhost:3000/adminRoom/agree', {
          studentId: mainStudentId,
          roomName,
          date,
          startTime: start,
          endTime: end,
        });
  
        if (response.status !== 200) {
          throw new Error(`Failed to approve reservation for ${start} to ${end}`);
        }
      }

      alert('모든 승인 처리가 완료되었습니다.');
      setIsModalOpen(false);
      // 성공적인 승인 후 목록에서 해당 예약 제거 또는 업데이트
      // 예: setPendingReservations(prev => prev.filter(item => item.id !== reservation.id));
    } catch (error) {
      console.error('승인 처리에 실패했습니다:', error);
      alert('승인 처리에 실패했습니다.');
    }
};

//승인 강의실 예약 데이터 삭제 관련 이벤트 핸들러 함수
const handleDeleteReservation = async (reservation) => {
  const { mainStudentId, roomName, date, startTime, endTime } = reservation;

  const startTimeHour = parseInt(startTime.split(":")[0]);
  const endTimeHour = parseInt(endTime.split(":")[0]);

  try {
    for (let hour = startTimeHour; hour < endTimeHour; hour++) {
      const start = `${hour}`;
      const end = `${hour + 1}`;

      const response = await axios.delete('http://localhost:3000/adminRoom/delete', {
        data: {
          studentId: mainStudentId,
          roomName,
          date,
          startTime: `${start}:00`, // "10:00" 형식
          endTime: `${end}:00` // "11:00" 형식
        }
      });

      if (response.status !== 200) {
        throw new Error(`Failed to delete reservation from ${start}:00 to ${end}:00`);
      }
    }

    alert('예약이 성공적으로 삭제되었습니다.');
    // 여기에서 상태 업데이트 로직 추가 (예약 목록에서 해당 예약 제거)
    setApprovedReservations(prevReservations => 
      prevReservations.filter(item => 
        !(item.roomName === roomName && item.date === date && item.startTime === startTime && item.endTime === endTime)
      )
    );
  } catch (error) {
    console.error('예약 삭제에 실패했습니다:', error);
    alert('예약 삭제에 실패했습니다.');
  }
};

  //승인 강의실 예약 데이터 관련 테이블 함수
  const ApprovedTable = ({ reservations, onDelete }) => {
    return (
      <table className="reservations-table">
        <thead>
          <tr>
            <th className='confirm_date'>날짜</th>
            <th className='confirm_name'>대표자 이름</th>
            <th className='confirm_id'>대표자 학번</th>
            <th className='confirm_room'>강의실 이름</th>
            <th className='confirm_time'>예약 시간</th>
            <th className='confirm_form'>신청서</th>
            <th className='confirm_delete'>삭제하기</th>
          </tr>
        </thead>
        <tbody>
          {reservations.map((reservation, index) => (
            <tr key={index}>
              <td>{reservation.date}</td>
              <td>{reservation.mainName}</td>
              <td>{reservation.mainStudentId}</td>
              <td>{reservation.roomName}</td>
              <td>{`${reservation.startTime}시 ~ ${reservation.endTime}시`}</td>
              <td>
              <button className="request-button" onClick={() => handleOpenModal(reservation, true)}>
                신청서 보기
              </button>
              </td>
              <td>
              <button className="delete-button" onClick={() => handleDeleteReservation(reservation)}>
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
            <th className='waiting_date'>날짜</th>
            <th className='waiting_name'>대표자 이름</th>
            <th className='waiting_id'>대표자 학번</th>
            <th className='waiting_room'>강의실 이름</th>
            <th className='waiting_time'>예약 시간</th>
            <th className='waiting_form'>신청서</th>
          </tr>
        </thead>
        <tbody>
          {reservations.map((reservation, index) => (
            <tr key={index}>
              <td>{reservation.date}</td>
              <td>{reservation.mainName}</td>
              <td>{reservation.mainStudentId}</td>
              <td>{reservation.roomName}</td>
              <td>{`${reservation.startTime}시 ~ ${reservation.endTime}시`}</td>
              <td>
                <button className="request-button" onClick={() => handleOpenModal(reservation)}>
                  신청서 보기
                </button>
              </td>
            </tr>
          ))}
        </tbody>
      </table>
    );
  };

const Modal = ({ reservation, onClose, onApprove }) => {
  let participants = [];
  try {
    participants = JSON.parse(reservation.participants);
  } catch (e) {
    console.error("참가자 정보 파싱 오류:", e);
    participants = [];
  }

  return (
    <div className="modal-backdrop">
      <div className="modal-content">
        <span className="close-button" onClick={onClose}>&times;</span>
        <div className='popup_form'>
          <h2>{reservation.mainFaculty} 강의실 신청서</h2>
        </div>
        <div>
        <div className="form_form">
      <div className="form-container">
        <div className="form-row">
          <div className="form-cell header">구분</div>
          <div className="form-cell">{reservation.roomName}</div>
        </div>
        <div className="form-row">
          <div className="form-cell header">사용일시</div>
          <div className="form-cell" colSpan="2">{reservation.date} {reservation.startTime}시 ~ {reservation.endTime}시</div>
        </div>
        <div className="form-row">
          <div className="form-cell header">사용목적</div>
          <div className="form-cell" colSpan="2">{reservation.usingPurpose}</div>
        </div>
        <div className="form-row">
          <div className="form-cell header" rowSpan="5">대표자<br/>/<br/>책임자</div>
          <div className="form-sub-container" colSpan="2">
            <div className="form-sub-row">
              <div className="form-sub-cell sub-header">학번</div>
              <div className="form-sub-cell">{reservation.mainStudentId}</div>
            </div>
            <div className="form-sub-row">
              <div className="form-sub-cell sub-header">성명</div>
              <div className="form-sub-cell">{reservation.mainName}</div>
            </div>
            <div className="form-sub-row">
              <div className="form-sub-cell sub-header">연락처</div>
              <div className="form-sub-cell">{reservation.mainPhoneNumber}</div>
            </div>
            <div className="form-sub-row">
              <div className="form-sub-cell sub-header">E-Mail</div>
              <div className="form-sub-cell">{reservation.mainEmail}</div>
            </div>
            <div className="form-sub-row">
              <div className="form-sub-cell sub-header">서명</div>
              <div className="form-sub-cell">
              <img
                src={`data:image/png;base64,${reservation.signature}`}
                alt="Main Signature"
                className="signature-image"
              />
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
        </div>
          {participants.map((participant, index) => (
            <div key={index}>
              <div className="form_form_form">
              <div className="form-container">
              <div className="form-row">
          <div className="participantform-cell header" rowSpan="3"></div>
          <div className="participant-sub-container" colSpan="2">
            <div className="participant-sub-row">
              <div className="participant-sub-cell sub-header">학번</div>
              <div className="participant-sub-cell">{participant.studentId}</div>
            </div>
            <div className="participant-sub-row">
              <div className="participant-sub-cell sub-header">소속</div>
              <div className="participant-sub-cell">{participant.department}</div>
            </div>
            <div className="participant-sub-row">
              <div className="participant-sub-cell sub-header">성명</div>
              <div className="participant-sub-cell">{participant.name}</div>
            </div>
            <div className="participant-sub-row">
              <div className="participant-sub-cell sub-header">서명</div>
              <div className="participant-sub-cell">
              <img
                    src={`data:image/png;base64,${participant.p_signature}`}
                    alt="Participant Signature"
                    className="signature-image"
                  />
              </div>
            </div>
          </div>
        </div>
        </div>
        </div>
            </div>
          ))}
          {showApproveButton && (
            <button className='confirm_button' onClick={() => onApprove(reservation)}>승인하기</button>
          )}
        </div>
      </div>
  );
};

const ReservationModal = ({ isOpen, onClose, onSubmit }) => {
  const [formData, setFormData] = useState({
    roomName: '',
    date: '',
    startTime: '',
    endTime: '',
    usingPurpose: ''
  });

  if (!isOpen) return null;

  const handleChange = (e) => {
    const { name, value } = e.target;
    setFormData(prev => ({ ...prev, [name]: value }));
  };

  const handleSubmit = (e) => {
    e.preventDefault();
    onSubmit(formData);
    setFormData({ roomName: '', date: '', startTime: '', endTime: '', usingPurpose: '' }); // Reset form
  };

  return (
    <div className="modal-backdrop">
      <div className="modal-content">
        <span className="close-button" onClick={onClose}>&times;</span>
        <h2>강의실 예약 추가</h2>
        <hr />
        <form onSubmit={handleSubmit}>
          <div className="form-table">
            <div className="form-row">
              <div className="form-label">강의실 이름:</div>
              <input className="admin-reserve-input" type="text" name="roomName" value={formData.roomName} onChange={handleChange} />
            </div>
            <div className="form-row">
              <div className="form-label">날짜:</div>
              <input className="admin-reserve-input" type="date" name="date" value={formData.date} onChange={handleChange} />
            </div>
            <div className="form-row">
              <div className="form-label">시작 시간:</div>
              <input className="admin-reserve-input" type="text" name="startTime" placeholder="HH:MM" value={formData.startTime} onChange={handleChange} />
            </div>
            <div className="form-row">
              <div className="form-label">종료 시간:</div>
              <input className="admin-reserve-input" type="text" name="endTime" placeholder="HH:MM" value={formData.endTime} onChange={handleChange} />
            </div>
            <div className="form-row">
              <div className="form-label">사용 목적:</div>
              <input className="admin-reserve-input" type="text" name="usingPurpose" value={formData.usingPurpose} onChange={handleChange} />
            </div>
          </div>
          <button className="admin-reservation-button" type="submit">예약 추가</button>
        </form>
      </div>
    </div>
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
                  <p className='classRoom_title'>승인 강의실 예약내역</p>
                  <button className="add-reservation-button" onClick={handleOpenReservationModal}>+강의실 예약 추가하기</button>
                  <ReservationModal
                    isOpen={isReservationModalOpen}
                    onClose={handleCloseReservationModal}
                    onSubmit={handleAddReservation}
                  />
                </div>
                <div className='classRoom_table'>
                  <ApprovedTable reservations={approvedReservations} onDelete={handleDeleteReservation} />
                </div>
              </div>

              <div className='classRoom_box'>
                <div className='classRoom_box_inner'>
                  <p className='classRoom_title'>미승인 강의실 예약내역</p>
                </div>
                <div className='classRoom_table'>
                  <DynamicTable reservations={pendingReservations} />
                </div>
              </div>
            </div>
            {isModalOpen && <Modal reservation={currentReservation} onClose={handleCloseModal} onApprove={handleApproveReservation} />}
          </div>
        </div>
      </div>
    </div>
  );
}

export default Room;