import express from "express";
import bodyParser from "body-parser";

import router from "./routes/authRoutes.js";
import reserveClub from "./routes/reserveclub.js";
import reserveroom from "./routes/reserveroom.js";
import adminAuth from "./admin/routes/adminAuth.js";
import adminClub from "./admin/routes/adminClub.js";
import adminRoom from "./admin/routes/adminRoom.js";

const port = 3000;

const app = express();

app.use(express.json());
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
// 서버 시작
app.listen(port, () => {
  console.log(`Server is running on port ${port}`);
});
