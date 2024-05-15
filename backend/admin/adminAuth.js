import {
  getAuth,
  createUserWithEmailAndPassword,
  deleteUser,
  fetchSignInMethodsForEmail,
  signInWithEmailAndPassword,
} from "firebase/auth";
import {
  setDoc,
  getFirestore,
  doc,
  deleteDoc,
  getDoc,
  getDocs,
  query,
  collection,
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

const auth = getAuth(app);
const adminAuth = express.Router();

function isAdmin(req, res, next) {
  const { email } = req.body;
  // 관리자 이메일
  const adminEmail = "react@kookmin.ac.kr";

  // 이메일이 관리자 이메일과 일치하는지 확인
  if (email === adminEmail) {
    // 관리자인 경우 다음 미들웨어로 진행
    next();
  } else {
    // 관리자가 아닌 경우 권한 없음 응답
    res.status(403).json({ error: "Unauthorized: You are not an admin " });
  }
}

// 로그인
adminAuth.post("/signin", isAdmin, async (req, res) => {
  const { email, password } = req.body;

  try {
    // Firebase를 이용하여 이메일과 비밀번호로 로그인
    const userCredential = await signInWithEmailAndPassword(
      auth,
      email,
      password
    );
    const user = userCredential.user;

    // 로그인 성공 시 사용자 정보 반환
    res.status(200).json({
      message: "Signin successful",
      uid: user.uid,
      email: user.email,
      token: "true",
    });
  } catch (error) {
    // 로그인 실패 시 오류 응답
    console.error("Error signing in", error);
    res.status(401).json({ error: "Signin failed" });
  }
});

// 관리자 모든 사용자 프로필 조회
adminAuth.get("/profile", isAdmin, async (req, res) => {
  try {
    const allUserDocs = await getDocs(query(collection(db, "users")));

    const allUserData = [];

    allUserDocs.forEach((doc) => {
      allUserData.push(doc.data());
    });
    res
      .status(200)
      .json({ message: "All User checking success", allUserData: allUserData });
  } catch (error) {
    // 오류 발생 시 오류 응답
    console.error("Error fetching all profile", error);
    res.status(500).json({ error: "Failed to fetch all profile" });
  }
});

adminAuth.get('/login-data', async (req, res) => {
  const docRef = doc(db, "login", "count");
  const docSnap = await getDoc(docRef);

  if (!docSnap.exists()) {
    return res.status(404).send({ error: 'No login data available.' });
  }

  const data = docSnap.data();
  const today = new Date();
  const result = {};

  for (let i = 0; i < 7; i++) {
    const dateString = today.toISOString().split('T')[0];
    result[dateString] = data[dateString] || 0;
    today.setDate(today.getDate() - 1);
  }

  res.json(result);
});
export default adminAuth;
