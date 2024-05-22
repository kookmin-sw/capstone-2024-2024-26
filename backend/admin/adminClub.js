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

// function isAdmin(req, res, next) {
//   const { email } = req.body;
//   // 관리자 이메일
//   const adminEmail = "react@kookmin.ac.kr";

//   // 이메일이 관리자 이메일과 일치하는지 확인
//   if (email === adminEmail) {
//     // 관리자인 경우 다음 미들웨어로 진행
//     console.log("isAdmin OK");
//     next();
//   } else {
//     // 관리자가 아닌 경우 권한 없음 응답
//     res.status(403).json({ error: "Unauthorized: You are not an admin " });
//   }
// }

// 관리자 동아리방 설정 생성
adminClub.post("/create/room", async (req, res) => {
  const {
    faculty,
    roomName,
    available_Table,
    tableList, // 테이블 정보
    available_People,
    available_Time,
    clubRoomImage, // 인코딩된 이미지 값(강의실 사진)
    clubRoomDesignImage, // 인코딩된 이미지 값(강의실 도안 사진)
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
      tableList: tableList,
      available_People: available_People,
      available_Time: available_Time,
      clubRoomImage: clubRoomImage,
      clubRoomDesignImage: clubRoomDesignImage,
    };

    // 강의실 정보 및 이미지 URL 저장
    await setDoc(clubRoomDocRef, data);

    res.status(200).json({ message: "Register Club Room successfully" });
  } catch (error) {
    console.error("Error registering Club Room:", error);
    res.status(500).json({ error: "Failed to register Club Room" });
  }
});

// 동아리방 정보 불러오기
adminClub.get("/clubRoomInfo/:faculty", async (req, res) => {
  const faculty = req.params.faculty;

  try {
    // 컬렉션 이름 설정
    const collectionName = `${faculty}_Club`;

    const facultyClubCollcetion = collection(db, collectionName);

    const querySnapshot = await getDocs(facultyClubCollcetion);

    if (querySnapshot.empty) {
      return res.status(401).json({ error: "ClubRoom Info does not exist" });
    }

    const allClubRoomInfo = [];

    querySnapshot.forEach((doc) => {
      const clubRoomInfo = doc.data();
      allClubRoomInfo.push({
        faculty: clubRoomInfo.faculty,
        roomName: clubRoomInfo.roomName,
        available_Table: clubRoomInfo.available_Table,
        tableList: clubRoomInfo.tableList,
        available_Time: clubRoomInfo.available_Time,
        available_People: clubRoomInfo.available_People,
        clubRoomImage: clubRoomInfo.clubRoomImage,
        clubRoomDesignImage: clubRoomInfo.clubRoomDesignImage,
      });
    });

    res.status(200).json({
      message: "fetch all clubRoom info successfully",
      allClubRoomInfo,
    });
  } catch (error) {
    //오류 발생 시 오류 응답
    console.error("Error fetching clubRoom info", error);
    res.status(500).json({ error: "Failed to fetch clubRoom info" });
  }
});

// 동아리방 정보 삭제
adminClub.delete("/delete/clubRoomInfo", async (req, res) => {
  const { faculty, roomName } = req.body;

  try {
    // 컬렉션 이름 설정
    const collectionName = `${faculty}_Club`;

    const facultyClubCollcetion = collection(db, collectionName);

    const roomDocRef = doc(facultyClubCollcetion, roomName);

    const roomDocSnapshot = await getDoc(roomDocRef);
    if (!roomDocSnapshot.exists()) {
      return res.status(404).json({ error: "Room not found" });
    }

    await deleteDoc(roomDocRef);

    res.status(200).json({ message: "Room deleted successfully" });
  } catch (error) {
    console.error("Error deleting room", error);
    res.status(500).json({ error: "Failed to delete room" });
  }
});

// 사용자별 특정 시작 날짜부터 특정 끝 날짜까지의 예약 내역 반환
adminClub.get(
  "/reservationclubs/:faculty/:startDate/:endDate",

  async (req, res) => {
    const faculty = req.params.faculty;
    const startDate = new Date(req.params.startDate);
    const endDate = new Date(req.params.endDate);

    try {
      // 컬렉션 이름 설정
      const collectionName = `${faculty}_Club`;

      // 사용자 예약 내역
      const userReservations = [];

      // 동아리방 컬렉션 참조
      const facultyClubCollectionRef = collection(db, collectionName);

      const querySnapshot = await getDocs(facultyClubCollectionRef);

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
              if (reservationData && reservationData.tableData) {
                const startTime = docSnapshot.id.split("-")[0];
                const endTime = docSnapshot.id.split("-")[1];

                console.log(reservationData.tableData);
                // 예약된 테이블 정보 조회
                reservationData.tableData.forEach((table) => {
                  if (table.studentId) {
                    userReservations.push({
                      roomName: roomName,
                      date: dateString,
                      startTime: startTime,
                      endTime: endTime,
                      tableData: table,
                    });
                  }
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

export default adminClub;