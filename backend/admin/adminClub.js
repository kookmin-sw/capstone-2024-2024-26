import {
  collection,
  getFirestore,
  getDoc,
  setDoc,
  doc,
  getDocs,
  where,
  deleteDoc,
  updateDoc
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

const adminClub = express.Router();

function isAdmin(req, res, next) {
  const { email } = req.body;
  // 관리자 이메일
  const adminEmail = "react@kookmin.ac.kr";

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

// 관리자 동아리방 예약 생성
adminClub.post("/", isAdmin, async (req, res) => {
  const { userId, roomName, date, startTime, endTime, tableNumber } = req.body;
  try {
    // 사용자 정보 가져오기
    const userDoc = await getDoc(doc(db, "users", userId));

    if (!userDoc.exists()) {
      return res.status(404).json({ error: "User not found" });
    }
    const userData = userDoc.data();

    const collectionName = `${userData.faculty}_Club`;

    const existDocSnapShot = await getDoc(doc(db, collectionName, roomName));

    if (!existDocSnapShot.exists()) {
      // 해당 문서가 존재하지 않는 경우
      return res.status(404).json({ error: "This Club room does not exists"});
    } 
    const facultyClubCollection = collection(db, collectionName);
    const clubRoomDoc = doc(facultyClubCollection, roomName);
    const clubRoomDocSnap = await getDoc(clubRoomDoc);

    // 해당 동아리방이 있는지 확인
    if (!clubRoomDocSnap.exists()) {
      return res.status(404).json({
        error: `${roomName} does not exist in ${collectionName} collection`,
      });
    }

    const dateCollection = collection(clubRoomDoc, date);
    const availableTable = parseInt(clubRoomDocSnap.data().available_Table);

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
        const reservationData = reservationDocSnap.data();

        // 이미 예약된 테이블이 있는지 확인
        const index = parseInt(tableNumber) - 1;
        if (reservationData.tableData[index][`T${tableNumber}`]) {
          // 이미 예약된 테이블이 있는 경우 예약을 중단하고 다음 시간대로 넘어갑니다.
          return res.status(400).json({
            error: `Table ${tableNumber} is already reserved from ${i}-${
              i + 1
            }`,
          });
        }
      }
    }
    for (let i = startTimeHour; i < endTimeHour; i++) {
      const reservationDocRef = doc(dateCollection, `${i}-${i + 1}`);
      const reservationDocSnap = await getDoc(reservationDocRef);
      if (!reservationDocSnap.exists()) {
        const tableData = new Array();
        for (let j = 1; j <= availableTable; j++) {
          const tableInfo = {
            [`T${j}`]: j === parseInt(tableNumber) ? true : false,
          };
          // name과 studentId를 추가합니다.
          if (j === parseInt(tableNumber)) {
            tableInfo.name = userData.name;
            tableInfo.studentId = userData.studentId;
          }
          tableData.push(tableInfo);
        }
        await setDoc(reservationDocRef, {
          tableData: tableData,
        });
      } else {
        // 해당 시간대의 문서가 존재할 때
        const reservationData = reservationDocSnap.data();

        // 기존에 예약된 테이블이 있는 경우, 해당 테이블만 true로 설정하고 업데이트
        // 특정 테이블 번호를 true로 설정합니다.
        const index = parseInt(tableNumber) - 1;
        if (reservationData.tableData[index][`T${tableNumber}`] === false) {
          // 해당 테이블에 대해 name과 studentId도 업데이트
          reservationData.tableData[index][`T${tableNumber}`] = true;
          reservationData.tableData[index].name = userData.name;
          reservationData.tableData[index].studentId = userData.studentId;

          await updateDoc(reservationDocRef, {
            tableData: reservationData.tableData,
          });
        }
      }
    }
    res.status(200).json({ message: "Creating reservation club successfully" });
  } catch (error) {
    console.error("Error creating reservation club", error);
    return res.status(500).json({ error: "Failed reservation club" });
  }
});

// 관리자 동아리방 예약 내역 삭제
adminClub.delete(
  "/delete/:userId/:reservationUID",
  isAdmin,
  async (req, res) => {
    const userId = req.params.userId;
    const reservationUID = req.params.reservationUID;

    try {
      // 사용자 정보 가져오기
      const userDoc = await getDoc(doc(db, "users", userId));

      if (!userDoc.exists()) {
        return res.status(404).json({ error: "User not found" });
      }
      const userData = userDoc.data();

      // 컬렉션 이름 설정
      const collectionName = `${userData.faculty}_Club`;

      // Firestore에서 동아리 예약내역 삭제
      await deleteDoc(doc(db, `${collectionName}`, reservationUID));

      res
        .status(200)
        .json({ message: "Reservation club deleted successfully" });
    } catch (error) {
      console.log("Error deleting reservation club", error);
      res.status(500).json({ error: "Failed to delete reservation club" });
    }
  }
);

// 동아리방 예약 수정
adminClub.post("/update/:userId/:reserveclubUID", isAdmin, async (req, res) => {
  const userId = req.params.userId;
  const reserveclubUID = req.params.reserveclubUID;
  const { roomId, date, startTime, endTime, tableNumber } = req.body;

  try {
    // 사용자 정보 가져오기
    const userDoc = await getDoc(doc(db, "users", userId));

    if (!userDoc.exists()) {
      return res.status(404).json({ error: "User not found" });
    }
    const userData = userDoc.data();

    // 컬렉션 이름 설정
    const collectionName = `${userData.faculty}_Club`;

    // Firestore reservationClub에서 해당 예약 문서를 가져옴
    const reserveClubDoc = await getDoc(
      doc(db, `${collectionName}`, reserveclubUID)
    );
    if (!reserveClubDoc.exists()) {
      // 예약 문서가 존재하지 않는 경우 오류 응답
      return res.status(404).json({ error: "Reservation not found" });
    }
    // 문서 ID에 roomId와 같은 문자열이 포함되어 있는지 확인
    const existingReservationSnapshot = await getDocs(
      collection(db, `${collectionName}`),
      where("roomId", "==", roomId)
    );

    const existingReservation = existingReservationSnapshot.docs.find((doc) =>
      doc.id.includes(roomId)
    );
    // roomId와 같은 문자열이 포함되어 있는 경우 예약 진행
    if (existingReservation) {
      // 변경된 필드만 업데이트
      const updateFields = {};
      if (roomId) updateFields.roomId = roomId;
      if (date) updateFields.date = date;
      if (startTime) updateFields.startTime = startTime;
      if (endTime) updateFields.endTime = endTime;
      if (tableNumber) updateFields.tableNumber = tableNumber;

      // 겹치는 예약이 있는지 확인
      const existingReservationsSnapshot = await getDocs(
        collection(db, `${collectionName}`),
        where("date", "==", date),
        where("roomId", "==", roomId),
        where("tableNumber", "==", tableNumber),
        where("reserveclubUID", "!=", reserveclubUID) // 현재 예약을 제외하고 조회
      );

      // 겹치는 예약이 있는지 확인
      const overlappingReservation = existingReservationsSnapshot.docs.find(
        (doc) => {
          const reservation = doc.data();
          console.log(reservation);

          // 기존 예약의 시작 시간과 끝 시간
          const existingStartTime = reservation.startTime;
          const existingEndTime = reservation.endTime;
          const existingDate = reservation.date;
          const existingRoomId = reservation.roomId;
          const startTimeClub = updateFields.startTime;
          const endTimeClub = updateFields.endTime;

          // 예약 시간이 같은 경우 또는 기존 예약과 겹치는 경우 확인
          if (
            (existingDate == date &&
              startTimeClub == existingStartTime &&
              endTimeClub == existingEndTime &&
              roomId == existingRoomId) ||
            (existingDate == date &&
              roomId == existingRoomId &&
              startTimeClub < existingEndTime &&
              endTimeClub > existingStartTime)
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

      // 겹치는 예약이 없으면 예약 업데이트
      await updateDoc(
        doc(db, `${collectionName}`, reserveclubUID),
        updateFields
      );

      // 업데이트 된 동아리방 예약 정보 반환
      res.status(200).json({ message: "Reservationclub updated successfully" });
    } else {
      // roomId와 같은 문자열이 포함되어 있지 않은 경우 에러 반환
      return res.status(404).json({ error: "Room not found" });
    }
  } catch (error) {
    console.error("Error updating reservationclub");
    res.status(500).json({ error: "Failed to update reservationclub" });
  }
});

// 관리자 동아리방 설정 생성
adminClub.post("/create/room", isAdmin, async (req, res) => {
  const { faculty, roomName , location, available_Table } = req.body;
  try {
    // 단과대학 동아리 컬렉션 생성
    const facultyClubCollectionRef = collection(db, `${faculty}_Club`);

    // 동아리방 위치 문서 생성
    const clubRoomDocRef = doc(facultyClubCollectionRef, `${roomName}`);

    // 정보 생성
    const data = {
      roomName: `${roomName}`,
      location: `${location}`,
      available_Table: `${available_Table}`,
      available_Time: "09:00 - 22:00"
    }

    // 정보 저장
    await setDoc(clubRoomDocRef, data);

    res.status(200).json({ message: "Register Club Room successfully" });
  } catch (error) {
    console.error("Error registering Club Room:", error);
    res.status(500).json({ error: "Failed to register Club Room" });
  }
});

export default adminClub;
