import React, { useState, useEffect } from 'react';
import Sidebar from './sideBar';
import Banner from './banner';
import '../styles/notification.css';

const Notification = () => {
  const [notices, setNotices] = useState([]);
  const [showModal, setShowModal] = useState(false);
  const [noticeCategory, setNoticeCategory] = useState('');
  const [noticeContent, setNoticeContent] = useState('');

  useEffect(() => {
    const savedNotices = localStorage.getItem('notices');
    if (savedNotices) {
      setNotices(JSON.parse(savedNotices));
    }
  }, []);

  const saveNoticesToLocalStorage = (notices) => {
    localStorage.setItem('notices', JSON.stringify(notices));
  };

  const handleAddNotice = () => {
    const newNotice = {
      date: new Date().toLocaleDateString(),
      category: noticeCategory,
      content: noticeContent
    };
    const updatedNotices = [...notices, newNotice];
    setNotices(updatedNotices);
    saveNoticesToLocalStorage(updatedNotices);
    setShowModal(false);
    setNoticeCategory('');
    setNoticeContent('');
  };

  const handleDeleteNotice = (index) => {
    const updatedNotices = notices.filter((_, i) => i !== index);
    setNotices(updatedNotices);
    saveNoticesToLocalStorage(updatedNotices);
  };


  return (
    <div className="main-container">
      <Banner />
      <div className="sidebar-and-content">
        <Sidebar />
        <div className="main-content">
          <div className='notice_container'>
            <div className='notice_box'>
              <div className='notice_box_button'>
                <p className='notice_title'>공지사항</p> 
                <button className='notice_add_button' onClick={() => setShowModal(true)}>+</button>
              </div>
              <hr />
              <div className='notice_table_scroll'>
              <table className="notice_table">
                <thead>
                  <tr>
                    <th className='table_date'>등록날짜</th>
                    <th className='table_category'>공지분류</th>
                    <th className='table_content'>공지내용</th>
                    <th className='table_delete'>공지 관리</th>
                  </tr>
                </thead>
                <tbody>
                  {notices.map((notice, index) => (
                    <tr key={index}>
                      <td>{notice.date}</td>
                      <td>{notice.category}</td>
                      <td className='notice-content-cell'>{notice.content}</td>
                      <td><button className='notice_delete_button' onClick={() => handleDeleteNotice(index)}>삭제</button></td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
            </div>
          </div>
        </div>
      </div>
      {showModal && (
        <div className="modal-backdrop">
          <div className="modal-content">
            <span className="close-button" onClick={() => setShowModal(false)}>&times;</span>
            <h2 className="modal-title">공지사항 등록하기</h2>
            <div className="modal-body">
              <div className="modal-row">
                <label className="modal-label">공지 분류:</label>
                <select
                  className="modal-input"
                  value={noticeCategory}
                  onChange={e => setNoticeCategory(e.target.value)}
                >
                  <option value="">선택하세요</option>
                  <option value="일반">일반</option>
                  <option value="긴급">긴급</option>
                  <option value="긴급">강의실</option>
                  <option value="긴급">세미나</option>
                </select>
              </div>
              <div className="modal-row">
                <label className="modal-label">공지 내용:</label>
                <textarea
                  className="modal-textarea"
                  value={noticeContent}
                  onChange={e => setNoticeContent(e.target.value)}
                />
              </div>
            </div>
            <button className="modal-send-button" onClick={handleAddNotice}>등록하기</button>
          </div>
        </div>
      )}
    </div>
  );
}

export default Notification;