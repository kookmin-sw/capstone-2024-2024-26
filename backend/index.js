import express from "express";
import bodyParser from "body-parser";

import router from "./routes/authRoutes.js";
import reserveClub from "./routes/reserveclub.js";
import reserveroom from "./routes/reserveroom.js";
import adminAuth from "./admin/adminAuth.js";
import adminClub from "./admin/adminClub.js";
import adminRoom from "./admin/adminRoom.js";
import adminCamera from "./admin/adminCamera.js";
import adminNotify from "./admin/adminNotify.js";
import inquiry from "./routes/inquiry.js";
import adminInquiry from "./admin/adminInquiry.js";
// import notify from "./routes/notify.js";

const port = 3000;

const app = express();

app.use(express.json({ limit: "100mb" }));
app.use(express.urlencoded({ limit: "100mb", extended: false }));
app.use(bodyParser.json());
// 회원가입, 로그인, 로그아웃
app.use("/auth", router);
// 동아리 예약 관련 api
app.use("/reserveclub", reserveClub);
// 강의실 예약 관련 api
app.use("/reserveroom", reserveroom);
// 관리자 회원 관리 api
app.use("/adminAuth", adminAuth);
// 관리자 동아리방 관리 api
app.use("/adminClub", adminClub);
// 관리자 강의실 관리 api
app.use("/adminRoom", adminRoom);

// 카메라 관리 api
app.use("/adminCamera", adminCamera);
// 문의 관리 api
app.use("/inquiry", inquiry);
// 관리자 문의 관리 api
app.use("/adminInquiry", adminInquiry);
// 관리자 알림 관리 api
app.use("/adminNotify", adminNotify);
// 백그라운드 설정
// app.use("/notify", notify);

// 서버 시작
app.listen(port, () => {
  console.log(`Server is running on port ${port}`);
});
