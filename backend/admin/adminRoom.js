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
  
  const adminRoom = express.Router();

  export default adminRoom;