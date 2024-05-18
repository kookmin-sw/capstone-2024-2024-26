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

adminCamera.get("/get", async (req, res) => {
  console.log("Received get request for cameras."); // 서버에서 요청 받음 확인 로그
  try {
    const cameraDocs = await getDocs(query(collection(db, "Camera")));
    console.log("Query executed, documents count:", cameraDocs.size); // 문서 수 로깅
    if (cameraDocs.empty) {
      console.log("No camera locations found."); // 데이터가 없는 경우 로그
      return res.status(400).json({ message: "No location for camera" });
    }

    const cameras = [];
    cameraDocs.forEach((doc) => {
      // cameras.push(doc.data());
      const cameraData = doc.data();
      cameraData.locationName = doc.id; // 데이터 객체에 id 속성 추가

      cameras.push(cameraData);
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

adminCamera.post("/set", async (req, res) => {
  const { locationName, location } = req.body;
  try {
    // 카메라 위치정보 등록
    await setDoc(doc(db, "Camera", `${locationName}`), {
      location: location,
      info: "",
      state: ""
    });

    res.status(200).json({ message: "Setting camera successfully" });
  } catch (error) {
    res.status(400).json({ error: "Failed to setting camera location" });
  }
});


adminCamera.delete("/delete/:locationName", async (req, res) => {
  const locationName = req.params.locationName;
  try {
    await deleteDoc(doc(db, "Camera", locationName));
    console.log(`Deleted camera at location: ${locationName}`); // Log the deletion
    res.status(200).json({ message: `Camera deleted at ${locationName}` });
  } catch (error) {
    console.error(`Error deleting camera at ${locationName}:`, error);
    res.status(500).json({ message: "Failed to delete camera location" });
  }
});


adminCamera.patch("/update/:locationName", async (req, res) => {
  const locationName = req.params.locationName;
  const updateData = req.body; // Data to update
  try {
    await setDoc(doc(db, "Camera", locationName), updateData, { merge: true }); // Set with merge to update fields
    console.log(`Updated camera at location: ${locationName}`); // Log the update
    res.status(200).json({ message: `Camera updated at ${locationName}` });
  } catch (error) {
    console.error(`Error updating camera at ${locationName}:`, error);
    res.status(500).json({ message: "Failed to update camera location" });
  }
});



export default adminCamera;