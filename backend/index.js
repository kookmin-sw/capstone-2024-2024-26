import express from "express";
import bodyParser from "body-parser";
import cors from 'cors';
import router from "./routes/authRoutes.js";
import reserveClub from "./routes/reserveclub.js";
import reserveroom from "./routes/reserveroom.js";
import adminAuth from "./admin/adminAuth.js";
import adminClub from "./admin/adminClub.js";
import adminRoom from "./admin/adminRoom.js";


const port = 3000;
const app = express();

app.use(cors({
  origin: ['http://localhost:3000', 'http://localhost:3001']
}));
//서로다른 포트의 요청을 허용하게 해줌
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
