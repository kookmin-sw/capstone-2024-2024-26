import {
  collection,
  getFirestore,
  getDoc,
  setDoc,
  doc,
  getDocs,
  where,
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
  const { userId, roomId, date, startTime, endTime, numberOfPeople } = req.body;

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
    const isOverlappingRoom = existingroomReservationSnapshot.docs.some(
      (doc) => {
        const reservationRoom = doc.data();

        // 기존 예약의 시작 시간과 끝 시간
        const existingStartTimeRoom = new Date(reservationRoom.startTime);
        const existingEndTimeRoom = new Date(reservationRoom.endTime);

        // 겹치는 예약인지 확인
        if (
          (startTime < existingEndTimeRoom &&
            endTime > existingStartTimeRoom) ||
          (existingStartTimeRoom < endTime && existingEndTimeRoom > startTime)
        ) {
          return true;
        }

        return false;
      }
    );

    // 겹치는 예약이 있는 경우 에러 반환
    if (isOverlappingRoom) {
      return res
        .status(400)
        .json({ error: " The room is already reserved for this time" });
    }

    // 겹치는 예약이 없으면 예약 추가
    await setDoc(doc(db, "reservationRoom", userId), {
      name: userData.name,
      roomId: roomId,
      date: date,
      startTime: startTime,
      endTime: endTime,
      numberOfPeople: numberOfPeople,
    });

    // 예약 성공 시 응답
    res.status(201).json({ message: "Reservation room created successfully" });
  } catch (error) {
    // 오류 발생 시 오류 응답
    console.error("Error creating reservation room", error);
    res.status(500).json({ error: "Failed reservation room" });
  }
});

reserveroom.get("/reservationrooms/:date", async(req, res) => {
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
})

export default reserveroom;
