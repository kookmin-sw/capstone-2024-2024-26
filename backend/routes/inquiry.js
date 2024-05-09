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
  const { userId, date, content } = req.body;

  try {
    // 사용자 정보 가져오기
    const userDoc = await getDoc(doc(db, "users", userId));

    if (!userDoc.exists()) {
      return res.status(404).json({ error: "User not found" });
    }
    const userData = userDoc.data();

    const collectionName = `${userData.faculty}_Inquiry`;

    // 학번을 문서 ID로 사용하여 문의 문서 참조 생성
    const inquiryDocRef = doc(db, collectionName, userData.studentId);

    // 날짜별 문의 컬렉션 참조 생성 (자동으로 문서 ID가 생성됨)
    const dateCollectionRef = collection(inquiryDocRef, date);

    // 문의 정보 추가
    await addDoc(dateCollectionRef, {
      faculty: userData.faculty,
      name: userData.name,
      studentId: userData.studentId,
      date: date,
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

export default inquiry;
