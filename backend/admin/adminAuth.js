import {
  getAuth,
  createUserWithEmailAndPassword,
  deleteUser,
  fetchSignInMethodsForEmail,
  signInWithEmailAndPassword
} from "firebase/auth";
import { setDoc, getFirestore, doc, deleteDoc, getDoc, getDocs, query, collection} from "firebase/firestore";
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
  const email = req.headers.email;  // HTTP 헤더에서 이메일 추출

  const adminEmail = "react@kookmin.ac.kr";
  if (email === adminEmail) {
    next();  // 관리자인 경우 다음 미들웨어로 진행
  } else {
    console.log("Access denied for email:", email);  // 관리자가 아닌 경우 이메일을 콘솔에 로깅
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

adminAuth.delete("/delete/:uid", isAdmin, async (req, res) => {
  try {
    const userId = req.params.uid;

    // Firebase Authentication에서 회원 삭제
    deleteUser(auth, userId)
      .then(() => {})
      .catch((error) => {
        console.error("Error deleting user", error);
      });

    // Firestore에서 회원정보 삭제
    await deleteDoc(doc(db, "users", userId));

    res.status(200).json({ message: "User deleted successfully " });
  } catch (error) {
    console.error("Error deleting user", error);
    res.status(500).json({ error: "Failed to delete user" });
  }
});

adminAuth.post("/create", isAdmin, async (req, res) => {
  const {
    useremail,
    password,
    name,
    studentId,
    faculty,
    department,
    club,
    phone,
    agreeForm,
  } = req.body;

  try {
    // 이미 가입된 이메일인지 확인
    const signInMethods = await fetchSignInMethodsForEmail(auth, useremail);
    if (signInMethods && signInMethods.length > 0) {
      console.error("Email already in use");
      return res.status(400).json({
        error: "Email already in use. Please use a different email address.",
      });
    }

    // Firebase Authentication을 사용하여 사용자 생성
    const userCredential = await createUserWithEmailAndPassword(
      auth,
      useremail,
      password
    );
    const user = userCredential.user;

    // Firestore에 사용자 정보 추가
    await setDoc(doc(db, "users", user.uid), {
      useremail: useremail,
      password: password,
      name: name,
      studentId: studentId,
      faculty: faculty,
      department: department,
      club: club,
      phone: phone,
      agreeForm: agreeForm,
    });

    // 사용자 추가 성공 응답
    res
      .status(201)
      .json({ message: "User added successfully", userId: user.uid });
  } catch (error) {
    // 오류 발생 시 오류 응답
    console.error("Error adding user", error);
    res.status(500).json({ error: "Failed to add user" });
  }
});

// 프로필 수정
adminAuth.post("/profile/update/:uid", isAdmin, async (req, res) => {
  const userId = req.params.uid;
  const {
    password,
    name,
    studentId,
    faculty,
    department,
    club,
    phone,
    agreeForm,
  } = req.body;

  try {
    // Firebase Firestore에서 사용자의 문서를 가져옴
    const userDoc = await getDoc(doc(db, "users", userId));
    if (!userDoc.exists()) {
      // 사용자 문서가 존재하지 않는 경우 오류 응답
      return res.status(404).json({ error: "User not found" });
    }

    // 변경된 필드만 업데이트
    const updateFields = {};
    if (password) updateFields.password = password;
    if (name) updateFields.name = name;
    if (studentId) updateFields.studentId = studentId;
    if (faculty) updateFields.faculty = faculty;
    if (department) updateFields.department = department;
    if (club) updateFields.club = club;
    if (phone) updateFields.phone = phone;
    if (agreeForm) updateFields.agreeForm = agreeForm;

    // 사용자 문서를 업데이트
    await updateDoc(doc(db, "users", userId), updateFields);

    // 업데이트된 사용자 정보 반환
    res.status(200).json({ message: "Profile updated successfully" });
  } catch (error) {
    // 오류 발생 시 오류 응답
    console.error("Error updating profile", error);
    res.status(500).json({ error: "Failed to update profile" });
  }
});

// 관리자 모든 사용자 프로필 조회
adminAuth.get("/profile", isAdmin, async (req, res) => {

  try {
    const allUserDocs = await getDocs(query(collection(db, "users")));

    const allUserData = [];

    allUserDocs.forEach((doc) => {
      allUserData.push(doc.data());
    })
    res
      .status(200)
      .json({ message: "All User checking success", allUserData: allUserData });
  } catch (error) {
    // 오류 발생 시 오류 응답
    console.error("Error fetching all profile", error);
    res.status(500).json({ error: "Failed to fetch all profile" });
  }
});


// 관리자 특정 사용자 프로필 조회
adminAuth.get("/profile/:uid", isAdmin, async (req, res) => {
  const uid = req.params.uid;

  try {
    // Firebase Firestore에서 해당 사용자의 문서를 가져옴
    const userDoc = await getDoc(doc(db, "users", uid));
    if (!userDoc.exists()) {
      // 사용자 문서가 존재하지 않는 경우 오류 응답
      return res.status(404).json({ error: "User not found" });
    }

    // 사용자 정보 반환
    const userData = userDoc.data();
    res
      .status(200)
      .json({ message: "User checking success", userData: userData });
  } catch (error) {
    // 오류 발생 시 오류 응답
    console.error("Error fetching profile", error);
    res.status(500).json({ error: "Failed to fetch profile" });
  }
});

export default adminAuth;