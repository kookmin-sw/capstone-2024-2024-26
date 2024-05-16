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
  query,
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

const inquiry = express.Router();

// 문의하기
inquiry.post("/", async (req, res) => {
  const { userId, date, title, content } = req.body;

  try {
    // 사용자 정보 가져오기
    const userDoc = await getDoc(doc(db, "users", userId));

    if (!userDoc.exists()) {
      return res.status(404).json({ error: "User not found" });
    }
    const userData = userDoc.data();

    const collectionName = `${userData.faculty}_Inquiry`;

    // Inquiry 컬렉션 생성
    await setDoc(doc(db, collectionName, userData.studentId), {});

    const studentIdDocRef = doc(db, collectionName, userData.studentId);

    const offset = 1000 * 60 * 60 * 9;
    const koreaNow = new Date(new Date().getTime() + offset);
    const formattedDate = koreaNow.toISOString().replace('T', ' ').replace(/\.\d+Z$/, '').slice(0, -3); 
    

    const dateCollectionRef = collection(studentIdDocRef, date);

    const timeDocRef = doc(dateCollectionRef, formattedDate);

    // 문의 정보 추가
    await setDoc(timeDocRef, {
      faculty: userData.faculty,
      name: userData.name,
      studentId: userData.studentId,
      date: formattedDate,
      title: title,
      content: content,
      response: "",
      responseDate: "",
      responseStatus: false,
    });

    res.status(200).json({ message: "Created inquiry successfully" });
  } catch (error) {
    // 오류 발생 시 오류 응답
    console.error("Error creating inquiry", error);
    res.status(500).json({ error: "Failed to create inquiry" });
  }
});

// 사용자 전체 문의 내역 가져오기
inquiry.get("/list/:userId/:startDate/:endDate", async (req, res) => {
  const userId = req.params.userId;
  const startDate = req.params.startDate;
  const endDate = req.params.endDate;
  try {
    // 사용자 정보 가져오기
    const userDoc = await getDoc(doc(db, "users", userId));

    if (!userDoc.exists()) {
      return res.status(404).json({ error: "User not found" });
    }
    const userData = userDoc.data();

    const collectionName = `${userData.faculty}_Inquiry`;

    // 전체 문의 내역
    const allInquiry = [];

    for (
      let currentDate = new Date(startDate);
      currentDate <= new Date(endDate);
      currentDate.setDate(currentDate.getDate() + 1)
    ) {
      const dateString = currentDate.toISOString().split("T")[0]; // yyyy-mm-dd 형식의 문자열로 변환
      const dateCollectionRef = collection(
        db,
        `${collectionName}/${userData.studentId}/${dateString}`
      ); // 컬렉션 참조 생성

      // 해당 날짜별 시간 문서 조회
      const timeDocSnapshot = await getDocs(dateCollectionRef);

      timeDocSnapshot.forEach((docSnapshot) => {
        const reservationData = docSnapshot.data();
        // 문의 정보 조회
        allInquiry.push({
          faculty: reservationData.faculty,
          name: reservationData.name,
          studentId: reservationData.studentId,
          date: reservationData.date,
          title: reservationData.title,
          content: reservationData.content,
          response: reservationData.response,
          responseDate: reservationData.responseDate,
          responseStatus: reservationData.responseStatus,
        });
      });
    }

    res.status(200).json({
      message: "Inquiry retrieves successfully",
      inquiries: allInquiry,
    });
  } catch (error) {
    // 오류 발생 시 오류 응답
    console.error("Error retrieving inquiry", error);
    res.status(500).json({ error: "Failed to retrieve inquiry" });
  }
});

export default inquiry;

