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

const reserveClub = express.Router();

// 관리자가 등록한 예약 가능 공유공간 조회 (메인)
reserveClub.post("/main_lentroom/:uid", async (req, res) => {
  const { uid } = req.body;
  
  try {
    //이 데이터 웹에서 받아와서 디비에 저장해야함 .
    // 사용자 정보 가져오기
  const userDoc = await getDoc(doc(db, "users", uid));

  if (!userDoc.exists()) {
    return res.status(404).json({ error: "User not found" });
  }
  const userData = userDoc.data();

  const collectionName = `${userData.faculty}_Club`;

  const collectionRef = collection(db, collectionName);

  const existDoc = query(collectionRef);

  const existDocSnapShot = await getDocs(existDoc);

  const share_room_data = [];
  
  existDocSnapShot.forEach((doc) => {
    const existData = doc.data();
    share_room_data.push({
      roomName: doc.id,
      
      time: existData.available_Time,
      people: existData.available_People,
      clubRoomImage: existData.clubRoomImage,
      clubRoomDesignImage : existData.clubRoomDesignImage,
    });
  });
  

    // 사용자의 예약 정보 반환
    res.status(200).json({
      message: "successfully get lentroom", share_room_data : share_room_data,
      
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

  const existDoc = query(collectionRef);

  const existDocSnapShot = await getDocs(existDoc);

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
      message: "successfully get lentroom", share_room_data : share_room_data,
      
    });
  } catch (error) {
    // 오류 발생 시 오류 응답
    console.error("no room ", error);
    res.status(500).json({ error: "fail_ no_room" });
  }
});

//////////******************* */
// 예약하기 .
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
      return res.status(404).json({ error: "This Club room does not exists"});
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
      return res.status(402).json({ error: "Unvaild startTime and endTime" });
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
            name: '',
            studentId: '',
            status: 'previous'
          };
          if (j === parseInt(tableNumber)) {
            tableInfo.name = userData.name;
            tableInfo.studentId = userData.studentId;
            tableInfo.status = 'previous';
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
          }
        }
    
        if (reservationData.tableData[index][`T${tableNumber}`] === false) {
          reservationData.tableData[index][`T${tableNumber}`] = true;
          reservationData.tableData[index].name = userData.name;
          reservationData.tableData[index].studentId = userData.studentId;
          reservationData.tableData[index].status = 'previous';
    
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
reserveClub.post('/selectdate', async (req, res) => {
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
      querySnapshot.forEach(doc => {
          // 각 문서(예약)에서 예약된 시간과 테이블 정보 추출
          const data = doc.data();
          reservations.push({
              timeRange: doc.id, // 문서 ID는 예약 시간대 (예: "9-10")
              tables: data.tableData // 테이블 예약 데이터
          });
      });

      // 예약된 시간대와 테이블 정보 반환
      res.status(200).json({
          
          reservations: reservations
      });

  } catch (error) {
      console.error("Error fetching reservations", error);
      res.status(500).json({ error: "Failed to fetch reservations" });
  }
});


// 사용자별 특정 시작 날짜부터 특정 끝 날짜까지의 예약 내역 반환
reserveClub.get(
  "/reservationclubs/:userId/:startDate/:endDate",
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
                  if (table.studentId === userData.studentId) {
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

// 동아리방 예약 수정
reserveClub.post("/update/:userId/:reserveclubUID", async (req, res) => {
  const userId = req.params.userId;
  const reserveclubUID = req.params.reserveclubUID;
  const { roomId, date, startTime, endTime, tableNumber } = req.body;

  try {
    // 사용자 정보 가져오기
    const userDoc = await getDoc(doc(db, "users", userId));

    if (!userDoc.exists()) {
      return res.status(404).json({ error: "User not found" });
    }
    const userData = userDoc.data();

    // 컬렉션 이름 설정
    const collectionName = `${userData.faculty}_Club`;

    // Firestore reservationClub에서 해당 예약 문서를 가져옴
    const reserveClubDoc = await getDoc(doc(db, `${collectionName}`, reserveclubUID));
    if (!reserveClubDoc.exists()) {
      // 예약 문서가 존재하지 않는 경우 오류 응답
      return res.status(404).json({ error: "Reservation not found" });
    }

    // 변경된 필드만 업데이트
    const updateFields = {};
    if (roomId) updateFields.roomId = roomId;
    if (date) updateFields.date = date;
    if (startTime) updateFields.startTime = startTime;
    if (endTime) updateFields.endTime = endTime;
    if (tableNumber) updateFields.tableNumber = tableNumber;

    // 겹치는 예약이 있는지 확인
    const existingReservationsSnapshot = await getDocs(
      collection(db, `${collectionName}`),
      where("date", "==", date),
      where("roomId", "==", roomId),
      where("tableNumber", "==", tableNumber),
      where("reserveclubUID", "!=", reserveclubUID) // 현재 예약을 제외하고 조회
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
        const startTimeClub = updateFields.startTime;
        const endTimeClub = updateFields.endTime;

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

    if (overlappingReservation) {
      return res
        .status(400)
        .json({ error: "The room is already reserved for this time" });
    }

    // 겹치는 예약이 없으면 예약 업데이트
    await updateDoc(doc(db, `${collectionName}`, reserveclubUID), updateFields);

    // 업데이트 된 동아리방 예약 정보 반환
    res.status(200).json({ message: "Reservationclub updated successfully" });
  } catch (error) {
    console.error("Error updating reservationclub");
    res.status(500).json({ error: "Failed to update reservationclub" });
  }
});

// 동아리방 예약 취소
reserveClub.delete("/delete/:userId/:reserveclubUID", async(req, res) => {
  const userId = req.params.userId;
  const reserveclubUID = req.params.reserveclubUID;

  try{
    // 사용자 정보 가져오기
    const userDoc = await getDoc(doc(db, "users", userId));

    if (!userDoc.exists()) {
      return res.status(404).json({ error: "User not found" });
    }
    const userData = userDoc.data();

    // 컬렉션 이름 설정
    const collectionName = `${userData.faculty}_Club`;

    // Firestore reservationClub에서 해당 예약 문서를 가져옴
    const reserveClubDoc = await getDoc(doc(db, `${collectionName}`, reserveclubUID));
    if (!reserveClubDoc.exists()) {
      // 예약 문서가 존재하지 않는 경우 오류 응답
      return res.status(404).json({ error: "Reservation not found" });
    }

    // 동아리방 예약 내역 삭제
    await deleteDoc(doc(db, `${collectionName}`, reserveclubUID));

    res.status(200).json({ message: "Reservation club deleted success"})
  } catch(error) {
    console.error("Error deleting reservation club", error);
    res.status(500).json({ error: "Failed to delete reservation club"});
  }
});

export default reserveClub;
