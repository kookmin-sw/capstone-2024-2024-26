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

const adminInquiry = express.Router();

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

adminInquiry.post("/", isAdmin, async (req, res) => {
  const { userId, date, inquiryId, response } = req.body;

  try {
    // 사용자 정보 가져오기
    const userDoc = await getDoc(doc(db, "users", userId));

    if (!userDoc.exists()) {
      return res.status(404).json({ error: "User not found" });
    }
    const userData = userDoc.data();

    const collectionName = `${userData.faculty}_Inquiry`;

    // 학번을 문서 ID로 사용하여 문의 문서 참조 생성
    const studentDocRef = doc(db, collectionName, userData.studentId);

    // 날짜별 문의 컬렉션 참조 생성 (자동으로 문서 ID가 생성됨)
    const dateCollectionRef = collection(studentDocRef, date);

    const inquiryDocRef = doc(dateCollectionRef, inquiryId);

    const currentDate = new Date();

    const responseDate = currentDate.toISOString().split("T")[0];

    await updateDoc(inquiryDocRef, {
      response: response,
      responseDate: responseDate,
      responseStatus: true
    });
    res.status(200).json({
      message: "Administrator inquiry did response fetched successfully"
    });
  } catch (error) {
    // 오류 발생 시 오류 응답
    console.error("Error response Administrator inquiry", error);
    res.status(500).json({ error: "Failed to response Administrator inquiry" });
  }
});

export default adminInquiry;