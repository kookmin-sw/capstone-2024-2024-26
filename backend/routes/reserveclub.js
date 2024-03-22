import {
  addDoc,
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
      where("tableNumber", "==", tableNumber)
    );

    // 겹치는 예약이 있는지 확인
    const overlappingReservation = existingReservationsSnapshot.docs.find(
      (doc) => {
        const reservation = doc.data();

        // 기존 예약의 시작 시간과 끝 시간
        const existingStartTime = reservation.startTime;
        const existingEndTime = reservation.endTime;
        const startTimeClub = startTime;
        const endTimeClub = endTime;

        // 예약 시간이 같은 경우 또는 기존 예약과 겹치는 경우 확인
        if (
          (startTimeClub == existingStartTime &&
            endTimeClub == existingEndTime) ||
          (startTimeClub < existingEndTime && endTimeClub > existingStartTime)
        ) {
          return true;
        }

        return false;
      }
    );

    // 겹치는 예약이 있는 경우 에러 반환
    if (overlappingReservation) {
      return res
        .status(400)
        .json({ error: "The room is already reserved for this time" });
    }

    // 겹치는 예약이 없으면 예약 추가
    await setDoc(doc(db, "reservationClub", userId), {
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
    res.status(200).json({
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

reserveClub.post("/update/:uid", async (req, res) => {
  try {
    const userId = req.params.uid;
    const { roomId, date, startTime, endTime, numberOfPeople, tableNumber } =
      req.body;

    // Firestore reservationClub에서 해당 예약 문서를 가져옴
    const reserveClubDoc = await getDoc(doc(db, "reservationClub", userId));
    if (!reserveClubDoc.exists()) {
      // 예약 문서가 존재하지 않는 경우 오류 응답
      return res.status(404).json({ error: "Reservation not found" });
    }

    // 변경된 필드만 업데이트
    const updateFields = {};
    if (roomId) updateFields.roomId = roomId;
    if (date) updateFields.date = date;
    if (startTime) updateFields.startTime = startTime;
    if (endTime) updateFields.endTime = endTime;
    if (numberOfPeople) updateFields.numberOfPeople = numberOfPeople;
    if (tableNumber) updateFields.tableNumber = tableNumber;

    // 겹치는 예약이 있는지 확인
    const existingReservationsSnapshot = await getDocs(
      collection(db, "reservationClub"),
      where("date", "==", date),
      where("roomId", "==", roomId),
      where("tableNumber", "==", tableNumber),
      where("userId", "!=", userId) // 현재 예약을 제외하고 조회
    );

    // 겹치는 예약이 있는 경우 에러 반환
    if (!existingReservationsSnapshot.empty) {
      const overlappingReservation = existingReservationsSnapshot.docs.find(
        (doc) => {
          const reservation = doc.data();
          const existingStartTime = reservation.startTime;
          const existingEndTime = reservation.endTime;

          // 예약 시간이 같은 경우 또는 기존 예약과 겹치는 경우 확인
          if (
            (startTime == existingStartTime && endTime == existingEndTime) ||
            (startTime < existingEndTime && endTime > existingStartTime)
          ) {
            return true;
          }
          return false;
        }
      );

      if (overlappingReservation) {
        return res
          .status(400)
          .json({ error: "The room is already reserved for this time" });
      }
    }

    // 겹치는 예약이 없으면 예약 업데이트
    await updateDoc(doc(db, "reservationClub", userId), updateFields);

    // 업데이트 된 동아리방 예약 정보 반환
    res.status(200).json({ message: "Reservationclub updated successfully" });
  } catch (error) {
    console.error("Error updating reservationclub");
    res.status(500).json({ error: "Failed to update reservationclub" });
  }
});

function isAdmin(req, res, next) {
  const { email } = req.body;
  // 관리자 이메일
  const adminEmail = "admin@kookmin.ac.kr";

  // 이메일이 관리자 이메일과 일치하는지 확인
  if (email === adminEmail) {
    // 관리자인 경우 다음 미들웨어로 진행
    console.log("isAdmin OK");
    next();
  } else {
    // 관리자가 아닌 경우 권한 없음 응답
    res.status(403).json({ error: "Unauthorized: You are not an admin " });
  }
}

// 동아리방 예약 생성 (관리자 모드)
reserveClub.post("/adminMode/add", isAdmin, async (req, res) => {
  const {
    userId,
    userName,
    userClub,
    roomId,
    date,
    startTime,
    endTime,
    numberOfPeople,
    tableNumber,
  } = req.body;

  try {
    // 예약 추가
    await addDoc(collection(db, "reservationClub"), {
      userId: userId,
      userName: userName,
      userClub: userClub,
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
    console.error("Error creating reservation club in admin mode", error);
    res.status(500).json({ error: "Failed reservation club in admin mode" });
  }
});

reserveClub.delete("/adminMode/delete/:uid", isAdmin, async (req, res) => {
  try {
    // Firestore reservationClub uid로 해야함!!
    const userId = req.params.uid;

    // Firestore에서 동아리 예약내역 삭제
    await deleteDoc(doc(db, "reservationClub", userId));

    res.status(200).json({ message: "Reservation club deleted successfully" });
  } catch (error) {
    console.log("Error deleting reservation club", error);
    res.status(500).json({ error: "Failed to delete reservation club" });
  }
});

export default reserveClub;
