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
    await addDoc(collection(db, "reservationRoom"), {
      userId: userId,
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

export default reserveroom;
