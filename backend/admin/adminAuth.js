import {
    getAuth,
    createUserWithEmailAndPassword,
    deleteUser,
    fetchSignInMethodsForEmail,
  } from "firebase/auth";
  import {
    setDoc,
    getFirestore,
    doc,
    deleteDoc,
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
    const adminEmail = "admin@kookmin.ac.kr";
  
    // 이메일이 관리자 이메일과 일치하는지 확인
    if (email === adminEmail) {
      // 관리자인 경우 다음 미들웨어로 진행
      next();
    } else {
      // 관리자가 아닌 경우 권한 없음 응답
      res.status(403).json({ error: "Unauthorized: You are not an admin " });
    }
  }
  
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
  
  export default adminAuth;
  