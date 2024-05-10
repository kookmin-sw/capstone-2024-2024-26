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
    usingPurpose, // 소속, 학번, 성명, 연락처, 이메일
    studentIds, // studentIds 리스트 형태로!
    signImagesEncode, // 서명이미지 인코딩된 값 리스트 형태로!
    numberOfPeople,
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
        if (studentIds.length !== parseInt(numberOfPeople)) {
          return res.status(401).json({
            error: "The number of people does not match number of students",
          });
        } else {
          // 각 학생의 이름과 전공을 저장할 배열
          const studentNames = [];
          const studentDepartments = [];
          for (const studentId of studentIds) {
            const collectionRef = collection(db, "users");
            const userDoc = query(
              collectionRef,
              where("studentId", "==", studentId)
            );

            const userDocSnapshot = await getDocs(userDoc);
            if (!userDocSnapshot.empty) {
              const userData = userDocSnapshot.docs[0].data();
              const studentName = userData.name;
              const studentDepartment = userData.department;

              // 배열에 학생의 이름과 전공 추가
              studentNames.push(studentName);
              studentDepartments.push(studentDepartment);
            }
          }

          await setDoc(reservationDocRef, {
            mainName: userData.name, // 누가 대표로 예약을 했는지(책임 문제)
            studentName: studentNames,
            studentId: studentIds,
            studentDepartment: studentDepartments,
            usingPurpose: usingPurpose,
            boolAgree: false,
            signImagesEncode: signImagesEncode,
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

// 해당 날짜에 모든 예약 내역 조회
reserveroom.get("/reservationrooms/:userId/:date", async (req, res) => {
  const userId = req.params.userId;
  const date = req.params.date;

  try {
    // 사용자 정보 가져오기
    const userDoc = await getDoc(doc(db, "users", userId));

    if (!userDoc.exists()) {
      return res.status(404).json({ error: "User not found" });
    }
    const userData = userDoc.data();

    // 컬렉션 이름 설정
    const collectionName = `${userData.faculty}_Classroom`;

    // 해당 날짜의 모든 예약 내역 가져오기
    const reservationsSnapshot = await getDocs(
      query(collection(db, `${collectionName}`), where("date", "==", date))
    );

    // 예약이 없는 경우
    if (reservationsSnapshot.empty) {
      return res
        .status(404)
        .json({ message: "No reservations found for this date" });
    }

    // 예약 내역 반환
    const reservations = [];
    reservationsSnapshot.forEach((doc) => {
      const reservation = doc.data();
      reservations.push({
        id: doc.id, // 예약 문서 ID
        userId: reservation.userId,
        userName: reservation.userName,
        roomId: reservation.roomId,
        date: reservation.date,
        startTime: reservation.startTime,
        endTime: reservation.endTime,
        numberOfPeople: reservation.numberOfPeople,
      });
    });

    // 해당 날짜의 모든 예약 내역 반환
    res.status(200).json({
      message: "Reservations for the date fetched successfully",
      reservations,
    });
  } catch (error) {
    // 오류 발생 시 오류 응답
    console.error("Error fetching reservations for the date", error);
    res
      .status(500)
      .json({ error: "Failed to fetch reservations for the date" });
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

      // 사용자 예약 내역
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

                // 예약된 문서 정보 조회
                  userReservations.push({
                    roomName: roomName,
                    mainName: userData.name,
                    date: dateString,
                    startTime: startTime,
                    endTime: endTime,
                    studentName: reservationData.studentNames,
                    studentDepartment: reservationData.studentDepartments,
                    studentId: reservationData.studentIds,
                    usingPurpose: reservationData.usingPurpose,
                    boolAgree: reservationData.boolAgree
                  });
              }
            });
          }
        })
      );

      // 사용자 예약 내역 반환
      res.status(200).json({
        message: "User reservations fetched successfully",
        reservations: userReservations,
      });
    } catch (error) {
      // 오류 발생 시 오류 응답
      console.error("Error fetching user reservations", error);
      res.status(500).json({ error: "Failed to fetch user reservations" });
    }
  }
);


export default reserveroom;
