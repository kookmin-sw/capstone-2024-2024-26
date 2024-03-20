import {
  addDoc,
  collection,
  getFirestore,
  getDoc,
  doc,
  getDocs,
  where
} from "firebase/firestore";
import { initializeApp } from "firebase/app";
import express from "express";

const firebaseConfig = {
  apiKey: "AIzaSyAocxBUBdG8MuMl7Z7owoX6S6PXax8vYZQ",
  authDomain: "capstone-c2358.firebaseapp.com",
  projectId: "capstone-c2358",
  storageBucket: "capstone-c2358.appspot.com",
  messagingSenderId: "452182758120",
  appId: "1:452182758120:web:30f72007059d6fdf4c6f5d",
  measurementId: "G-ST9TF7PNY3",
};

const app = initializeApp(firebaseConfig);
const db = getFirestore(app);

const reserveClub = express.Router();

// 동아리방 예약
reserveClub.post("/", async (req, res) => {
  const {
    userId,
    roomId,
    date,
    startTime,
    endTime,
    numberOfPeople,
    tableNumber,
  } = req.body;

  try {
    // 사용자 정보 가져오기
    const userDoc = await getDoc(doc(db, "users", userId));
    if (!userDoc.exists()) {
      return res.status(404).json({ error: "User not found" });
    }
    const userData = userDoc.data();

    // 예약된 시간대와 좌석 확인
    const existingReservations = await getDocs(
      collection(db, "reservationClub"),
      where("roomId", "==", roomId),
      where("date", "==", date),
      where("tableNumber", "==", tableNumber),
      where("startTime", "<", endTime),
      where("endTime", ">", startTime)
    );

    // 예약이 되어있으면 오류 반환
    if (!existingReservations.empty) {
      return res
        .status(400)
        .json({ error: "The room is already reserved for this time" });
    }

    // 추가적인 예약 정보 저장
    // 동아리방 예약 정보를 데이터베이스에 저장
    await addDoc(collection(db, "reservationClub"),{
      userId: userId,
      userName: userData.name,
      userClub: userData.club,
      roomId: roomId,
      date: date,
      startTime: startTime,
      endTime: endTime,
      numberOfPeople: numberOfPeople,
      tableNumber: tableNumber,
    });

    // 예약 성공 시 응답
    res.status(201).json({ message: "Reservation club created successfully" });
  } catch (error) {
    // 오류 발생 시 오류 응답
    console.error("Error creating reservation club", error);
    res.status(500).json({ error: "Failed reservation club" });
  }
});

// // 사용자별 동아리방 예약 내역 조회
// router.get("/reservations/:userId", async(req, res) =>{
//     const userId = req.params.userId;

//     try{
//         // 사용자의 모든 예약 내역 가져오기
//         const userReservationsSnapshot = await firebase
//         .firestore()
//         .collection("reservations")
//         .where("userId", "==", userId)
//         .get();

//         if(userReservations.empty){
//             return res.status(404).json({ message: "No reservations found"});
//         }

//         // 예약 내역 반환
//         const userReservations = [];
//         userReservationsSnapshot.foreEach((doc) => {
//             const reservation = doc.data();
//             userReservations.push({
//                 id: doc.id, // 예약 문서 ID
//                 roomId: reservation.roomId,
//                 numberOfPeople: reservation.numberOfPeople,
//                 date: reservation.date,
//                 startTime: reservation.startTime,
//                 endTime: reservation.endTime,
//                 tableNumber: reservation.tableNumber,
//             });
//         });

//         // 사용자의 예약 정보 반환
//         res.status(200).json(userReservations);
//     } catch(error) {
//         // 오류 발생 시 오류 응답
//         console.error("Error fetching user reservations", error);
//         res.status(500).json({ error: "Failed to fetch user reservations"});
//     }
// });

export default reserveClub;
