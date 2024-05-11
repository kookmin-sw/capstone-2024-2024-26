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
adminClub.post("/reserve", isAdmin, async (req, res) => {
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
      return res.status(404).json({ error: "This Club room does not exists" });
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
adminClub.post(
  "/delete",
  isAdmin,
  async (req, res) => {
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
        return res.status(404).json({ error: "This Club room does not exists" });
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
  
      const startTimeParts = startTime.split(":");
      const startTimeHour = parseInt(startTimeParts[0]);
  
      const endTimeParts = endTime.split(":");
      const endTimeHour = parseInt(endTimeParts[0]);
  
      // 시작 시간부터 종료 시간까지 각 시간대에 대해 예약 문서를 업데이트합니다.
      for (let i = startTimeHour; i < endTimeHour; i++) {
        const reservationDocRef = doc(dateCollection, `${i}-${i + 1}`);
        const reservationDocSnap = await getDoc(reservationDocRef);
  
        // 해당 시간대 예약 문서가 있는지 확인
        if (reservationDocSnap.exists()) {
          const reservationData = reservationDocSnap.data();
  
          // 해당 테이블 번호의 예약을 취소하고 상태를 false로 변경합니다.
          const index = parseInt(tableNumber) - 1;
          if (reservationData.tableData[index][`T${tableNumber}`]) {
            console.log(reservationData.tableData[index]);
            // 예약 취소 및 테이블 상태 변경
            reservationData.tableData[index][`T${tableNumber}`] = false;
            delete reservationData.tableData[index].name;
            delete reservationData.tableData[index].studentId;
  
            await updateDoc(reservationDocRef, {
              tableData: reservationData.tableData,
            });
          }
        }
      }
  
      res.status(200).json({ message: "Reservation canceled successfully" });
    } catch (error) {
      console.error("Error canceling reservation", error);
      return res.status(500).json({ error: "Failed to cancel reservation" });
    }
  }
);

// 관리자 동아리방 설정 생성
adminClub.post("/create/room", isAdmin, async (req, res) => {
  const {
    faculty,
    roomName,
    available_Table,
    available_People,
    available_Time,
    clubRoomImage, // 인코딩된 이미지 값(강의실 사진)
    clubRoomDesignImage // 인코딩된 이미지 값(강의실 도안 사진)
  } = req.body;
  try {
    // 단과대학 동아리 컬렉션 생성
    const facultyClubCollectionRef = collection(db, `${faculty}_Club`);

    // 동아리방 위치 문서 생성
    const clubRoomDocRef = doc(facultyClubCollectionRef, `${roomName}`);

    // 정보 생성
    const data = {
      faculty: faculty,
      roomName: roomName,
      available_Table: available_Table,
      available_People: available_People,
      available_Time: available_Time,
      clubRoomImage: clubRoomImage,
      clubRoomDesignImage: clubRoomDesignImage
    };

    // 강의실 정보 및 이미지 URL 저장
    await setDoc(clubRoomDocRef, data);

    res.status(200).json({ message: "Register Club Room successfully" });
  } catch (error) {
    console.error("Error registering Club Room:", error);
    res.status(500).json({ error: "Failed to register Club Room" });
  }
});

adminClub.get(
  "/reservations/:startDate/:endDate",
  isAdmin,
  async (req, res) => {
    const { faculty } = req.body;
    const startDate = new Date(req.params.startDate);
    const endDate = new Date(req.params.endDate);

    try {
      const collectionName = `${faculty}_Classroom`;

      // 각 단과대별 강의실 컬렉션
      const facultyConferenceCollcetion = collection(db, collectionName);

      // 해당 컬렉션의 모든 문서 가져오기
      const querySnapshot = await getDocs(facultyConferenceCollcetion);

      // 모든 문서 데이터를 저장할 배열
      const allDocData = [];

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
                allDocData.push({
                  roomName: roomName,
                  mainName: reservationData.mainName,
                  date: dateString,
                  startTime: startTime,
                  endTime: endTime,
                  studentName: reservationData.studentNames,
                  studentDepartment: reservationData.studentDepartments,
                  studentId: reservationData.studentIds,
                  usingPurpose: reservationData.usingPurpose,
                  boolAgree: reservationData.boolAgree,
                });
              }
            });
          }
        })
      );

      // 사용자 예약 내역 반환
      res.status(200).json({
        message: "Administrator reservations fetched successfully",
        reservations: allDocData,
      });
    } catch (error) {
      // 오류 발생 시 오류 응답
      console.error("Error fetching Administrator reservations", error);
      res
        .status(500)
        .json({ error: "Failed to fetch administrator reservations" });
    }
  }
);

export default adminClub;
