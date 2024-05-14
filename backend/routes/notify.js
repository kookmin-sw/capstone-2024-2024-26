import express from "express";
import admin from "firebase-admin";
import dotenv from "dotenv";
import cron from "node-cron";
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
const messaging = admin.messaging();

const notify = express.Router();

// 모든 사용자에게 10분 전 공유공간 입실 알림
cron.schedule("*/10 * * * *", async () => {
  try {
    // 현재 한국 시간 가져오기
    const offset = 1000 * 60 * 60 * 9; // 한국 시간 UTC+9
    const koreaNow = new Date(new Date().getTime() + offset);

    const tenMinutesLater = new Date(koreaNow.getTime() + 10 * 60 * 1000);

    const formattedDate = koreaNow.toISOString().split("T")[0];

    // 모든 사용자 정보 가져오기
    const userCollectionRef = collection(db, "users");
    const querySnapshot = await getDocs(userCollectionRef);

    // 각 사용자별로 처리
    querySnapshot.docs.forEach(async (user) => {
      const userData = user.data();
      const facultyRef = collection(db, `${userData.faculty}_Club`);
      const roomSnapshot = await getDocs(facultyRef);
      if (!roomSnapshot.empty) {
        roomSnapshot.docs.forEach(async (roomDoc) => {
          // 해당 날짜 컬렉션으로 접근
          const roomName = roomDoc.id;
          const dateCollectionRef = collection(
            db,
            `${userData.faculty}_Club/${roomName}/${formattedDate}`
          );
          // 해당 날짜별 시간 대 참조
          const timeDocSnapshot = await getDocs(dateCollectionRef);
          if (!timeDocSnapshot.empty) {
            timeDocSnapshot.docs.forEach(async (docSnapshot) => {
              if (docSnapshot.exists()) {
                const timeInfo = docSnapshot.id;
                const startTime = timeInfo.split("-")[0];
                const reservationData = docSnapshot.data();
                const reservationStartTime = new Date(
                  formattedDate + "T" + startTime + ":00Z"
                );
                if (
                  reservationStartTime.getTime() <= tenMinutesLater.getTime()
                ) {
                  reservationData.tableData.forEach((table) => {
                    if (table.studentId === userData.studentId) {
                      const notificationMessage = {
                        message: `${formattedDate} ${startTime}시에 ${roomName}으로 입장해주세요.`,
                      };

                      messaging.sendEach({
                        tokens: userData.fcmToken,
                        message: notificationMessage,
                      });
                    }
                  });
                }
              }
            });
          }
        });
      }
    });

    console.log("Scheduled task completed.");
  } catch (error) {
    console.error("Error during scheduled task:", error);
  }
});

// 모든 사용자에게 10분 전 강의실 입실 알림
cron.schedule("*/10 * * * *", async () => {
  try {
    // 현재 한국 시간 가져오기
    const offset = 1000 * 60 * 60 * 9; // 한국 시간 UTC+9
    const koreaNow = new Date(new Date().getTime() + offset);

    const tenMinutesLater = new Date(koreaNow.getTime() + 10 * 60 * 1000);

    const formattedDate = koreaNow.toISOString().split("T")[0];

    // 모든 사용자 정보 가져오기
    const userCollectionRef = collection(db, "users");
    const querySnapshot = await getDocs(userCollectionRef);

    // 각 사용자별로 처리
    querySnapshot.docs.forEach(async (user) => {
      const userData = user.data();
      const facultyRef = collection(db, `${userData.faculty}_Classroom`);
      const roomSnapshot = await getDocs(facultyRef);
      if (!roomSnapshot.empty) {
        roomSnapshot.docs.forEach(async (roomDoc) => {
          // 해당 날짜 컬렉션으로 접근
          const roomName = roomDoc.id;
          const dateCollectionRef = collection(
            db,
            `${userData.faculty}_Classroom/${roomName}/${formattedDate}`
          );
          // 해당 날짜별 시간 대 참조
          const timeDocSnapshot = await getDocs(dateCollectionRef);
          if (!timeDocSnapshot.empty) {
            timeDocSnapshot.docs.forEach(async (docSnapshot) => {
              if (docSnapshot.exists()) {
                const timeInfo = docSnapshot.id;
                const startTime = timeInfo.split("-")[0];
                const reservationData = docSnapshot.data();
                const reservationStartTime = new Date(
                  formattedDate + "T" + startTime + ":00Z"
                );
                if (
                  reservationStartTime.getTime() <= tenMinutesLater.getTime() &&
                  reservationData.mainStudentId === userData.studentId
                ) {
                  reservationData.tableData.forEach((table) => {
                    const notificationMessage = {
                      message: `${formattedDate} ${startTime}시에 ${roomName}으로 입장해주세요.`,
                    };

                    messaging.sendEach({
                      tokens: userData.fcmToken,
                      message: notificationMessage,
                    });
                  });
                }
              }
            });
          }
        });
      }
    });

    console.log("Scheduled task completed.");
  } catch (error) {
    console.error("Error during scheduled task:", error);
  }
});


export default notify;
