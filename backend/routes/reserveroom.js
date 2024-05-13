import {
  collection,
  getFirestore,
  getDoc,
  setDoc,
  doc,
  getDocs,
  where,
  query,
  deleteDoc,
  updateDoc,
} from "firebase/firestore";
import { initializeApp } from "firebase/app";
import express from "express";
import dotenv from "dotenv";
import fs from "fs";
dotenv.config();
const firebaseConfig = {
  apiKey: process.env.FLUTTER_APP_apikey,
  authDomain: process.env.FLUTTER_APP_authDomain,
  projectId: process.env.FLUTTER_APP_projectId,
  storageBucket: process.env.FLUTTER_APP_storageBucket,
  messagingSenderId: process.env.FLUTTER_APP_messagingSenderId,
  appId: process.env.FLUTTER_APP_appId,
  measurementId: process.env.FLUTTER_APP_measurementId,
};

const app = initializeApp(firebaseConfig);
const db = getFirestore(app);

const reserveroom = express.Router();

// 강의실 예약
reserveroom.post("/", async (req, res) => {
  const {
    userId,
    roomName,
    date,
    startTime,
    endTime,
    usingPurpose,
    studentId,
    participants,
    numberOfPeople,
    signature,
  } = req.body;
  try {
    // 사용자 정보 가져오기
    const userDoc = await getDoc(doc(db, "users", userId));

    if (!userDoc.exists()) {
      return res.status(404).json({ error: "User not found" });
    }
    const userData = userDoc.data();

    const collectionName = `${userData.faculty}_Classroom_queue`;

    const existDocSnapShot = await getDoc(doc(db, collectionName, roomName));

    if (!existDocSnapShot.exists()) {
      // 해당 문서가 존재하지 않는 경우
      return res.status(404).json({ error: "This Classroom does not exists" });
    }
    const facultyConferenceCollection = collection(db, collectionName);
    const conferenceRoomDoc = doc(facultyConferenceCollection, roomName);
    const conferenceRoomDocSnap = await getDoc(conferenceRoomDoc);

    // 해당 강의실이 있는지 확인
    if (!conferenceRoomDocSnap.exists()) {
      return res.status(404).json({
        error: `${roomName} does not exist in ${collectionName} collection`,
      });
    }
    const dateCollection = collection(conferenceRoomDoc, date);

    const startTimeParts = startTime.split(":");
    const startTimeHour = parseInt(startTimeParts[0]);

    const endTimeParts = endTime.split(":");
    const endTimeHour = parseInt(endTimeParts[0]);

    const timeDiff = endTimeHour - startTimeHour;

    if (timeDiff < 1) {
      return res.status(402).json({ error: "Unvaild startTime and endTime" });
    }

    for (let i = startTimeHour; i < endTimeHour; i++) {
      const reservationDocRef = doc(dateCollection, `${i}-${i + 1}`);
      const reservationDocSnap = await getDoc(reservationDocRef);

      if (reservationDocSnap.exists()) {
        return res.status(400).json({
          error: `This Conference ${roomName} room  is already reserved from ${i}-${
            i + 1
          }`,
        });
      }
    }

    for (let i = startTimeHour; i < endTimeHour; i++) {
      const reservationDocRef = doc(dateCollection, `${i}-${i + 1}`);
      const reservationDocSnap = await getDoc(reservationDocRef);
      if (!reservationDocSnap.exists()) {
        const participantArray = JSON.parse(participants);

        if (participantArray.length !== parseInt(numberOfPeople) - 1) {
          return res.status(401).json({
            error: "The number of people does not match number of students",
          });
        } else {
          await setDoc(reservationDocRef, {
            roomName: roomName,
            date: date,
            startTime: startTime,
            endTime: endTime,
            mainName: userData.name, // 누가 대표로 예약을 했는지(책임 문제)
            mainFaculty: userData.faculty, // 대표자 소속
            mainStudentId: studentId, // 대표자 학번
            mainPhoneNumber: userData.phone, // 대표자 전화번호
            mainEmail: userData.email, // 대표자 이메일
            participants: participants,
            numberOfPeople: numberOfPeople,
            usingPurpose: usingPurpose,
            boolAgree: false,
            signature: signature,
          });
        }
      }
    }

    // 예약 성공 시 응답
    res
      .status(201)
      .json({ message: "Reservation Conference created successfully" });
  } catch (error) {
    // 오류 발생 시 오류 응답
    console.error("Error reserve conference room", error);
    res.status(500).json({ error: "Failed to reserve conference room" });
  }
});

// 사용자별 특정 시작 날짜부터 특정 끝 날짜까지의 강의실 예약 내역 조회
reserveroom.get(
  "/reservationrooms/:userId/:startDate/:endDate",
  async (req, res) => {
    const userId = req.params.userId;
    const startDate = new Date(req.params.startDate);
    const endDate = new Date(req.params.endDate);

    try {
      // 사용자 정보 가져오기
      const userDoc = await getDoc(doc(db, "users", userId));

      if (!userDoc.exists()) {
        return res.status(404).json({ error: "User not found" });
      }
      const userData = userDoc.data();

      // 컬렉션 이름 설정
      const collectionName = `${userData.faculty}_Classroom_queue`;

      // 사용자 예약 내역(승인 전)
      const userReservations = [];

      // 강의실 컬렉션 참조
      const facultyConferenceCollectionRef = collection(db, collectionName);

      const querySnapshot = await getDocs(facultyConferenceCollectionRef);

      // 비동기 처리를 위해 Promise.all 사용
      await Promise.all(
        querySnapshot.docs.map(async (roomDoc) => {
          const roomName = roomDoc.id;
          for (
            let currentDate = new Date(startDate);
            currentDate <= new Date(endDate);
            currentDate.setDate(currentDate.getDate() + 1)
          ) {
            const dateString = currentDate.toISOString().split("T")[0]; // yyyy-mm-dd 형식의 문자열로 변환
            const dateCollectionRef = collection(
              db,
              `${collectionName}/${roomName}/${dateString}`
            ); // 컬렉션 참조 생성

            // 해당 날짜별 시간 대 예약 내역 조회
            const timeDocSnapshot = await getDocs(dateCollectionRef);

            timeDocSnapshot.forEach((docSnapshot) => {
              const reservationData = docSnapshot.data();
              if (reservationData) {
                const startTime = docSnapshot.id.split("-")[0];
                const endTime = docSnapshot.id.split("-")[1];
                if (reservationData.mainStudentId == userData.studentId) {
                  // 예약된 문서 정보 조회
                  userReservations.push({
                    roomName: reservationData.roomName,
                    date: reservationData.date,
                    startTime: startTime,
                    endTime: endTime,
                    mainName: reservationData.mainName, // 누가 대표로 예약을 했는지(책임 문제)
                    mainFaculty: reservationData.mainFaculty, // 대표자 소속
                    mainStudentId: reservationData.mainStudentId, // 대표자 학번
                    mainPhoneNumber: reservationData.mainPhoneNumber, // 대표자 전화번호
                    mainEmail: reservationData.mainEmail, // 대표자 이메일
                    participants: reservationData.participants,
                    usingPurpose: reservationData.usingPurpose,
                    boolAgree: false,
                    signature: reservationData.signature,
                    statusMessage: "관리자 승인 전 강의실 예약 내역"
                  });
                }
              }
            });
          }
        })
      );

      // 사용자 예약 내역 반환
      res.status(200).json({
        message: "User reservations fetched successfully",
        notConfirmReservations: userReservations,
      });
    } catch (error) {
      // 오류 발생 시 오류 응답
      console.error("Error fetching user reservations", error);
      res.status(500).json({ error: "Failed to fetch user reservations" });
    }
  }
);

// 강의실 예약 내역 삭제
reserveroom.delete("/delete", async (req, res) => {
  const { userId, roomName, date, startTime, endTime } = req.body;

  try {
    // 사용자 정보 가져오기
    const userDoc = await getDoc(doc(db, "users", userId));

    if (!userDoc.exists()) {
      return res.status(404).json({ error: "User not found" });
    }
    const userData = userDoc.data();

    const collectionName = `${userData.faculty}_Classroom_queue`;

    const conferenceRoomCollection = collection(db, collectionName);
    const roomDocRef = doc(conferenceRoomCollection, roomName);

    const dateCollection = collection(roomDocRef, date);

    // 예약 시간대 확인
    const startTimeParts = startTime.split(":");
    const startTimeHour = parseInt(startTimeParts[0]);

    const endTimeParts = endTime.split(":");
    const endTimeHour = parseInt(endTimeParts[0]);

    // 예약 내역 삭제
    for (let i = startTimeHour; i < endTimeHour; i++) {
      const reservationDocRef = doc(dateCollection, `${i}-${i + 1}`);
      await deleteDoc(reservationDocRef);
    }

    // 삭제 성공 시 응답
    res.status(200).json({ message: "Reservation deleted successfully" });
  } catch (error) {
    // 오류 발생 시 오류 응답
    console.error("Error deleting reservation", error);
    res.status(500).json({ error: "Failed to delete reservation" });
  }
});

// 이용 예정 내역
reserveroom.get("/future/reservations/:userId", async (req, res) => {
  const userId = req.params.userId;

  try {
    // 사용자 정보 가져오기
    const userDoc = await getDoc(doc(db, "users", userId));

    if (!userDoc.exists()) {
      return res.status(404).json({ error: "User not found" });
    }
    const userData = userDoc.data();

    // 컬렉션 이름 설정
    const collectionName = `${userData.faculty}_Classroom_queue`;

    // 사용자 예약 내역
    const userReservations = [];

    // 동아리방 컬렉션 참조
    const facultyClubCollectionRef = collection(db, collectionName);

    const querySnapshot = await getDocs(facultyClubCollectionRef);

    // 비동기 처리를 위해 Promise.all 사용
    await Promise.all(
      querySnapshot.docs.map(async (roomDoc) => {
        const roomName = roomDoc.id;
        const offset = 1000 * 60 * 60 * 9;
        const koreaNow = new Date(new Date().getTime() + offset);

        let endDate = new Date();
        endDate.setDate(koreaNow.getDate() + 14);

        const currentDate = koreaNow.toISOString().split("T")[0];
        for (; koreaNow <= endDate; koreaNow.setDate(koreaNow.getDate() + 1)) {
          const dateString = koreaNow.toISOString().split("T")[0]; // yyyy-mm-dd 형식의 문자열로 변환
          // console.log(typeof(currentDate), typeof(dateString));
          if (currentDate === dateString) {
            const dateCollectionRef = collection(
              db,
              `${collectionName}/${roomName}/${dateString}`
            ); // 컬렉션 참조 생성

            // 해당 날짜별 시간 대 예약 내역 조회
            const timeDocSnapshot = await getDocs(dateCollectionRef);

            timeDocSnapshot.forEach((docSnapshot) => {
              const reservationData = docSnapshot.data();
              if (reservationData) {
                const startTime = docSnapshot.id.split("-")[0];
                const endTime = docSnapshot.id.split("-")[1];
                const timeString = koreaNow.toISOString().split("T")[1].substring(0,2); 
                if (parseInt(startTime) > parseInt(timeString)) {
                  // 예약된 테이블 정보 조회{
                  userReservations.push({
                    roomName: reservationData.roomName,
                    date: reservationData.date,
                    startTime: startTime,
                    endTime: endTime,
                    mainName: reservationData.mainName, // 누가 대표로 예약을 했는지(책임 문제)
                    mainFaculty: reservationData.mainFaculty, // 대표자 소속
                    mainStudentId: reservationData.mainStudentId, // 대표자 학번
                    mainPhoneNumber: reservationData.mainPhoneNumber, // 대표자 전화번호
                    mainEmail: reservationData.mainEmail, // 대표자 이메일
                    participants: reservationData.participants,
                    usingPurpose: reservationData.usingPurpose,
                    boolAgree: false,
                    signature: reservationData.signature,
                    statusMessage: "관리자 승인 전 강의실 예약 내역"
                  });
                }
              }
            });
          } else {
            const dateCollectionRef = collection(
              db,
              `${collectionName}/${roomName}/${dateString}`
            ); // 컬렉션 참조 생성

            // 해당 날짜별 시간 대 예약 내역 조회
            const timeDocSnapshot = await getDocs(dateCollectionRef);

            timeDocSnapshot.forEach((docSnapshot) => {
              const reservationData = docSnapshot.data();
              if (reservationData && reservationData.tableData) {
                const startTime = docSnapshot.id.split("-")[0];
                const endTime = docSnapshot.id.split("-")[1];

                // 예약된 정보 조회
                userReservations.push({
                  roomName: reservationData.roomName,
                  startTime: startTime,
                  endTime: endTime,
                  mainName: reservationData.mainName, // 누가 대표로 예약을 했는지(책임 문제)
                  mainFaculty: reservationData.faculty, // 대표자 소속
                  mainStudentId: reservationData.mainStudentId, // 대표자 학번
                  mainPhoneNumber: reservationData.mainPhoneNumber, // 대표자 전화번호
                  mainEmail: reservationData.mainEmail, // 대표자 이메일
                  participants: reservationData.participants,
                  usingPurpose: reservationData.usingPurpose,
                  boolAgree: false,
                  signature: reservationData.signature,
                });
              }
            });
          }
        }
      })
    );

    // 사용자 예약 내역 반환
    res.status(200).json({
      message: "User future reservations fetched successfully",
      notConfirmReservations: userReservations,
    });
  } catch (error) {
    // 오류 발생 시 오류 응답
    console.error("Error fetching user future reservations", error);
    res.status(500).json({ error: "Failed to fetch user future reservations" });
  }
});

export default reserveroom;
