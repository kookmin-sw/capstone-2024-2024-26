import express from "express";
import bodyParser from "body-parser";

import router from "./routes/authRoutes.js";
import reserveClub from "./routes/reserveclub.js";
import reserveroom from "./routes/reserveroom.js";

const port = 3000;

const app2 = express();

app2.use(express.json());
app2.use(bodyParser.json());
// 회원가입, 로그인, 로그아웃
app2.use("/auth", router);
// 동아리 예약 관련 api
app2.use("/reserveclub", reserveClub);
// 강의실 예약 관련 api
app2.use("/reserveroom", reserveroom);
// 서버 시작
app2.listen(port, () => {
  console.log(`Server is running on port ${port}`);
});
