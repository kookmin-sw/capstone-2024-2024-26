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
import fs from "fs";
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

const reserveroom = express.Router();

// 강의실 예약
reserveroom.post("/", async (req, res) => {
  const {
    userId,
    roomName,
    date,
    startTime,
    endTime,
    usingPurpose,
    studentId,
    participants,
    numberOfPeople,
    signature,
  } = req.body;

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
    const facultyConferenceCollection = collection(db, collectionName);
    const conferenceRoomDoc = doc(facultyConferenceCollection, roomName);
    const conferenceRoomDocSnap = await getDoc(conferenceRoomDoc);

    // 해당 강의실이 있는지 확인
    if (!conferenceRoomDocSnap.exists()) {
      return res.status(404).json({
        error: `${roomName} does not exist in ${collectionName} collection`,
      });
    }
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
        const participantArray = JSON.parse(participants);

        if (participantArray.length !== parseInt(numberOfPeople) - 1) {
          return res.status(401).json({
            error: "The number of people does not match number of students",
          });
        } else {
          await setDoc(reservationDocRef, {
            roomName: roomName,
            date: date,
            startTime: startTime,
            endTime: endTime,
            mainName: userData.name, // 누가 대표로 예약을 했는지(책임 문제)
            mainFaculty: userData.faculty, // 대표자 소속
            mainStudentId: studentId, // 대표자 학번
            mainPhoneNumber: userData.phone, // 대표자 전화번호
            mainEmail: userData.email, // 대표자 이메일
            participants: participants,
            numberOfPeople: numberOfPeople,
            usingPurpose: usingPurpose,
            boolAgree: false,
            signature: signature,
          });
        }
      }
    }

    // 예약 성공 시 응답
    res
      .status(201)
      .json({ message: "Reservation Conference created successfully" });
  } catch (error) {
    // 오류 발생 시 오류 응답
    console.error("Error reserve conference room", error);
    res.status(500).json({ error: "Failed to reserve conference room" });
  }
});


// 날짜 받았을때 가능 시간대 보여주기 
reserveroom.post('/selectdate', async (req, res) => {
  const { userId, roomName, date } = req.body; // 클라이언트로부터 userId, roomName, date를 쿼리 파라미터로 받습니다.

 
  try {
      // 사용자 정보 가져오기
      const userDoc = await getDoc(doc(db, "users", userId));
      if (!userDoc.exists()) {
          return res.status(404).json({ error: "User not found" });
      }
      const userData = userDoc.data();

      const collectionName = `${userData.faculty}_Classroom`;
      const clubRoomDoc = doc(db, collectionName, roomName);

      // 해당 동아리방 정보 조회
      const clubRoomDocSnap = await getDoc(clubRoomDoc);
      if (!clubRoomDocSnap.exists()) {
          return res.status(404).json({ error: "Club room does not exist" });
      }

      // 해당 날짜에 대한 예약 컬렉션 참조
      const dateCollection = collection(clubRoomDoc, date);
      const querySnapshot = await getDocs(dateCollection);
      
      const reservations = [];
      querySnapshot.forEach(doc => {
          // 각 문서(예약)에서 예약된 시간추출
          const data = doc.data();
          reservations.push({
              timeRange: doc.id, // 문서 ID는 예약 시간대 (예: "9-10")
              
          });
      });

      // 예약된 시간대 반환
      res.status(200).json({
          
          reservations: reservations
      });

  } catch (error) {
      console.error("Error fetching reservations", error);
      res.status(500).json({ error: "Failed to fetch reservations" });
  }
});



// 사용자별 강의실 예약 내역 조회
reserveroom.get(
  "/reservationPrevious/:userId/:startDate/:endDate",
  async (req, res) => {
    const userId = req.params.userId;
    const startDate = new Date(req.params.startDate);
    const endDate = new Date(req.params.endDate);

    try {
      // 사용자 정보 가져오기
      const userDoc = await getDoc(doc(db, "users", userId));

      if (!userDoc.exists()) {
        return res.status(404).json({ error: "User not found" });
      }
      const userData = userDoc.data();

      // 컬렉션 이름 설정
      // 승인 전
      const collectionName = `${userData.faculty}_Classroom_queue`;

      // 승인 후
      const collectionName1 = `${userData.faculty}_Classroom`;

      // 사용자 예약 내역(승인 전)
      const userReservations = [];

      // 사용자 예약 내역(승인 후)
      const userReservations1Previous = [];

      const userReservations1Done = [];

      // 강의실 컬렉션 참조
      const facultyConferenceCollectionRef = collection(db, collectionName);
      const facultyConferenceCollectionRef1 = collection(db, collectionName1);

      const querySnapshot = await getDocs(facultyConferenceCollectionRef);
      const querySnapshot1 = await getDocs(facultyConferenceCollectionRef1);

      // 비동기 처리를 위해 Promise.all 사용
      // 승인 전
      await Promise.all(
        querySnapshot.docs.map(async (roomDoc) => {
          const roomName = roomDoc.id;

          // 사용한 예약 내역 및 이용 예정 내역
          for (
            const currentDate = new Date(startDate);
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
              if (
                reservationData &&
                reservationData.mainStudentId == userData.studentId
              ) {
                const startTime = docSnapshot.id.split("-")[0];
                const endTime = docSnapshot.id.split("-")[1];

                // 예약된 문서 정보 조회
                userReservations.push({
                  roomName: reservationData.roomName,
                  date: reservationData.date,
                  startTime: startTime,
                  endTime: endTime,
                  status: "previous",
                  boolAgree: reservationData.boolAgree,
                });
              }
            });
          }
        })
      );

      // 승인 후
      await Promise.all(
        querySnapshot1.docs.map(async (roomDoc) => {
          const roomName = roomDoc.id;

          // 사용한 예약 내역 및 이용 예정 내역
          for (
            const currentDate = new Date(startDate);
            currentDate <= new Date(endDate);
            currentDate.setDate(currentDate.getDate() + 1)
          ) {
            const dateString = currentDate.toISOString().split("T")[0]; // yyyy-mm-dd 형식의 문자열로 변환
            const dateCollectionRef = collection(
              db,
              `${collectionName1}/${roomName}/${dateString}`
            ); // 컬렉션 참조 생성

            // 해당 날짜별 시간 대 예약 내역 조회
            const timeDocSnapshot = await getDocs(dateCollectionRef);

            timeDocSnapshot.forEach((docSnapshot) => {
              const reservationData = docSnapshot.data();
              if (
                reservationData &&
                reservationData.mainStudentId == userData.studentId
              ) {
                const startTime = docSnapshot.id.split("-")[0];
                const endTime = docSnapshot.id.split("-")[1];

                if (reservationData.status === "previous") {
                  userReservations1Previous.push({
                    roomName: reservationData.roomName,
                    date: reservationData.date,
                    startTime: startTime,
                    endTime: endTime,
                    status: reservationData.status,
                    boolAgree: reservationData.boolAgree,
                  });
                } else {
                  userReservations1Done.push({
                    roomName: reservationData.roomName,
                    date: reservationData.date,
                    startTime: startTime,
                    endTime: endTime,
                    status: reservationData.status,
                    boolAgree: reservationData.boolAgree,
                  });
                }
              }
            });
          }
        })
      );

      // 배열 합치기
      const combinedReservations = userReservations.concat(
        userReservations1Previous
      );

      // 사용자 예약 내역 반환
      res.status(200).json({
        message: "User reservations fetched successfully",
        previousReservation: combinedReservations, // 관리자 승인 전 예약 내역
      });
    } catch (error) {
      // 오류 발생 시 오류 응답
      console.error("Error fetching user reservations", error);
      res.status(500).json({ error: "Failed to fetch user reservations" });
    }
  }
);


// 사용자별 강의실 예약 내역 조회
reserveroom.get(
  "/reservationsDone/:userId/:startDate/:endDate",
  async (req, res) => {
    const userId = req.params.userId;
    const startDate = new Date(req.params.startDate);
    const endDate = new Date(req.params.endDate);

    try {
      // 사용자 정보 가져오기
      const userDoc = await getDoc(doc(db, "users", userId));

      if (!userDoc.exists()) {
        return res.status(404).json({ error: "User not found" });
      }
      const userData = userDoc.data();

      // 컬렉션 이름 설정
      // 승인 전
      const collectionName = `${userData.faculty}_Classroom_queue`;

      // 승인 후
      const collectionName1 = `${userData.faculty}_Classroom`;

      // 사용자 예약 내역(승인 전)
      const userReservations = [];

      // 사용자 예약 내역(승인 후)
      const userReservations1Previous = [];

      const userReservations1Done = [];

      // 강의실 컬렉션 참조
      const facultyConferenceCollectionRef = collection(db, collectionName);
      const facultyConferenceCollectionRef1 = collection(db, collectionName1);

      const querySnapshot = await getDocs(facultyConferenceCollectionRef);
      const querySnapshot1 = await getDocs(facultyConferenceCollectionRef1);

      // 비동기 처리를 위해 Promise.all 사용
      // 승인 전
      await Promise.all(
        querySnapshot.docs.map(async (roomDoc) => {
          const roomName = roomDoc.id;

          // 사용한 예약 내역 및 이용 예정 내역
          for (
            const currentDate = new Date(startDate);
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
              if (
                reservationData &&
                reservationData.mainStudentId == userData.studentId
              ) {
                const startTime = docSnapshot.id.split("-")[0];
                const endTime = docSnapshot.id.split("-")[1];

                // 예약된 문서 정보 조회
                userReservations.push({
                  roomName: reservationData.roomName,
                  date: reservationData.date,
                  startTime: startTime,
                  endTime: endTime,
                  status: "previous",
                  boolAgree: reservationData.boolAgree,
                });
              }
            });
          }
        })
      );

      // 승인 후
      await Promise.all(
        querySnapshot1.docs.map(async (roomDoc) => {
          const roomName = roomDoc.id;

          // 사용한 예약 내역 및 이용 예정 내역
          for (
            const currentDate = new Date(startDate);
            currentDate <= new Date(endDate);
            currentDate.setDate(currentDate.getDate() + 1)
          ) {
            const dateString = currentDate.toISOString().split("T")[0]; // yyyy-mm-dd 형식의 문자열로 변환
            const dateCollectionRef = collection(
              db,
              `${collectionName1}/${roomName}/${dateString}`
            ); // 컬렉션 참조 생성

            // 해당 날짜별 시간 대 예약 내역 조회
            const timeDocSnapshot = await getDocs(dateCollectionRef);

            timeDocSnapshot.forEach((docSnapshot) => {
              const reservationData = docSnapshot.data();
              if (
                reservationData &&
                reservationData.mainStudentId == userData.studentId
              ) {
                const startTime = docSnapshot.id.split("-")[0];
                const endTime = docSnapshot.id.split("-")[1];

                if (reservationData.status === "previous") {
                  userReservations1Previous.push({
                    roomName: reservationData.roomName,
                    date: reservationData.date,
                    startTime: startTime,
                    endTime: endTime,
                    status: reservationData.status,
                    boolAgree: reservationData.boolAgree,
                  });
                } else {
                  userReservations1Done.push({
                    roomName: reservationData.roomName,
                    date: reservationData.date,
                    startTime: startTime,
                    endTime: endTime,
                    status: reservationData.status,
                    boolAgree: reservationData.boolAgree,
                  });
                }
              }
            });
          }
        })
      );


      // 사용자 예약 내역 반환
      res.status(200).json({
        message: "User reservations fetched successfully",
        doneReservation: userReservations1Done, // 관리자 승인 후 예약 내역
      });
    } catch (error) {
      // 오류 발생 시 오류 응답
      console.error("Error fetching user reservations", error);
      res.status(500).json({ error: "Failed to fetch user reservations" });
    }
  }
);

// 반납하기
reserveroom.post("/return", async (req, res) => {
  const { userId, roomName, date, startTime, endTime } = req.body;
  try {
    // 사용자 정보 가져오기
    const userDoc = await getDoc(doc(db, "users", userId));

    if (!userDoc.exists()) {
      return res.status(404).json({ error: "User not found" });
    }
    const userData = userDoc.data();

    const collectionName = `${userData.faculty}_Classroom`;

    const existDocSnapShot = await getDoc(doc(db, collectionName, roomName));

    if (!existDocSnapShot.exists()) {
      // 해당 문서가 존재하지 않는 경우
      return res.status(404).json({ error: "This Club room does not exists" });
    }
    const facultyConferenceCollection = collection(db, collectionName);
    const conferenceRoomDoc = doc(facultyConferenceCollection, roomName);
    const conferenceRoomDocSnap = await getDoc(conferenceRoomDoc);

    // 해당 동아리방이 있는지 확인
    if (!conferenceRoomDocSnap.exists()) {
      return res.status(404).json({
        error: `${roomName} does not exist in ${collectionName} collection`,
      });
    }

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
      if (!reservationDocSnap.exists()) {
        return res
          .status(400)
          .json({ error: "The reservation club room does not exist" });
      } else {
        // 해당 시간대의 문서가 존재할 때
        const reservationData = reservationDocSnap.data();

        if (
          reservationData.mainStudentId === userData.studentId &&
          reservationData.status === "previous"
        ) {
          // 해당 테이블에 대해 반납 업데이트
          reservationData.status = "done";

          await updateDoc(reservationDocRef, reservationData);
        }
      }
    }
    res.status(200).json({
      message: "Entrancing conference room successfully",
    });
  } catch (error) {
    console.error("Error entrancing reservation conference room");
    res.status(500).json({ error: "Failed to entrance reservation club room" });
  }
});

// 동아리방 예약 취소
reserveroom.post("/delete", async (req, res) => {
  const { userId, roomName, date, startTime, endTime } = req.body;
  console.log(req.body);
  try {
    // 사용자 정보 가져오기
    const userDoc = await getDoc(doc(db, "users", userId));
   
    if (!userDoc.exists()) {
      return res.status(404).json({ error: "User not found" });
    }
    const userData = userDoc.data();
    const collectionName = `${userData.faculty}_Classroom_queue`;

    const collectionName1 = `${userData.faculty}_Classroom`;

    const existDocSnapShot = await getDoc(doc(db, collectionName, roomName));

    const existDocSnapShot1 = await getDoc(doc(db, collectionName1, roomName));

    if (!existDocSnapShot.exists()) {
      // 해당 문서가 존재하지 않는 경우
      return res.status(404).json({ error: "This Club room does not exist" });
    }

    if (!existDocSnapShot1.exists()) {
      // 해당 문서가 존재하지 않는 경우
      return res.status(404).json({ error: "This Club room does not exist" });
    }

    const clubRoomDoc = doc(collection(db, collectionName), roomName);

    const clubRoomDoc1 = doc(collection(db, collectionName1), roomName);

    const clubRoomDocSnap = await getDoc(clubRoomDoc);

    const clubRoomDocSnap1 = await getDoc(clubRoomDoc1);

    // 해당 동아리방이 있는지 확인
    if (!clubRoomDocSnap.exists()) {
      return res.status(404).json({
        error: `${roomName} does not exist in ${collectionName} collection`,
      });
    }

    if (!clubRoomDocSnap1.exists()) {
      return res.status(404).json({
        error: `${roomName} does not exist in ${collectionName} collection`,
      });
    }

    const dateCollection = collection(clubRoomDoc, date);

    const dateCollection1 = collection(clubRoomDoc1, date);

    const startTimeParts = startTime.split(":");
    const startTimeHour = parseInt(startTimeParts[0]);

    const endTimeParts = endTime.split(":");
    const endTimeHour = parseInt(endTimeParts[0]);

    // 시작 시간부터 종료 시간까지 각 시간대에 대해 예약 문서를 업데이트합니다.
    for (let i = startTimeHour; i < endTimeHour; i++) {
      const reservationDocRef = doc(dateCollection, `${i}-${i + 1}`);
      const reservationDocRef1 = doc(dateCollection1, `${i}-${i + 1}`);

      const reservationDocSnap = await getDoc(reservationDocRef);

      const reservationDocSnap1 = await getDoc(reservationDocRef1);

      // 해당 시간대 예약 문서가 있는지 확인
      if (reservationDocSnap.exists()) {
        await deleteDoc(reservationDocRef);
      } 
      if (reservationDocSnap1.exists()) {
        await deleteDoc(reservationDocRef1);
      } 
    }

    res.status(200).json({ message: "Reservation canceled successfully" });
  } catch (error) {
    console.error("Error canceling reservation", error);
    return res.status(500).json({ error: "Failed to cancel reservation" });
  }
});


export default reserveroom;

