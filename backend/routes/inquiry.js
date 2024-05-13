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

    const year = koreaNow.getFullYear();
    const month = String(koreaNow.getMonth() + 1).padStart(2, "0");
    const day = String(koreaNow.getDate()).padStart(2, "0");
    const hours = String(koreaNow.getHours()).padStart(2, "0");
    const minutes = String(koreaNow.getMinutes()).padStart(2, "0");

    const time = `${year}-${month}-${day}-${hours}-${minutes}`;

    const dateCollectionRef = collection(studentIdDocRef, date);

    const timeDocRef = doc(dateCollectionRef, time);

    // 문의 정보 추가
    await setDoc(timeDocRef, {
      faculty: userData.faculty,
      name: userData.name,
      studentId: userData.studentId,
      date: time,
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

export default inquiry;
