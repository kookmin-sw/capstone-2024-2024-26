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
import mime from "mime-types";
import fs from "fs";
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
  const { faculty, roomName, available_People, available_Time, base64Image } = req.body;

  try {
    // base64 데이터 디코딩
    const base64ImageInfo = base64Image.split(";base64,").pop();
    const buffer = Buffer.from(base64ImageInfo, "base64");

    // 파일 확장자 추출
    const mimeType = mime.lookup(roomName);
    const ext = mime.extension(mimeType);

    // 이미지를 Firebase Storage에 업로드
    const storageRef = ref(
      storage,
      `roomLayouts/${faculty}/${roomName}.${ext}`
    );
    await uploadBytes(storageRef, buffer); // 이미지 업로드

    // Firebase Storage에서 이미지 URL 가져오기
    const imageUrl = await getDownloadURL(storageRef);

    // 단과대학 동아리 컬렉션 생성
    const facultyClubCollectionRef = collection(
      db,
      `${faculty}_Classroom_queue`
    );

    // 동아리방 위치 문서 생성
    const classRoomDocRef = doc(facultyClubCollectionRef, `${roomName}`);

    // 정보 생성
    const data = {
      roomName: `${roomName}`,
      available_People: `${available_People}`,
      available_Time: `${available_Time}`,
      roomLayoutImageUrl: `${imageUrl}`, // 이미지 URL 저장
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
  const { userId, boolAgree, reserveroomUID } = req.body;
  try {
    if (boolAgree === true) {
      // 사용자 정보 가져오기
      const userDoc = await getDoc(doc(db, "users", userId));

      if (!userDoc.exists()) {
        return res.status(404).json({ error: "User not found" });
      }
      const userData = userDoc.data();

      // 컬렉션 이름 설정
      const collectionNameQueue = `${userData.faculty}_Classroom_queue`;

      // 예약 강의실 정보 가져오기
      const reserveroomDoc = await getDoc(
        doc(db, collectionNameQueue, reserveroomUID)
      );

      if (!reserveroomDoc.exists()) {
        return res.status(404).json({ error: "Reservation not found" });
      }

      // 강의실 예약 정보를 등록할 컬렉션 이름 설정
      const classroomCollectionName = `${userData.faculty}_Classroom`;

      // 강의실 예약 정보 등록
      await setDoc(
        doc(db, classroomCollectionName, reserveroomUID),
        reserveroomDoc.data()
      );

      // boolAgree 값을 true로 변경하여 저장
      await updateDoc(doc(db, classroomCollectionName, reserveroomUID), {
        boolAgree: true,
      });

      // Firestore에서 강의실 대기열 예약내역 삭제
      await deleteDoc(doc(db, collectionNameQueue, reserveroomUID));

      res.status(200).json({ message: "Register Classroom successfully" });
    } else {
      res.status(400).json({ error: "Administrator denied your reservation" });
    }
  } catch (error) {
    console.error("Error registering Classroom:", error);
    res.status(500).json({ error: "Failed to register Classroom" });
  }
});

// 관리자 강의실 예약
adminRoom.post("/create", isAdmin, async (req, res) => {
  const {
    userId,
    roomId,
    date,
    startTime,
    endTime,
    usingPurpose,
    studentIds,
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

    // 예약된 시간대와 좌석 확인
    const existingReservationsSnapshot = await getDocs(
      collection(db, `${collectionName}`),
      where("date", "==", date),
      where("roomId", "==", roomId)
    );

    // 겹치는 예약이 있는지 확인
    const overlappingReservation = existingReservationsSnapshot.docs.find(
      (doc) => {
        const reservation = doc.data();
        // 기존 예약의 시작 시간과 끝 시간
        const existingStartTime = reservation.startTime;
        const existingEndTime = reservation.endTime;
        const existingDate = reservation.date;
        const existingRoomId = reservation.roomId;
        const startTimeClub = startTime;
        const endTimeClub = endTime;

        // 예약 시간이 같은 경우 또는 기존 예약과 겹치는 경우 확인
        if (
          (existingDate == date &&
            startTimeClub == existingStartTime &&
            endTimeClub == existingEndTime &&
            roomId == existingRoomId) ||
          (existingDate == date &&
            roomId == existingRoomId &&
            startTimeClub < existingEndTime &&
            endTimeClub > existingStartTime)
        ) {
          return true;
        }
        return false;
      }
    );

    // 겹치는 예약이 있는 경우 에러 반환
    if (overlappingReservation) {
      return res
        .status(401)
        .json({ error: "The room is already reserved for this time" });
    }

    // 학생들의 학번을 공백을 기준으로 분할하여 리스트를 만듦
    const studentIdList = studentIds.split(" ");
    if (studentIdList.length != numberOfPeople) {
      return res.status(400).json({
        error:
          "The numberOfPeople does not match the number of given studentIds",
      });
    }

    // 각 학생의 정보를 가져오는 비동기 함수
    const getUserInfoPromises = studentIdList.map(async (studentId) => {
      const userQuerySnapshot = await getDocs(
        query(collection(db, "users"), where("studentId", "==", studentId))
      );
      if (!userQuerySnapshot.empty) {
        const userData = userQuerySnapshot.docs[0].data();
        return {
          studentId: studentId,
          name: userData.name,
          faculty: userData.faculty,
        };
      } else {
        throw new Error(`User with ID ${studentId} not found`);
      }
    });

    // 비동기 함수들을 병렬로 실행하여 학생 정보를 가져옵니다.
    const studentInfoList = await Promise.all(getUserInfoPromises);

    const existingMyReservationSnapshot = await getDocs(
      query(collection(db, `${collectionName}`), where("roomId", "==", roomId))
    );

    // 문서 컬렉션에 uid로 구분해주기(덮어쓰이지않게 문서 개수에 따라 번호 부여)
    const reservationCount = existingMyReservationSnapshot.size + 1;
    // 겹치는 예약이 없으면 예약 추가
    await setDoc(
      doc(
        db,
        `${collectionName}`,
        `${roomId}_${userData.studentId}_${reservationCount}`
      ),
      {
        mainName: userData.name,
        roomId: roomId,
        date: date,
        startTime: startTime,
        endTime: endTime,
        usingPurpose: usingPurpose,
        numberOfPeople: numberOfPeople,
        studentIds: studentIdList,
        studentNames: studentInfoList.map((student) => student.name),
        studentFaculty: studentInfoList.map((student) => student.faculty),
        boolAgree: true,
      }
    );

    // 예약 성공 시 응답
    res.status(201).json({ message: "Reservation room created successfully" });
  } catch (error) {
    // 오류 발생 시 오류 응답
    console.error("Error creating reservation room", error);
    res.status(500).json({ error: "Failed reservation room" });
  }
});

// 관리자 강의실 예약 내역 삭제
adminRoom.delete(
  "/delete/:userId/:reservationUID",
  isAdmin,
  async (req, res) => {
    const userId = req.params.userId;
    const reservationUID = req.params.reservationUID;

    try {
      // 사용자 정보 가져오기
      const userDoc = await getDoc(doc(db, "users", userId));

      if (!userDoc.exists()) {
        return res.status(404).json({ error: "User not found" });
      }
      const userData = userDoc.data();

      // 컬렉션 이름 설정(예약내역)
      const collectionName = `${userData.faculty}_Classroom`;

      // 컬렉션 이름 설정(대기열)
      const collectionNameQueue = `${userData.faculty}_Classroom_queue`;

      // Firestore에서 강의실 예약내역 삭제
      await deleteDoc(doc(db, `${collectionName}`, reservationUID));

      // Firestore에서 강의실 대기열 예약내역 삭제
      await deleteDoc(doc(db, `${collectionNameQueue}`, reservationUID));

      res
        .status(200)
        .json({ message: "Reservation club deleted successfully" });
    } catch (error) {
      console.log("Error deleting reservation club", error);
      res.status(500).json({ error: "Failed to delete reservation club" });
    }
  }
);

export default adminRoom;