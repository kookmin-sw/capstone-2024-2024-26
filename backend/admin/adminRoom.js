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
import { getStorage, ref, uploadBytes, getDownloadURL } from "firebase/storage";
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
const storage = getStorage(app);

const adminRoom = express.Router();

function isAdmin(req, res, next) {
  const { email } = req.body;
  // 관리자 이메일
  const adminEmail = "react@kookmin.ac.kr";

  console.log(adminEmail);
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

// 강의실 생성 설정
adminRoom.post("/create/room", isAdmin, async (req, res) => {
  const {
    faculty,
    roomName,
    location,
    available_People,
    available_Time,
    conferenceImage,
  } = req.body;

  try {
    // 단과대학 강의실 컬렉션 생성
    const facultyClubCollectionRef = collection(
      db,
      `${faculty}_Classroom_queue`
    );

    // 강의실 위치 문서 생성
    const classRoomDocRef = doc(facultyClubCollectionRef, `${roomName}`);

    // 정보 생성
    const data = {
      faculty: faculty,
      roomName: roomName,
      location: location,
      available_People: available_People,
      available_Time: available_Time,
      conferenceImage: conferenceImage,
    };

    // 강의실 정보 및 이미지 URL 저장
    await setDoc(classRoomDocRef, data);

    res.status(200).json({ message: "Register Classroom successfully" });
  } catch (error) {
    console.error("Error registering Classroom:", error);
    res.status(500).json({ error: "Failed to register Classroom" });
  }
});

adminRoom.post("/agree", isAdmin, async (req, res) => {
  const { userId, roomName, date, startTime, endTime } = req.body;
  try {
    // 사용자 정보 가져오기
    const userDoc = await getDoc(doc(db, "users", userId));

    if (!userDoc.exists()) {
      return res.status(404).json({ error: "User not found" });
    }
    const userData = userDoc.data();

    const collectionName = `${userData.faculty}_Classroom_queue`;

    const collectionNameConference = `${userData.faculty}_Classroom`;

    const existDocSnapShot = await getDoc(doc(db, collectionName, roomName));

    if (!existDocSnapShot.exists()) {
      // 해당 문서가 존재하지 않는 경우
      return res.status(404).json({ error: "This Classroom does not exists" });
    }
    const facultyConferenceCollectionQueue = collection(db, collectionName);
    const facultyConferenceCollcetion = collection(
      db,
      collectionNameConference
    );

    const conferenceRoomDoc = doc(facultyConferenceCollcetion, roomName);
    const conferenceRoomDocQueue = doc(
      facultyConferenceCollectionQueue,
      roomName
    );

    const conferenceRoomDocSnapQueue = await getDoc(conferenceRoomDocQueue);

    // 해당 강의실이 있는지 확인
    if (!conferenceRoomDocSnapQueue.exists()) {
      return res.status(404).json({
        error: `${roomName} does not exist in ${collectionName} collection`,
      });
    }

    const dateCollection = collection(conferenceRoomDoc, date);
    const dateCollectionQueue = collection(conferenceRoomDocQueue, date);

    const startTimeParts = startTime.split(":");
    const startTimeHour = parseInt(startTimeParts[0]);

    const endTimeParts = endTime.split(":");
    const endTimeHour = parseInt(endTimeParts[0]);

    const timeDiff = endTimeHour - startTimeHour;

    if (timeDiff < 1) {
      return res.status(402).json({ error: "Unvaild startTime and endTime" });
    }

    for (let i = startTimeHour; i < endTimeHour; i++) {
      const reservationDocRefQueue = doc(dateCollectionQueue, `${i}-${i + 1}`);
      const reservationDocRef = doc(dateCollection, `${i}-${i + 1}`);

      const reservationDocSnap = await getDoc(reservationDocRefQueue);
      if (reservationDocSnap.exists()) {
        const reservationData = reservationDocSnap.data();
        // boolAgree 필드가 false이면 값을 true로 업데이트
        if (!reservationData.boolAgree) {
          await updateDoc(reservationDocRefQueue, { boolAgree: true });

          const reservationDocDataSnap = await getDoc(reservationDocRefQueue);
          const reservationData = reservationDocDataSnap.data();

          await setDoc(reservationDocRef, reservationData);

          await deleteDoc(reservationDocRefQueue);
        }
      }
    }

    res
      .status(200)
      .json({ message: "Agree Conference reservation successfully" });
  } catch (error) {
    console.error("Error Agreeing Conference:", error);
    res.status(500).json({ error: "Failed to agree Conference" });
  }
});

adminRoom.get(
  "/reservations/:startDate/:endDate",
  isAdmin,
  async (req, res) => {
    const { faculty } = req.body;
    const startDate = new Date(req.params.startDate);
    const endDate = new Date(req.params.endDate);

    try {
      const collectionName = `${faculty}_Classroom`;

      // 각 단과대별 강의실 컬렉션
      const facultyConferenceCollcetion = collection(db, collectionName);

      // 해당 컬렉션의 모든 문서 가져오기
      const querySnapshot = await getDocs(facultyConferenceCollcetion);

      // 모든 문서 데이터를 저장할 배열
      const allDocData = [];

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
              if (reservationData) {
                const startTime = docSnapshot.id.split("-")[0];
                const endTime = docSnapshot.id.split("-")[1];

                // 예약된 문서 정보 조회
                allDocData.push({
                  roomName: roomName,
                  mainName: reservationData.mainName,
                  date: dateString,
                  startTime: startTime,
                  endTime: endTime,
                  studentName: reservationData.studentNames,
                  studentDepartment: reservationData.studentDepartments,
                  studentId: reservationData.studentIds,
                  usingPurpose: reservationData.usingPurpose,
                  boolAgree: reservationData.boolAgree,
                });
              }
            });
          }
        })
      );

      // 사용자 예약 내역 반환
      res.status(200).json({
        message: "Administrator reservations fetched successfully",
        reservations: allDocData,
      });
    } catch (error) {
      // 오류 발생 시 오류 응답
      console.error("Error fetching Administrator reservations", error);
      res
        .status(500)
        .json({ error: "Failed to fetch administrator reservations" });
    }
  }
);

// 강의실 정보 불러오기
adminRoom.get("/conferenceInfo/:userId", isAdmin, async (req, res) => {
  const userId = req.params.userId;

  try {
    // 사용자 정보 가져오기
    const userDoc = await getDoc(doc(db, "users", userId));

    if (!userDoc.exists()) {
      return res.status(404).json({ error: "User not found" });
    }
    const userData = userDoc.data();

    // 컬렉션 이름 설정
    const collectionName = `${userData.faculty}_Classroom_queue`;

    const facultyConferenceCollcetion = collection(db, collectionName);

    const querySnapshot = await getDocs(facultyConferenceCollcetion);

    if (querySnapshot.empty) {
      return res.status(401).json({ error: "Conference Info does not exist" });
    }

    const allConferenceInfo = [];

    querySnapshot.forEach((doc) => {
      const conferenceInfo = doc.data();
      allConferenceInfo.push({
        faculty: conferenceInfo.faculty,
        roomName: conferenceInfo.roomName,
        available_Time: conferenceInfo.available_Time,
        available_People: conferenceInfo.available_People,
        conferenceImage: conferenceInfo.conferenceImage,
      });
    });

    res.status(200).json({
      message: "fetch all conference info successfully",
      allConferenceInfo,
    });
  } catch (error) {
    //오류 발생 시 오류 응답
    console.error("Error fetching conference info", error);
    res.status(500).json({ error: "Failed to fetch conference info" });
  }
});

// 강의실 정보 삭제
adminRoom.delete("/delete/conferenceInfo", isAdmin, async (req, res) => {
  const { faculty, roomName } = req.body;

  try {
    // 컬렉션 이름 설정
    const collectionName = `${faculty}_Classroom_queue`;

    const facultyConferenceCollcetion = collection(db, collectionName);

    const roomDocRef = doc(facultyConferenceCollcetion, roomName);

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

export default adminRoom;
