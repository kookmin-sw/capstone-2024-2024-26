import {
  addDoc,
  collection,
  getFirestore,
  getDoc,
  doc,
  getDocs,
  where,
} from "firebase/firestore";
import { initializeApp } from "firebase/app";
import express from "express";

const firebaseConfig = {
  apiKey: "AIzaSyAocxBUBdG8MuMl7Z7owoX6S6PXax8vYZQ",
  authDomain: "capstone-c2358.firebaseapp.com",
  projectId: "capstone-c2358",
  storageBucket: "capstone-c2358.appspot.com",
  messagingSenderId: "452182758120",
  appId: "1:452182758120:web:30f72007059d6fdf4c6f5d",
  measurementId: "G-ST9TF7PNY3",
};

const app = initializeApp(firebaseConfig);
const db = getFirestore(app);

const reserveClub = express.Router();

// 동아리방 예약
reserveClub.post("/", async (req, res) => {
  const {
    userId,
    roomId,
    date,
    startTime,
    endTime,
    numberOfPeople,
    tableNumber,
  } = req.body;

  try {
    // 사용자 정보 가져오기
    const userDoc = await getDoc(doc(db, "users", userId));
    if (!userDoc.exists()) {
      return res.status(404).json({ error: "User not found" });
    }
    const userData = userDoc.data();

    // 예약된 시간대와 좌석 확인
    const existingReservationsSnapshot = await getDocs(
      collection(db, "reservationClub"),
      where("date", "==", date),
      where("roomId", "==", roomId),
      where("tableNumber", "==", tableNumber),
      where("startTime", "==", startTime),
      where("endTime", "==", endTime)
    );

    // 이미 해당 예약이 존재하는 경우
    if (!existingReservationsSnapshot.empty) {
      return res
        .status(400)
        .json({ error: "The same reservation already exists" });
    }

    // 겹치는 예약이 있는지 확인
    const isOverlapping = existingReservationsSnapshot.docs.some((doc) => {
      const reservation = doc.data();

      // 기존 예약의 시작 시간과 끝 시간
      const existingStartTime = new Date(reservation.startTime);
      const existingEndTime = new Date(reservation.endTime);

      // 새 예약의 시작 시간이 기존 예약의 끝 시간보다 이전이고, 새 예약의 끝 시간이 기존 예약의 시작 시간보다 이후일 경우 겹침
      if (newStartTime < existingEndTime && newEndTime > existingStartTime) {
        return true;
      }

      return false;
    });

    // 겹치는 예약이 있는지 확인
    if (isOverlapping) {
      return res
        .status(400)
        .json({ error: "The room is already reserved for this time" });
    }

    // 겹치는 예약이 없으면 예약 추가
    await addDoc(collection(db, "reservationClub"), {
      userId: userId,
      userName: userData.name,
      userClub: userData.club,
      roomId: roomId,
      date: date,
      startTime: startTime,
      endTime: endTime,
      numberOfPeople: numberOfPeople,
      tableNumber: tableNumber,
    });

    // 예약 성공 시 응답
    res.status(201).json({ message: "Reservation club created successfully" });
  } catch (error) {
    // 오류 발생 시 오류 응답
    console.error("Error creating reservation club", error);
    res.status(500).json({ error: "Failed reservation club" });
  }
});

// 사용자별 동아리 예약 내역 조회
reserveClub.get("/reservationclubs/:userId", async (req, res) => {
  const userId = req.params.userId;

  try {
    // 사용자의 모든 예약 내역 가져오기
    const userReservationsSnapshot = await getDocs(
      collection(db, "reservationClub"),
      where("userId", "==", userId)
    );

    if (userReservationsSnapshot.empty) {
      return res.status(404).json({ message: "No reservations found" });
    }

    // 예약 내역 반환
    const userReservations = [];
    userReservationsSnapshot.forEach((doc) => {
      const reservation = doc.data();
      userReservations.push({
        id: doc.id, // 예약 문서 ID
        roomId: reservation.roomId,
        numberOfPeople: reservation.numberOfPeople,
        date: reservation.date,
        startTime: reservation.startTime,
        endTime: reservation.endTime,
        tableNumber: reservation.tableNumber,
      });
    });

    // 사용자의 예약 정보 반환
    res
      .status(200)
      .json({
        message: "User reservations fetched successfully",
        reservations: userReservations,
      });
  } catch (error) {
    // 오류 발생 시 오류 응답
    console.error("Error fetching user reservations", error);
    res.status(500).json({ error: "Failed to fetch user reservations" });
  }
});

// 해당 날짜에 해당하는 모든 예약 내역 가져오기
reserveClub.get("/reservationclubs/:date", async (req, res) => {
  const date = req.params.date;

  try {
    // 해당 날짜의 모든 예약 내역 가져오기
    const reservationsSnapshot = await getDocs(
      collection(db, "reservationClub"),
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
        userClub: reservation.userClub,
        roomId: reservation.roomId,
        date: reservation.date,
        startTime: reservation.startTime,
        endTime: reservation.endTime,
        numberOfPeople: reservation.numberOfPeople,
        tableNumber: reservation.tableNumber,
      });
    });

    // 해당 날짜의 모든 예약 내역 반환
    res
      .status(200)
      .json({
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

export default reserveClub;
