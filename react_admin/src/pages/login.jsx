import React, { useState } from 'react';
import { useNavigate } from "react-router-dom";
import axios from 'axios';
import kookmin_logo from '../image/kookmin_logo.jpg';
import '../styles/login.css';
import Swal from 'sweetalert2';

const Login = () => {
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [error, setError] = useState("");
  const navigate = useNavigate();

  const handleLogin = async () => {

    try {
      const response = await axios.post("http://localhost:3000/adminAuth/signin", {
        email,
        password,
      });

      if (response.data.message === "Signin successful") {
        // 로그인 성공 시 이메일 저장
        localStorage.setItem("userEmail", email);  // 로컬 스토리지에 이메일 저장
        const adminEmail = "react@kookmin.ac.kr"; // 관리자 이메일 설정
        if (email === adminEmail) {
            localStorage.setItem("isAdmin", "true"); // 관리자로 로그인된 상태 저장
        } else {
            localStorage.removeItem("isAdmin"); // 관리자가 아니면 관리자 상태 제거
        }
        navigate("/main");
      } else {
        Swal.fire({
          icon: "info",
          title: "로그인 실패!",
          text: "아이디와 비밀번호를 확인해주시길 바랍니다",
      });
        setError("로그인 실패: " + response.data.message);
      }
    } catch (error) {
      Swal.fire({
        icon: "info",
        title: "로그인 실패!",
        text: "아이디와 비밀번호를 확인해주시길 바랍니다",
    });
      setError("로그인 실패: 서버 오류가 발생했습니다.");
      Swal.fire({
        icon: "info",
        title: "로그인 실패!",
        text: "아이디와 비밀번호를 확인해주시길 바랍니다",
    });
    }
  };

  const onSubmit = (e) => {
      e.preventDefault();  // 폼의 기본 제출 동작을 막습니다.
      handleLogin();
  };

    const backgroundImageStyle = {
        backgroundImage: `url(${kookmin_logo})`,
        backgroundSize: 'cover',
        backgroundPosition: 'center',
        backgroundRepeat: 'no-repeat',
      };

    return (
      <div className='login_background'>
       <div className='login_container'>
            {/* <h2>K-SharePlace 관리자 웹</h2> */}
        <div className='login_box'>
            <h2>K-SharePlace 관리자 웹</h2>
            <form onSubmit={onSubmit}>
                <div className='form_group'>
                    <label htmlFor="Email">관리자 아이디</label>
                        <input
                            className='login_box_input'
                            name="email"
                            type="text"
                            placeholder='exmaple@kookmin.ac.kr'
                            required
                            value={email}
                            onChange={(e) => setEmail(e.target.value)} />
                </div>
                <div className='form_group'>
                        <label htmlFor="Password">비밀번호</label>
                        <input
                            className='login_box_input'
                            name="password"
                            type="password"
                            placeholder="Password"
                            required
                            value={password}
                            onChange={(e) => setPassword(e.target.value)} />
                </div>
                        <input
                            className='login_box_button'
                            type="submit"
                            value="Login"/>
            </form>
            {error && <p className='login_error'>{ "아이디 혹은 비밀번호가 잘못되었습니다." }</p>}
        </div>
        <div className='login_image' style={backgroundImageStyle}></div>
       </div>
      </div>

    )
}

export default Login;