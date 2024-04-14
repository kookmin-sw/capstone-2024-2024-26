import React, { useState } from 'react';
import { collection, query, where, doc, getDocs,deleteDoc } from 'firebase/firestore';
import Sidebar from './sideBar';
import Banner from './banner';
import firebase from 'firebase/compat/app';
import 'firebase/compat/app';
import 'firebase/compat/firestore';
import '../styles/reserve.css';
import DatePick from './datePick.jsx'; 

const Reserve = () => {
    const [reservations, setReservations] = useState([]);
    const [selectedDates, setSelectedDates] = useState(null);
    
    const handleDelete = async (index) => {
        try {
            const reservationToDelete = reservations[index];
            const db = firebase.firestore();
            const reservationsRef = collection(db, 'reservationClub');
            const reservationDocRef = doc(reservationsRef, reservationToDelete.id);
            
            await deleteDoc(reservationDocRef);
            
            const newReservations = [...reservations];
            newReservations.splice(index, 1);
            setReservations(newReservations);
            
            console.log('Reservation deleted successfully');
        } catch (error) {
            console.error('Error deleting reservation:', error);
        }
    };

    const handleEdit = (index) => {
        // 수정 기능 구현
        // 수정할 데이터를 입력할 수 있는 모달이나 폼을 띄워주는 등의 로직을 추가해야 합니다.
    };

    const fetchDataFromFirebase = async () => {
        try {
            if (!selectedDates || selectedDates.length !== 2) {
                console.error('Please select both start and end dates.');
                return;
            }

            const [startDate, endDate] = selectedDates;
            const db = firebase.firestore();
            const reservationsRef = collection(db, 'reservationClub');
            
            const q = query(reservationsRef, 
                where('date', '>=', startDate),
                where('date', '<=', endDate)
            );

            const querySnapshot = await getDocs(q);

            const reservationData = [];
            querySnapshot.forEach((doc) => {
                const data = doc.data();
                reservationData.push(data);
            });

            console.log("Fetched data:", reservationData);

            setReservations(reservationData);
        } catch (error) {
            console.error('Error fetching data:', error);
        }
    };

    return (
        <div className="main-container">
          <Banner />
          <div className="sidebar-and-content">
            <Sidebar />
            <div className="main-content">
                <div className='reserve_container'>
                    <div className='reserve_title'>
                        <h1>예약 관리</h1>
                        <div className='reserve_button_club'>공유 공간</div>
                        <div className='reserve_button_room'>강의실</div>
                    </div>
                    <div className='reserve_content'>
                        <div className='reserve_club'>
                            <div className='reserve_club_title'>공유공간 예약 현황</div>
                            <div className='reserve_club_content'>
                                <div className='club_dateSelector'>
                                    <DatePick onChange={setSelectedDates} />
                                    <button className='date_button' onClick={fetchDataFromFirebase}>검색</button>
                                </div>
                                <div className='club_reserve_data'>
                                {reservations.map((reservation, index) => (
                                <div key={index} className='reservation-item'>
                                    <p className='reserve_firestore_data'>
                                        {reservation.date} {reservation.userName} {reservation.startTime} ~ {reservation.endTime} {reservation.roomId}
                                    </p>
                                    <div className='action-buttons'>
                                        <button onClick={() => handleDelete(index)}>삭제</button>
                                        <button onClick={() => handleEdit(index)}>수정</button>
                                    </div>
                                    <hr />
                                </div>
                                    ))}
                                </div>
                            </div>
                        </div>
                    </div>
                </div> 
            </div>
          </div>
        </div>
    );
}

export default Reserve;