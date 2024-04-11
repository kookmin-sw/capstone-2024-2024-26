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
    roomId,
    date,
    startTime,
    endTime,
    usingPurpose,
    studentIds,
    numberOfPeople,
  } = req.body;

  try {
    // 사용자 정보 가져오기
    const userDoc = await getDoc(doc(db, "users", userId));
    if (!userDoc.exists()) {
      return res.status(404).json({ error: "User not found" });
    }
    const userData = userDoc.data();

    // 예약된 시간대와 강의실 정보 확인
    const existingroomReservationSnapshot = await getDocs(
      collection(db, "reservationRoom"),
      where("date", "==", date),
      where("roomId", "==", roomId)
    );

    // 겹치는 예약이 있는지 확인
    const overlappingReservation = existingroomReservationSnapshot.docs.find(
      (doc) => {
        const reservation = doc.data();

        // 기존 예약의 시작 시간과 끝 시간
        const existingStartTime = reservation.startTime;
        const existingEndTime = reservation.endTime;
        const existingDate = reservation.date;
        const existingRoomId = reservation.roomId;
        const startTimeRoom = startTime;
        const endTimeRoom = endTime;

        // 예약 시간이 같은 경우 또는 기존 예약과 겹치는 경우 확인
        if (
          (existingDate == date &&
            startTimeRoom == existingStartTime &&
            endTimeRoom == existingEndTime &&
            roomId == existingRoomId) ||
          (existingDate == date &&
            roomId == existingRoomId &&
            startTimeRoom < existingEndTime &&
            endTimeRoom > existingStartTime)
        ) {
          return true;
        }
        return false;
      }
    );

    // 겹치는 예약이 있는 경우 에러 반환
    if (overlappingReservation) {
      return res
        .status(401)
        .json({ error: "The room is already reserved for this time" });
    }

    // 학생들의 학번을 공백을 기준으로 분할하여 리스트를 만듦
    const studentIdList = studentIds.split(" ");
    if (studentIdList.length != numberOfPeople) {
      return res.status(400).json({
        error:
          "The numberOfPeople does not match the number of given studentIds",
      });
    }

    // 각 학생의 정보를 가져오는 비동기 함수
    const getUserInfoPromises = studentIdList.map(async (studentId) => {
      const userQuerySnapshot = await getDocs(
        query(collection(db, "users"), where("studentId", "==", studentId))
      );
      if (!userQuerySnapshot.empty) {
        const userData = userQuerySnapshot.docs[0].data();
        return {
          studentId: studentId,
          name: userData.name,
          faculty: userData.faculty,
        };
      } else {
        throw new Error(`User with ID ${studentId} not found`);
      }
    });

    // 비동기 함수들을 병렬로 실행하여 학생 정보를 가져옵니다.
    const studentInfoList = await Promise.all(getUserInfoPromises);

    // 전에 사용자가 한 예약이 있는지 확인
    const existingMyReservationSnapshot = await getDocs(
      collection(db, "reservationRoom"),
      where("userEmail", "==", userData.email)
    );

    // 문서 컬렉션에 uid로 구분해주기(덮어쓰이지않게 문서 개수에 따라 번호 부여)
    const reservationCount = existingMyReservationSnapshot.size;
    // 겹치는 예약이 없으면 예약 추가
    await setDoc(doc(db, "reservationRoom", `${userId}_${reservationCount}`), {
      mainName: userData.name,
      roomId: roomId,
      date: date,
      startTime: startTime,
      endTime: endTime,
      usingPurpose: usingPurpose,
      numberOfPeople: numberOfPeople,
      studentIds: studentIdList,
      studentNames: studentInfoList.map((student) => student.name),
      studentFaculty: studentInfoList.map((student) => student.faculty),
    });

    // 예약 성공 시 응답
    res.status(201).json({ message: "Reservation room created successfully" });
  } catch (error) {
    // 오류 발생 시 오류 응답
    console.error("Error creating reservation room", error);
    res.status(500).json({ error: "Failed reservation room" });
  }
});

reserveroom.get("/reservationrooms/:date", async (req, res) => {
  const date = req.params.date;

  try {
    // 해당 날짜의 모든 예약 내역 가져오기
    const reservationsSnapshot = await getDocs(
      collection(db, "reservationRoom"),
      where("date", "==", date)
    );

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

export default reserveroom;
