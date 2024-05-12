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

// 강의실 예약 승인
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

    const existDocSnapShot = await getDoc(doc(db, collectionName, roomName));

    if (!existDocSnapShot.exists()) {
      // 해당 문서가 존재하지 않는 경우
      return res.status(404).json({ error: "This Classroom does not exists" });
    }
    const facultyConferenceCollectionQueue = collection(db, collectionName);

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

    const dateCollectionQueue = collection(
      db,
      `${collectionName}/${roomName}/${date}`
    );

    const startTimeParts = startTime.split(":");
    const startTimeHour = parseInt(startTimeParts[0]);

    const endTimeParts = endTime.split(":");
    const endTimeHour = parseInt(endTimeParts[0]);

    const timeDiff = endTimeHour - startTimeHour;

    if (timeDiff < 1) {
      return res.status(402).json({ error: "Unvaild startTime and endTime" });
    }

    const data = [];

    await setDoc(doc(db, `${userData.faculty}_Classroom`, roomName), {});

    const roomDocRef = doc(db, `${userData.faculty}_Classroom`, roomName);

    const dateCollection = collection(roomDocRef, date);

    for (let i = startTimeHour; i < endTimeHour; i++) {
      const reservationDocRefQueue = doc(dateCollectionQueue, `${i}-${i + 1}`);

      const reservationDocRef = doc(dateCollection, `${i}-${i + 1}`);

      const reservationDocSnap = await getDoc(reservationDocRefQueue);
      if (reservationDocSnap.exists()) {
        const reservationData = reservationDocSnap.data();
        // boolAgree 필드가 false이면 값을 true로 업데이트
        if (!reservationData.boolAgree) {
          await updateDoc(reservationDocRefQueue, { boolAgree: true });

          const reservationDocSnapLast = await getDoc(reservationDocRefQueue);
          const reservationDataLast = reservationDocSnapLast.data();
          data.push(reservationDataLast);

          // 해당 시간대의 데이터를 컬렉션에 저장
          
          await setDoc(reservationDocRef, reservationDataLast);
        }
      }
    }
    console.log(data);
    res
      .status(200)
      .json({ message: "Agree Conference reservation successfully" });
  } catch (error) {
    console.error("Error Agreeing Conference:", error);
    res.status(500).json({ error: "Failed to agree Conference" });
  }
});

// 사용자별 특정 시작 날짜부터 특정 끝 날짜까지의 강의실 예약 내역 조회
adminRoom.get(
  "/reservations/:faculty/:startDate/:endDate",
  async (req, res) => {
    const faculty = req.params.faculty;
    const startDate = new Date(req.params.startDate);
    const endDate = new Date(req.params.endDate);

    try {
      // 컬렉션 이름 설정
      const collectionName = `${faculty}_Classroom`;

      // 강의실 컬렉션 참조
      const facultyConferenceCollectionRef = collection(db, collectionName);

      // 강의실 이름의 문서 가져오기
      const docSnapshot = await getDocs(facultyConferenceCollectionRef);

      console.log(docSnapshot);

      docSnapshot.docs.forEach((doc) => {
        const roomName = doc.id;
        console.log(roomName);
      });

      // 사용자 예약 내역 반환
      res.status(200).json({
        message: "User reservations fetched successfully",
        // reservations: reservations,
      });
    } catch (error) {
      // 오류 발생 시 오류 응답
      console.error("Error fetching user reservations", error);
      res.status(500).json({ error: "Failed to fetch user reservations" });
    }
  }
);

// 강의실 정보 불러오기
adminRoom.get("/conferenceInfo/:faculty", isAdmin, async (req, res) => {
  const faculty = req.params.faculty;

  try {
    // 컬렉션 이름 설정
    const collectionName = `${faculty}_Classroom_queue`;

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

// 강의실 예약
adminRoom.post("/reserve", isAdmin, async (req, res) => {
  const {
    userId,
    roomName,
    date,
    startTime,
    endTime,
    usingPurpose,
    studentIds, // studentIds 리스트 형태로!(대표자 학번 뺴고)
    numberOfPeople,
  } = req.body;
  try {
    // 사용자 정보 가져오기
    const userDoc = await getDoc(doc(db, "users", userId));

    if (!userDoc.exists()) {
      return res.status(404).json({ error: "User not found" });
    }
    const userData = userDoc.data();

    const collectionName = `${userData.faculty}_Classroom`;

    const facultyConferenceCollection = collection(db, collectionName);
    const conferenceRoomDoc = doc(facultyConferenceCollection, roomName);

    const dateCollection = collection(conferenceRoomDoc, date);

    const startTimeParts = startTime.split(":");
    const startTimeHour = parseInt(startTimeParts[0]);

    const endTimeParts = endTime.split(":");
    const endTimeHour = parseInt(endTimeParts[0]);

    const timeDiff = endTimeHour - startTimeHour;

    if (timeDiff < 1) {
      return res.status(402).json({ error: "Unvaild startTime and endTime" });
    }

    for (let i = startTimeHour; i < endTimeHour; i++) {
      const reservationDocRef = doc(dateCollection, `${i}-${i + 1}`);
      const reservationDocSnap = await getDoc(reservationDocRef);

      if (reservationDocSnap.exists()) {
        return res.status(400).json({
          error: `This Conference ${roomName} room  is already reserved from ${i}-${
            i + 1
          }`,
        });
      }
    }

    for (let i = startTimeHour; i < endTimeHour; i++) {
      const reservationDocRef = doc(dateCollection, `${i}-${i + 1}`);
      const reservationDocSnap = await getDoc(reservationDocRef);
      if (!reservationDocSnap.exists()) {
        if (studentIds.length !== parseInt(numberOfPeople) - 1) {
          return res.status(401).json({
            error: "The number of people does not match number of students",
          });
        } else {
          // 각 학생의 이름과 전공을 저장할 배열
          const studentNames = [];
          const studentDepartments = [];
          for (const studentId of studentIds) {
            const collectionRef = collection(db, "users");
            const userDoc = query(
              collectionRef,
              where("studentId", "==", studentId)
            );

            const userDocSnapshot = await getDocs(userDoc);
            if (!userDocSnapshot.empty) {
              const userData = userDocSnapshot.docs[0].data();
              const studentName = userData.name;
              const studentDepartment = userData.department;

              // 배열에 학생의 이름과 전공 추가
              studentNames.push(studentName);
              studentDepartments.push(studentDepartment);
            }
          }

          await setDoc(reservationDocRef, {
            mainName: userData.name, // 누가 대표로 예약을 했는지(책임 문제)
            mainFaculty: userData.faculty, // 대표자 소속
            mainStudentId: userData.studentId, // 대표자 학번
            mainPhoneNumber: userData.phone, // 대표자 전화번호
            mainEmail: userData.email, // 대표자 이메일
            studentName: studentNames,
            studentId: studentIds,
            studentDepartment: studentDepartments,
            usingPurpose: usingPurpose,
            boolAgree: true,
          });
        }
      }
    }

    // 예약 성공 시 응답
    res.status(201).json({
      message: "Administrator reservation Conference created successfully",
    });
  } catch (error) {
    // 오류 발생 시 오류 응답
    console.error("Error administrator reserve conference room", error);
    res
      .status(500)
      .json({ error: "Failed to administrator reserve conference room" });
  }
});

// 강의실 예약 내역 삭제
adminRoom.delete("/delete", isAdmin, async (req, res) => {
  const { userId, roomName, date, startTime, endTime } = req.body;

  try {
    // 사용자 정보 가져오기
    const userDoc = await getDoc(doc(db, "users", userId));

    if (!userDoc.exists()) {
      return res.status(404).json({ error: "User not found" });
    }
    const userData = userDoc.data();

    const collectionName = `${userData.faculty}_Classroom`;

    const conferenceRoomCollection = collection(db, collectionName);
    const roomDocRef = doc(conferenceRoomCollection, roomName);

    const dateCollection = collection(roomDocRef, date);

    // 예약 시간대 확인
    const startTimeParts = startTime.split(":");
    const startTimeHour = parseInt(startTimeParts[0]);

    const endTimeParts = endTime.split(":");
    const endTimeHour = parseInt(endTimeParts[0]);

    // 예약 내역 삭제
    for (let i = startTimeHour; i < endTimeHour; i++) {
      const reservationDocRef = doc(dateCollection, `${i}-${i + 1}`);
      await deleteDoc(reservationDocRef);
    }

    // 삭제 성공 시 응답
    res.status(200).json({ message: "Reservation deleted successfully" });
  } catch (error) {
    // 오류 발생 시 오류 응답
    console.error("Error deleting reservation", error);
    res.status(500).json({ error: "Failed to delete reservation" });
  }
});
export default adminRoom;
