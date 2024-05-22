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

adminInquiry.post("/", async (req, res) => {
  const { studentId, date, time, response } = req.body;

  try {
    // 사용자 정보 가져오기
    const user = query(
      collection(db, "users"),
      where("studentId", "==", studentId)
    );
    const userDocSnapshot = await getDocs(user);

    if (userDocSnapshot.empty) {
      return res.status(404).json({ error: "User not found" });
    }

    const userDoc = userDocSnapshot.docs[0];
    const userData = userDoc.data();
    const collectionName = `${userData.faculty}_Inquiry`;

    // 학번을 문서 ID로 사용하여 문의 문서 참조 생성
    const studentDocRef = doc(db, collectionName, userData.studentId);

    // 날짜별 문의 컬렉션 참조 생성 (자동으로 문서 ID가 생성됨)
    const dateCollectionRef = collection(studentDocRef, date);

    const timeDocRef = doc(dateCollectionRef, time);

    const offset = 1000 * 60 * 60 * 9;
    const koreaNow = new Date(new Date().getTime() + offset);
    // YY-MM-DD HH:MM 형식
    const formattedDate = koreaNow
      .toISOString()
      .replace("T", " ")
      .replace(/\.\d+Z$/, "")
      .slice(0, -3);

    await updateDoc(timeDocRef, {
      response: response,
      responseDate: formattedDate,
      responseStatus: true,
    });
    res.status(200).json({
      message: "Administrator inquiry did response fetched successfully",
    });
  } catch (error) {
    // 오류 발생 시 오류 응답
    console.error("Error response Administrator inquiry", error);
    res.status(500).json({ error: "Failed to response Administrator inquiry" });
  }
});

// 전체 문의 내역 가져오기
adminInquiry.get("/list/:faculty/:startDate/:endDate", async (req, res) => {
  const faculty = req.params.faculty;
  const startDate = req.params.startDate;
  const endDate = req.params.endDate;
  try {
    const collectionName = `${faculty}_Inquiry`;

    const inquiryCollectionRef = collection(db, collectionName);

    // 학번을 문서 ID로 사용하여 문의 문서 참조 생성
    const querySnapshot = await getDocs(inquiryCollectionRef);

    // 전체 문의 내역
    const allInquiry = [];

    // 비동기 처리를 위해 Promise.all 사용
    await Promise.all(
      querySnapshot.docs.map(async (student) => {
        const studentId = student.id;
        console.log(studentId);
        for (
          let currentDate = new Date(startDate);
          currentDate <= new Date(endDate);
          currentDate.setDate(currentDate.getDate() + 1)
        ) {
          const dateString = currentDate.toISOString().split("T")[0]; // yyyy-mm-dd 형식의 문자열로 변환
          const dateCollectionRef = collection(
            db,
            `${collectionName}/${studentId}/${dateString}`
          ); // 컬렉션 참조 생성

          // console.log(dateCollectionRef);
          // 해당 날짜별 시간 문서 조회
          const timeDocSnapshot = await getDocs(dateCollectionRef);

          // console.log(timeDocSnapshot);
          timeDocSnapshot.forEach((docSnapshot) => {
            const reservationData = docSnapshot.data();
            console.log(docSnapshot.id);
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
      })
    );
    res.status(200).json({
      message: "Administrator inquiry retrieves successfully",
      inquiries: allInquiry,
    });
  } catch (error) {
    // 오류 발생 시 오류 응답
    console.error("Error retrieving Administrator inquiry", error);
    res.status(500).json({ error: "Failed to retrieve Administrator inquiry" });
  }
});

export default adminInquiry;
