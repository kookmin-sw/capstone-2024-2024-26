import {
    collection,
    getFirestore,
    getDoc,
    setDoc,
    doc,
    getDocs,
    where,
    deleteDoc,
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
  adminClub.post("/create", isAdmin, async (req, res) => {
    const {
      userId,
      roomId,
      date,
      startTime,
      endTime,
      tableNumber,
    } = req.body;
  
    try {
      // 사용자 정보 가져오기
      const userDoc = await getDoc(doc(db, "users", userId));
  
      if (!userDoc.exists()) {
        return res.status(404).json({ error: "User not found"});
      }
      const userData = userDoc.data();
  
      const existingMyReservationSnapshot = await getDocs(
        collection(db, "reservationClub"),
        where("userEmail", "==", userData.email)
      );
  
      const reservationCount = existingMyReservationSnapshot.size;
  
      // 예약 추가
      await setDoc(doc(db, "reservationClub", `${userId}_${reservationCount}`), {
        userEmail: userData.email,
        userName: userData.name,
        userClub: userData.club,
        roomId: roomId,
        date: date,
        startTime: startTime,
        endTime: endTime,
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
  
  adminClub.delete("/delete/:uid", isAdmin, async (req, res) => {
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
  
  export default adminClub;
  