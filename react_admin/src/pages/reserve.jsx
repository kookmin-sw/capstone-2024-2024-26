import React, { useState, useMemo } from 'react';
import { collection, query, where, doc, getDocs, deleteDoc } from 'firebase/firestore';
import Sidebar from './sideBar';
import Banner from './banner';
import firebase from 'firebase/compat/app';
import 'firebase/compat/app';
import 'firebase/compat/firestore';
import '../styles/reserve.css';
import DatePick from './datePick.jsx';
import { useTable, useBlockLayout } from 'react-table';

const Reserve = () => {
    const [reservations, setReservations] = useState([]);
    const [selectedDates, setSelectedDates] = useState(null);
    const [showClub, setShowClub] = useState(true); // Default to showing '공유 공간' section

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
        if (!selectedDates || selectedDates.length !== 2) {
            console.error('Please select both start and end dates.');
            return;
        }

        const [startDate, endDate] = selectedDates;
        const db = firebase.firestore();
        const reservationsRef = collection(db, 'reservationClub');

        const q = query(reservationsRef, where('date', '>=', startDate), where('date', '<=', endDate));

        const querySnapshot = await getDocs(q);

        const reservationData = [];
        querySnapshot.forEach((doc) => {
            const data = doc.data();
            reservationData.push(data);
        });

        setReservations(reservationData);
    };

    const columns = useMemo(() => [
        { Header: '날짜', accessor: 'date'},
        { Header: '이름', accessor: 'userName' },
        { Header: '동아리', accessor: 'userClub' },
        { Header: '강의실 ID', accessor: 'roomId' },
        { Header: '테이블 번호', accessor: 'tableNumber' },
        { Header: '시작 시간', accessor: 'startTime' },
        { Header: '종료 시간', accessor: 'endTime' },
        {
            Header: '작업',
            Cell: ({ row }) => (
                <div className='action-buttons'>
                    <button className='reserve_edit_button' onClick={() => handleEdit(row.index)}>수정</button>
                    <button className='reserve_delete_button' onClick={() => handleDelete(row.index)}>삭제</button>
                </div>
            )
        }
    ], []);

    const tableInstance = useTable({ columns, data: reservations }, useBlockLayout);
    const { getTableProps, getTableBodyProps, headerGroups, rows, prepareRow } = tableInstance;

    return (
        <div className="main-container">
            <Banner />
            <div className="sidebar-and-content">
                <Sidebar />
                <div className="main-content">
                    <div className='reserve_container'>
                        <div className='reserve_title'>
                            <h1>예약 관리</h1>
                            <div className='reserve_buttons'>
                                <button className={showClub ? 'active' : ''} onClick={() => setShowClub(true)}>공유 공간</button>
                                <button className={!showClub ? 'active' : ''} onClick={() => setShowClub(false)}>강의실</button>
                            </div>
                        </div>
                        <div className='reserve_content'>
                            {showClub ? (
                                <div className='reserve_club'>
                                    <div className='reserve_club_title'>공유공간 예약 현황</div>
                                    <div className='reserve_club_content'>
                                        <div className='club_dateSelector'>
                                            <DatePick onChange={setSelectedDates} />
                                            <button className='date_button' onClick={fetchDataFromFirebase}>검색</button>
                                        </div>
                                        <div className='club_reserve_data'>
                                            <table {...getTableProps()} className="table">
                                                <thead>
                                                    {headerGroups.map(headerGroup => (
                                                        <tr {...headerGroup.getHeaderGroupProps()}>
                                                            {headerGroup.headers.map(column => (
                                                                <th {...column.getHeaderProps()} style={{ padding: '0px 36.2px',backgroundColor: 'rgb(179, 177, 177)'}}>{column.render('Header')}</th>
                                                            ))}
                                                        </tr>
                                                    ))}
                                                </thead>
                                                <tbody {...getTableBodyProps()}>
                                                    {rows.map(row => {
                                                        prepareRow(row);
                                                        return (
                                                            <tr {...row.getRowProps()}>
                                                                {row.cells.map(cell => {
                                                                    return <td {...cell.getCellProps()} 
                                                                    style={{ 

                                                                        textAlign: 'center', 
                                                                        padding: '8px 36.2px', 
                                                                        backgroundColor: 'rgb(211, 211, 211)',
                                                                    
                                                                    }}>{cell.render('Cell')}</td>;
                                                                })}
                                                            </tr>
                                                        );
                                                    })}
                                                </tbody>
                                            </table>
                                        </div>
                                    </div>
                                </div>
                            ) : (
                                <div className='reserve_club'>
                                    <div className='reserve_club_title'>강의실 예약 현황</div>
                                        <div className='reserve_club_content'>
                                            <div className='club_dateSelector'>
                                                <DatePick onChange={setSelectedDates} />
                                                <button className='date_button' onClick={fetchDataFromFirebase}>검색</button>
                                            </div>
                                            <div className='club_reserve_data'>
                                            </div>
                                        </div>
                                </div>
                            )}
                        </div>
                    </div>
                </div>
            </div>
        </div>
    );
};

export default Reserve;