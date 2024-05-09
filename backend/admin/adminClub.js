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
adminClub.post("/", isAdmin, async (req, res) => {});

// 관리자 동아리방 예약 내역 삭제
adminClub.delete(
  "/delete/:userId/:reservationUID",
  isAdmin,
  async (req, res) => {}
);

// 동아리방 예약 수정
adminClub.post(
  "/update/:userId/:reserveclubUID",
  isAdmin,
  async (req, res) => {}
);

// 관리자 동아리방 설정 생성
adminClub.post("/create/room", isAdmin, async (req, res) => {
  const {
    faculty,
    roomName,
    location,
    available_Table,
    available_People,
    available_Time,
    clubRoomImage,
  } = req.body;
  try {
    // 단과대학 동아리 컬렉션 생성
    const facultyClubCollectionRef = collection(
      db,
      `${faculty}_Club`
    );

    // 동아리방 위치 문서 생성
    const clubRoomDocRef = doc(facultyClubCollectionRef, `${roomName}`);

    // 정보 생성
    const data = {
      faculty: faculty,
      roomName: roomName,
      location: location,
      available_Table: available_Table,
      available_People: available_People,
      available_Time: available_Time,
      clubRoomImage: clubRoomImage,
    };

    // 강의실 정보 및 이미지 URL 저장
    await setDoc(clubRoomDocRef, data);

    res.status(200).json({ message: "Register Club Room successfully" });
  } catch (error) {
    console.error("Error registering Club Room:", error);
    res.status(500).json({ error: "Failed to register Club Room" });
  }
});

export default adminClub;
