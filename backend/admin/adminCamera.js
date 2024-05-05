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
    getDocs,
    getDoc,
    query,
    collection
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
  
  const adminCamera = express.Router();
  
  adminCamera.post("/set", async (req, res) => {
    const { location } = req.body;
    try {
      // 카메라 위치정보 등록
      await setDoc(doc(db, "Camera", `${location}`), {
        location: location,
        message: `Camera setting at ${location}`,
      });
  
      res.status(200).json({ message: "Setting camera successfully" });
    } catch (error) {
      res.status(400).json({ error: "Failed to setting camera location" });
    }
  });
  
  adminCamera.get("/get", async (req, res) => {
    try {
      const cameraDocs = await getDocs(query(collection(db, "Camera")));
      if (cameraDocs.empty) {
        return res.status(400).json({ message: "No location for camera" });
      }
  
      const cameras = [];
      cameraDocs.forEach((doc) => {
        cameras.push(doc.data());
      });
  
      res.status(200).json({
        message: "Retrieving all camera location successfully",
        cameras: cameras,
      });
    } catch (error) {
      console.error("Error retrieving camera locations:", error);
      res.status(500).json({ message: "Failed to retrieve camera locations" });
    }
  });
  
  export default adminCamera;