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

const adminRoom = express.Router();

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

// 관리자 강의실 생성
adminRoom.post("/create/room", isAdmin, async (req, res) => {
  const { faculty, department, roomId } = req.body;
  try {
    await setDoc(doc(db, `${faculty}_${department}_Club`, `${roomId}`), {
      adminMessage: `Admin has set up ${roomId} classroom.`,
    });

    res.status(200).json({ message: "Register Classroom successfully" });
  } catch (error) {
    console.error("Error registering Classroom:", error);
    res.status(500).json({ error: "Failed to register Classroom" });
  }
});

export default adminRoom;
