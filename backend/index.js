import express from "express";
import bodyParser from "body-parser";

import router from "./routes/authRoutes.js";

const port = 3000;

const app2 = express();

app2.use(express.json());
app2.use(bodyParser.json());
// 회원가입, 로그인, 로그아웃
app2.use("/auth", router);
//
// 서버 시작
app2.listen(port, () => {
  console.log("Server is running on port ${port}");
});
