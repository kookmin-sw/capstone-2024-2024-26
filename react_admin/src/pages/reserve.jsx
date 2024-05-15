import React, { useState } from 'react';
import axios from 'axios';
import Sidebar from './sideBar';
import Banner from './banner';
import Calendar from 'react-calendar';
import Modal from 'react-modal';
import 'react-calendar/dist/Calendar.css';
import '../styles/reserve.css';

const Reserve = () => {
    const [date, setDate] = useState(new Date());
    const [reservations, setReservations] = useState([]);
    const [modalIsOpen, setModalIsOpen] = useState(false);

    const fetchReservations = async (selectedDate) => {
        try {
            const faculty = localStorage.getItem('faculty');
            const formattedDate = selectedDate.toISOString().split('T')[0]; // 날짜 포맷 "YYYY-MM-DD"

            const [roomResponse, clubResponse] = await Promise.all([
                axios.get(`http://localhost:3000/adminRoom/reservations/${faculty}/${formattedDate}/${formattedDate}`),
                axios.get(`http://localhost:3000/adminClub/clubRoomInfo/${faculty}`)
            ]);

            const roomReservations = roomResponse.data.confirmReservations.map(reservation => ({
                type: '강의실',
                ...reservation
            }));

            const clubReservations = clubResponse.data.allClubRoomInfo.map(reservation => ({
                type: '공유공간',
                ...reservation
            }));

            setReservations([...roomReservations, ...clubReservations]);

        } catch (error) {
            console.error('Failed to fetch reservations:', error);
        }
    };

    const handleDateChange = (selectedDate) => {
        setDate(selectedDate);
        fetchReservations(selectedDate);
        setModalIsOpen(true);
    };

    const formatDate = (date) => {
        const days = ['일', '월', '화', '수', '목', '금', '토'];
        const dayOfWeek = days[date.getDay()];
        return `${date.getFullYear()}년 ${date.getMonth() + 1}월 ${date.getDate()}일 (${dayOfWeek})`;
    };

    return (
        <div className="main-container">
            <Banner />
            <div className="sidebar-and-content">
                <Sidebar />
                <div className="main-content">
                    <div className='calendar_box'>
                        <Calendar
                            onChange={handleDateChange}
                            value={date}
                        />
                    </div>
                </div>
            </div>
            <Modal
                isOpen={modalIsOpen}
                onRequestClose={() => setModalIsOpen(false)}
                contentLabel="Reservation Details"
                overlayClassName="react-modal-overlay"
                className="react-modal-content"
                ariaHideApp={false}
            >
                <h2>예약 내역: {formatDate(date)}</h2>
                <button className="react-modal-close" onClick={() => setModalIsOpen(false)}>닫기</button>
                <table>
                    <thead>
                        <tr>
                            <th className='reserve-type'>구분</th>
                            <th className='reserve-room'>예약공간</th>
                            <th className='reserve-time'>예약시간</th>
                            <th className='reserve-name'>이름</th>
                            <th className='reserve-email'>이메일</th>
                        </tr>
                    </thead>
                    <tbody>
                        {reservations.map((reservation, index) => (
                            <tr key={index}>
                                <td>{reservation.type}</td>
                                <td>{reservation.roomName}</td>
                                <td>{`${reservation.startTime} - ${reservation.endTime}`}</td>
                                <td>{reservation.mainName}</td>
                                <td>{reservation.mainEmail}</td>
                            </tr>
                        ))}
                    </tbody>
                </table>
            </Modal>
        </div>
    );
};

export default Reserve;