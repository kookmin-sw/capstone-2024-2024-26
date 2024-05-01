import React, { useState, useEffect } from 'react';
import firebase from 'firebase/compat/app';
import 'firebase/compat/app';
import 'firebase/compat/firestore';
import Sidebar from './sideBar';
import Banner from './banner';
import Calendar from 'react-calendar';
import 'react-calendar/dist/Calendar.css';
import '../styles/reserve.css';

const Reserve = () => {
    const [date, setDate] = useState(new Date());
    const [reservations, setReservations] = useState([]);

    useEffect(() => {
        const fetchData = async () => {
            const db = firebase.firestore();
            const formattedDate = date.toISOString().split('T')[0]; // 날짜 포맷 "YYYY-MM-DD"
            const querySnapshot = await db.collection('reservationClub')
                .where('date', '==', formattedDate + " 00:00:00.000Z")
                .get();
            const fetchedReservations = querySnapshot.docs.map(doc => doc.data());
            setReservations(fetchedReservations);
        };
        fetchData();
    }, [date]);

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
                            onChange={setDate}
                            value={date}
                        />
                    </div>
                    <div className='calendar_show'>
                        <h2>예약 내역: {formatDate(date)}</h2>
                        <table>
                            <thead>
                                <tr>
                                    <th className='reserve-room'>예약공간</th>
                                    <th className='reserve-time'>예약시간</th>
                                    <th className='reserve-name'>이름</th>
                                    <th className='reserve-email'>이메일</th>
                                </tr>
                            </thead>
                            <tbody>
                                {reservations.map((reservation, index) => (
                                    <tr key={index}>
                                        <td>{reservation.roomId}</td>
                                        <td>{`${reservation.startTime} - ${reservation.endTime}`}</td>
                                        <td>{reservation.userName}</td>
                                        <td>{reservation.userEmail}</td>
                                    </tr>
                                ))}
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
        </div>
    );
};

export default Reserve;