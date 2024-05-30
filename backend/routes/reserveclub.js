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
import cron from "node-cron";

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

const reserveClub = express.Router();

// 관리자가 등록한 예약 가능 공유공간 조회 (메인)
reserveClub.post("/main_lentroom/:uid", async (req, res) => {
  const { uid } = req.body;

  try {
    // 사용자 정보 가져오기
    const userDoc = await getDoc(doc(db, "users", uid));

    if (!userDoc.exists()) {
      return res.status(404).json({ error: "User not found" });
    }
    const userData = userDoc.data();
    const collectionName = `${userData.faculty}_Club`;
    const collectionRef = collection(db, collectionName);
    const existDocSnapShot = await getDocs(collectionRef);
    const share_room_data = [];

    existDocSnapShot.forEach((doc) => {
      const existData = doc.data();
      share_room_data.push({
        roomName: doc.id,
        tableList: existData.tableList,
        time: existData.available_Time,
        people: existData.available_People,
        clubRoomImage: existData.clubRoomImage,
        clubRoomDesignImage: existData.clubRoomDesignImage,
      });
    });

    // 사용자의 예약 정보 반환
    res.status(200).json({
      message: "successfully get lentroom",
      share_room_data: share_room_data,
    });
  } catch (error) {
    // 오류 발생 시 오류 응답
    console.error("no room ", error);
    res.status(500).json({ error: "fail_ no_room" });
  }
});

// 관리자가 등록한 예약 가능 강의실 조회 (메인)
reserveClub.post("/main_conference_room/:uid", async (req, res) => {
  const { uid } = req.body;

  try {
    // 사용자 정보 가져오기
    const userDoc = await getDoc(doc(db, "users", uid));

    if (!userDoc.exists()) {
      return res.status(404).json({ error: "User not found" });
    }
    const userData = userDoc.data();
    const collectionName = `${userData.faculty}_Classroom_queue`;
    const collectionRef = collection(db, collectionName);
    const existDocSnapShot = await getDocs(collectionRef);
    const share_room_data = [];

    existDocSnapShot.forEach((doc) => {
      const existData = doc.data();
      share_room_data.push({
        roomName: doc.id,
        faculty: existData.faculty,
        time: existData.available_Time,
        people: existData.available_People,
        conferenceImage: existData.conferenceImage,
      });
    });

    // 사용자의 예약 정보 반환
    res.status(200).json({
      message: "successfully get lentroom",
      share_room_data: share_room_data,
    });
  } catch (error) {
    // 오류 발생 시 오류 응답
    console.error("no room ", error);
    res.status(500).json({ error: "fail_ no_room" });
  }
});

// 예약하기
reserveClub.post("/", async (req, res) => {
  const { userId, roomName, date, startTime, endTime, tableNumber } = req.body;
  try {
    // 사용자 정보 가져오기
    const userDoc = await getDoc(doc(db, "users", userId));

    if (!userDoc.exists()) {
      return res.status(404).json({ error: "User not found" });
    }
    const userData = userDoc.data();
    const collectionName = `${userData.faculty}_Club`;
    const existDocSnapShot = await getDoc(doc(db, collectionName, roomName));

    if (!existDocSnapShot.exists()) {
      // 해당 문서가 존재하지 않는 경우
      return res.status(404).json({ error: "This Club room does not exist" });
    }
    const facultyClubCollection = collection(db, collectionName);
    const clubRoomDoc = doc(facultyClubCollection, roomName);
    const clubRoomDocSnap = await getDoc(clubRoomDoc);

    // 해당 동아리방이 있는지 확인
    if (!clubRoomDocSnap.exists()) {
      return res.status(404).json({
        error: `${roomName} does not exist in ${collectionName} collection`,
      });
    }

    const dateCollection = collection(clubRoomDoc, date);
    const availableTable = parseInt(clubRoomDocSnap.data().available_Table);

    const startTimeParts = startTime.split(":");
    const startTimeHour = parseInt(startTimeParts[0]);

    const endTimeParts = endTime.split(":");
    const endTimeHour = parseInt(endTimeParts[0]);

    const timeDiff = endTimeHour - startTimeHour;

    if (timeDiff < 1) {
      return res.status(402).json({ error: "Invalid startTime and endTime" });
    }

    for (let i = startTimeHour; i < endTimeHour; i++) {
      const reservationDocRef = doc(dateCollection, `${i}-${i + 1}`);
      const reservationDocSnap = await getDoc(reservationDocRef);

      if (!reservationDocSnap.exists()) {
        // 문서가 존재하지 않을 때 초기화
        const tableData = [];
        for (let j = 1; j <= availableTable; j++) {
          const tableInfo = {
            [`T${j}`]: j === parseInt(tableNumber) ? true : false,
            name: "",
            studentId: "",
            status: "previous",
          };
          if (j === parseInt(tableNumber)) {
            tableInfo.name = userData.name;
            tableInfo.studentId = userData.studentId;
            tableInfo.startTime = startTime;
            tableInfo.endTime = endTime;
          }
          tableData.push(tableInfo);
        }
        await setDoc(reservationDocRef, {
          tableData: tableData,
        });
      } else {
        const reservationData = reservationDocSnap.data();
        const index = parseInt(tableNumber) - 1;
        if (!reservationData.tableData[index]) {
          // 해당 인덱스의 데이터가 존재하지 않으면 초기화
          reservationData.tableData[index] = {};
          for (let j = 1; j <= availableTable; j++) {
            reservationData.tableData[index][`T${j}`] = false;
            reservationData.tableData[index].name = "";
            reservationData.tableData[index].studentId = "";
            reservationData.tableData[index].status = "previous";
          }
        }

        if (reservationData.tableData[index][`T${tableNumber}`] === false) {
          reservationData.tableData[index][`T${tableNumber}`] = true;
          reservationData.tableData[index].name = userData.name;
          reservationData.tableData[index].studentId = userData.studentId;
          reservationData.tableData[index].startTime = startTime;
          reservationData.tableData[index].endTime = endTime;

          await updateDoc(reservationDocRef, {
            tableData: reservationData.tableData,
          });
        }
      }
    }

    res.status(200).json({ message: "Creating reservation club successfully" });
  } catch (error) {
    console.error("Error creating reservation club", error);
    return res.status(500).json({ error: "Failed reservation club" });
  }
});

// 날짜 받았을때 가능 시간대 보여주기
reserveClub.post("/selectdate", async (req, res) => {
  const { userId, roomName, date } = req.body; // 클라이언트로부터 userId, roomName, date를 쿼리 파라미터로 받습니다.

  try {
    // 사용자 정보 가져오기
    const userDoc = await getDoc(doc(db, "users", userId));
    if (!userDoc.exists()) {
      return res.status(404).json({ error: "User not found" });
    }
    const userData = userDoc.data();
    const collectionName = `${userData.faculty}_Club`;
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
    querySnapshot.forEach((doc) => {
      // 각 문서(예약)에서 예약된 시간과 테이블 정보 추출
      const data = doc.data();
      reservations.push({
        timeRange: doc.id, // 문서 ID는 예약 시간대 (예: "9-10")
        tables: data.tableData, // 테이블 예약 데이터
      });
    });

    // 예약된 시간대와 테이블 정보 반환
    res.status(200).json({
      reservations: reservations,
    });
  } catch (error) {
    console.error("Error fetching reservations", error);
    res.status(500).json({ error: "Failed to fetch reservations" });
  }
});

// 사용자별 특정 시작 날짜부터 특정 끝 날짜까지의 예약 내역 반환
reserveClub.get(
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
      const collectionName = `${userData.faculty}_Club`;

      // 사용자 예약 내역
      const userReservations = [];

      // 동아리방 컬렉션 참조
      const facultyClubCollectionRef = collection(db, collectionName);
      const querySnapshot = await getDocs(facultyClubCollectionRef);

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

              if (reservationData && reservationData.tableData) {
                const startTime = docSnapshot.id.split("-")[0];
                const endTime = docSnapshot.id.split("-")[1];

                // 예약된 테이블 정보 조회
                reservationData.tableData.forEach((table) => {
                  if (
                    table.studentId === userData.studentId &&
                    table.status === "previous"
                  ) {
                    userReservations.push({
                      roomName: roomName,
                      date: dateString,
                      startTime: startTime,
                      endTime: endTime,
                      tableData: table,
                    });
                  }
                });
              }
            });
          }
        })
      );

      // 사용자 예약 내역 반환
      res.status(200).json({
        message: "User reservations fetched successfully",
        reservations: userReservations,
      });
    } catch (error) {
      // 오류 발생 시 오류 응답
      console.error("Error fetching user reservations", error);
      res.status(500).json({ error: "Failed to fetch user reservations" });
    }
  }
);

// 사용자별 특정 시작 날짜부터 특정 끝 날짜까지의 예약 내역 반환 (중복 제거)
reserveClub.get(
  "/reservationDone/:userId/:startDate/:endDate",
  async (req, res) => {
    const { userId, startDate, endDate } = req.params;
    const start = new Date(startDate);
    const end = new Date(endDate);

    try {
      const userDoc = await getDoc(doc(db, "users", userId));
      if (!userDoc.exists()) {
        return res.status(404).json({ error: "User not found" });
      }
      const userData = userDoc.data();
      const collectionName = `${userData.faculty}_Club`;
      const userReservations = [];
      const facultyClubCollectionRef = collection(db, collectionName);
      const querySnapshot = await getDocs(facultyClubCollectionRef);

      await Promise.all(
        querySnapshot.docs.map(async (roomDoc) => {
          const roomName = roomDoc.id;
          for (
            let currentDate = new Date(start);
            currentDate <= new Date(end);
            currentDate.setDate(currentDate.getDate() + 1)
          ) {
            const dateString = currentDate.toISOString().split("T")[0];
            const dateCollectionRef = collection(
              db,
              `${collectionName}/${roomName}/${dateString}`
            );

            const timeDocSnapshot = await getDocs(dateCollectionRef);

            timeDocSnapshot.forEach((docSnapshot) => {
              const reservationData = docSnapshot.data();
              if (reservationData && reservationData.tableData) {
                const startTime = docSnapshot.id.split("-")[0];
                const endTime = docSnapshot.id.split("-")[1];
                reservationData.tableData.forEach((table) => {
                  if (
                    table.studentId === userData.studentId &&
                    table.status === "done"
                  ) {
                    userReservations.push({
                      roomName: roomName,
                      date: dateString,
                      startTime: startTime,
                      endTime: endTime,
                      tableData: table,
                    });
                  }
                });
              }
            });
          }
        })
      );

      res.status(200).json({
        message: "User reservations fetched successfully",
        reservations: userReservations,
      });
    } catch (error) {
      console.error("Error fetching user reservations", error);
      res.status(500).json({ error: "Failed to fetch user reservations" });
    }
  }
);

// 동아리방 예약 취소
reserveClub.post("/delete", async (req, res) => {
  let { userId, roomName, date, startTime, endTime, tableNumber } = req.body;

  try {
    const userDoc = await getDoc(doc(db, "users", userId));
    if (!userDoc.exists()) {
      return res.status(404).json({ error: "User not found" });
    }
    const userData = userDoc.data();
    const collectionName = `${userData.faculty}_Club`;
    const existDocSnapShot = await getDoc(doc(db, collectionName, roomName));

    if (!existDocSnapShot.exists()) {
      return res.status(404).json({ error: "This Club room does not exist" });
    }

    const clubRoomDoc = doc(collection(db, collectionName), roomName);
    const clubRoomDocSnap = await getDoc(clubRoomDoc);

    if (!clubRoomDocSnap.exists()) {
      return res.status(404).json({
        error: `${roomName} does not exist in ${collectionName} collection`,
      });
    }

    const dateCollection = collection(clubRoomDoc, date);
    const startTimeParts = startTime.split(":");
    const startTimeHour = parseInt(startTimeParts[0]);
    const endTimeParts = endTime.split(":");
    const endTimeHour = parseInt(endTimeParts[0]);
    tableNumber = tableNumber.replace("T", "");

    for (let i = startTimeHour; i < endTimeHour; i++) {
      const reservationDocRef = doc(dateCollection, `${i}-${i + 1}`);
      const reservationDocSnap = await getDoc(reservationDocRef);

      if (reservationDocSnap.exists()) {
        const reservationData = reservationDocSnap.data();
        const index = parseInt(tableNumber) - 1;

        if (
          reservationData.tableData &&
          reservationData.tableData[index] &&
          reservationData.tableData[index][`T${tableNumber}`]
        ) {
          reservationData.tableData[index][`T${tableNumber}`] = false;
          delete reservationData.tableData[index].name;
          delete reservationData.tableData[index].studentId;
          delete reservationData.tableData[index].status;

          await updateDoc(reservationDocRef, {
            tableData: reservationData.tableData,
          });
        } else {
          console.log("Table data not found or already false");
        }
      } else {
        console.log("Reservation document not found");
      }
    }

    res.status(200).json({ message: "Reservation canceled successfully" });
  } catch (error) {
    console.error("Error canceling reservation", error);
    return res.status(500).json({ error: "Failed to cancel reservation" });
  }
});

// 반납하기
reserveClub.post("/return", async (req, res) => {
  const { userId, roomName, date, startTime, endTime, tableNumber } = req.body;
  try {
    const userDoc = await getDoc(doc(db, "users", userId));

    if (!userDoc.exists()) {
      return res.status(404).json({ error: "User not found" });
    }
    const userData = userDoc.data();
    const collectionName = `${userData.faculty}_Club`;
    const existDocSnapShot = await getDoc(doc(db, collectionName, roomName));

    if (!existDocSnapShot.exists()) {
      return res.status(404).json({ error: "This Club room does not exist" });
    }
    const facultyClubCollection = collection(db, collectionName);
    const clubRoomDoc = doc(facultyClubCollection, roomName);
    const clubRoomDocSnap = await getDoc(clubRoomDoc);

    if (!clubRoomDocSnap.exists()) {
      return res.status(404).json({
        error: `${roomName} does not exist in ${collectionName} collection`,
      });
    }

    const dateCollection = collection(clubRoomDoc, date);
    const startTimeParts = startTime.split(":");
    const startTimeHour = parseInt(startTimeParts[0]);
    const endTimeParts = endTime.split(":");
    const endTimeHour = parseInt(endTimeParts[0]);

    const timeDiff = endTimeHour - startTimeHour;

    if (timeDiff < 1) {
      return res.status(402).json({ error: "Invalid startTime and endTime" });
    }

    for (let i = startTimeHour; i < endTimeHour; i++) {
      const reservationDocRef = doc(dateCollection, `${i}-${i + 1}`);
      const reservationDocSnap = await getDoc(reservationDocRef);
      if (!reservationDocSnap.exists()) {
        return res
          .status(400)
          .json({ error: "The reservation club room does not exist" });
      } else {
        const reservationData = reservationDocSnap.data();
        const index = parseInt(tableNumber) - 1;

        if (reservationData.tableData[index][`T${tableNumber}`] === true) {
          reservationData.tableData[index].status = "done";

          await updateDoc(reservationDocRef, {
            tableData: reservationData.tableData,
          });
        }
      }
    }
    res.status(200).json({
      message: "return club room successfully",
    });
  } catch (error) {
    console.error("Error returning reservation club room", error);
    res.status(500).json({ error: "Failed to return reservation club room" });
  }
});

// 모든 사용자가 반납을 잘했는지 판단
cron.schedule("*/30 * * * *", async () => {
  try {
    const offset = 1000 * 60 * 60 * 9;
    const koreaNow = new Date(new Date().getTime() + offset);
    const formattedDate = koreaNow.toISOString().split("T")[0];
    const koreaNowHourOnly = koreaNow.toISOString().substring(11, 13);

    const userCollectionRef = collection(db, "users");
    const querySnapshot = await getDocs(userCollectionRef);

    querySnapshot.docs.forEach(async (user) => {
      const userData = user.data();
      const facultyRef = collection(db, `${userData.faculty}_Club`);
      const roomSnapshot = await getDocs(facultyRef);

      if (!roomSnapshot.empty) {
        roomSnapshot.docs.forEach(async (roomDoc) => {
          const roomName = roomDoc.id;
          const dateCollectionRef = collection(
            db,
            `${userData.faculty}_Club/${roomName}/${formattedDate}`
          );

          const timeDocSnapshot = await getDocs(dateCollectionRef);

          if (!timeDocSnapshot.empty) {
            timeDocSnapshot.docs.forEach(async (docSnapshot) => {
              const timeInfo = docSnapshot.id;
              if (docSnapshot.exists()) {
                const reservationData = docSnapshot.data();

                for (let i = 0; i < reservationData.tableData.length; i++) {
                  const table = reservationData.tableData[i];
                  if (table.endTime) {
                    const endTimeConfirm = table.endTime.split(":")[0];
                    if (
                      parseInt(endTimeConfirm) <= parseInt(koreaNowHourOnly) &&
                      table.status === "previous" &&
                      table.studentId === userData.studentId
                    ) {
                      table[`T${i + 1}`] = false;
                      table.name = "";
                      table.studentId = "";
                      table.status = "previous";
                      delete table.startTime;
                      delete table.endTime;
                      await updateDoc(doc(dateCollectionRef, timeInfo), {
                        tableData: reservationData.tableData,
                      });

                      userData.penalty += 0.5;

                      await updateDoc(doc(userCollectionRef, user.id), userData);
                    }
                  }
                }
              }
            });
          }
        });
      }
    });

    console.log("Check penalty successfully");
  } catch (error) {
    console.error("Error checking penalty", error);
  }
});

export default reserveClub;
