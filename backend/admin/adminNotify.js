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
  universe_domain: process.env.UNIVERSE_DOMAIN
};

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const db = admin.firestore();
const messaging = admin.messaging();

const adminNotify = express.Router();

// 관리자 권한 확인 미들웨어
function isAdmin(req, res, next) {
  const { email } = req.body;
  const adminEmail = "react@kookmin.ac.kr"; // 관리자 이메일

  if (email === adminEmail) {
    next(); // 관리자인 경우 다음 미들웨어로 진행
  } else {
    res.status(403).json({ error: "Unauthorized: You are not an admin " }); // 관리자가 아닌 경우 권한 없음 응답
  }
}

adminNotify.post("/sendNotificationToAllUsers", isAdmin, async (req, res) => {
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
        const today = new Date();
        const formattedDate = today.toISOString().split("T")[0]; // ISO 포맷에서 'T'를 기준으로 분리하여 날짜 부분만 가져옴

        // 알림 컬렉션에 알림 추가
        const tokenCollectionRef = db
          .collection("notifications")
          .doc(userData.fcmToken)
          .collection(formattedDate);
        tokenCollectionRef.add({
          title: title,
          body: body,
          timestamp: admin.firestore.FieldValue.serverTimestamp(), // 서버 시간으로 타임스탬프 추가
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

export default adminNotify;
