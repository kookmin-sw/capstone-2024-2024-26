import express from "express";
import { initializeApp } from "firebase-admin/app";
import admin from "firebase-admin";
import dotenv from "dotenv";

dotenv.config();

const serviceAccount = {
  type: process.env.TYPE,
  project_id: process.env.PROJECT_ID,
  private_key_id: process.env.PRIVATE_KEY_ID,
  private_key: process.env.PRIVATE_KEY,
  client_email: process.env.CLIENT_EMAIL,
  client_id: process.env.CLIENT_ID,
  auth_uri: process.env.AUTH_URI,
  token_uri: process.env.TOKEN_URI,
  auth_provider_x509_cert_url: process.env.AUTH_PROVIDER_X509_CERT_URL,
  client_x509_cert_url: process.env.CLIENT_X509_CERT_URL,
  universe_domain: process.env.UNIVERSE_DOMAIN,
};

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

const db = admin.firestore();
const messaging = admin.messaging();

const adminNotify = express.Router();

// // 관리자 권한 확인 미들웨어
// function isAdmin(req, res, next) {
//   const { email } = req.body;
//   const adminEmail = "react@kookmin.ac.kr"; // 관리자 이메일

//   if (email === adminEmail) {
//     next(); // 관리자인 경우 다음 미들웨어로 진행
//   } else {
//     res.status(403).json({ error: "Unauthorized: You are not an admin " }); // 관리자가 아닌 경우 권한 없음 응답
//   }
// }

// 모든 사용자에게 알림 보내기
adminNotify.post("/sendNotificationToAllUsers", async (req, res) => {
  const { title, body } = req.body;
  try {
    // Firestore의 users 컬렉션에서 모든 사용자의 FCM 토큰 가져오기
    const usersCollectionRef = db.collection("users");
    const querySnapshot = await usersCollectionRef.get();

    const userTokens = [];

    querySnapshot.forEach((doc) => {
      const userData = doc.data();
      if (userData.fcmToken) {
        userTokens.push(userData.fcmToken);
        const offset = 1000 * 60 * 60 * 9;
        const koreaNow = new Date(new Date().getTime() + offset);
        const formattedDate = koreaNow.toISOString().split("T")[0];

        // 알림 컬렉션에 알림 추가
        const tokenCollectionRef = db
          .collection("notifications")
          .doc(userData.fcmToken)
          .collection(formattedDate);
        tokenCollectionRef.add({
          title: title,
          body: body,
          timestamp: koreaNow,
        });
      }
    });

    // 알림 메시지 생성
    const notificationMessage = {
      title: title,
      body: body,
    };

    // 모든 사용자에게 알림 보내기
    const response = await messaging.sendEachForMulticast({
      tokens: userTokens,
      notification: notificationMessage,
    });

    res.status(200).json({
      message: "Notification sent to all users successfully",
      response,
    });
  } catch (error) {
    console.error("Error sending notification to all users:", error);
    res.status(500).json({ error: "Error sending notification to all users" });
  }
});

// 개별 사용자에게 알림 보내기
adminNotify.post("/sendNotificationToUser", async (req, res) => {
  const { studentId, title, body } = req.body;
  try {
    // Firestore에서 사용자 정보 가져오기
    const userQuery = db
      .collection("users")
      .where("studentId", "==", studentId);
    const userSnapshot = await userQuery.get();
    if (userSnapshot.empty) {
      return res.status(404).json({ error: "User not found" });
    }

    const userData = userSnapshot.docs[0].data();
    if (!userData.fcmToken) {
      return res
        .status(400)
        .json({ error: "FCM token not found for the user" });
    }

    const userTokens = [];

    if (userData.fcmToken) {
      userTokens.push(userData.fcmToken);
      const offset = 1000 * 60 * 60 * 9;
      const koreaNow = new Date(new Date().getTime() + offset);
      const formattedDate = koreaNow.toISOString().split("T")[0];
      const formattedDateString = koreaNow.toISOString();

      // 알림 컬렉션에 알림 추가
      const tokenCollectionRef = db
        .collection("notifications")
        .doc(userData.fcmToken)
        .collection(formattedDate);
      tokenCollectionRef.add({
        title: title,
        body: body,
        timestamp: formattedDateString,
      });
    }

    // 알림 메시지 생성
    const notificationMessage = {
      notification: {
        title: title,
        body: body,
      },
    };

    // 개별 사용자에게 알림 보내기
    const response = await messaging.sendEach([
      {
        token: userData.fcmToken,
        message: notificationMessage,
      },
    ]);

    res.status(200).json({
      message: "Notification sent to the user successfully",
      response,
    });
  } catch (error) {
    console.error("Error sending notification to the user:", error);
    res.status(500).json({ error: "Error sending notification to the user" });
  }
});

export default adminNotify;
