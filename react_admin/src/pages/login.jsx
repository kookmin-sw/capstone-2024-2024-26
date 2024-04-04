import React, { useState } from 'react';
import { signInWithEmailAndPassword } from "firebase/auth";
import { authService } from '../firebase/fbInstance';
import { useNavigate } from "react-router-dom";
import kookmin_logo from '../image/kookmin_logo.jpg';
import style from "../styles/login.css";

const Login = () => {
    const [email, setEmail] = useState('');
    const [password, setPassword] = useState('');
    const [error, setError] = useState('');
    const navigate = useNavigate();

    const onChange = (event) => {
        const { name, value } = event.target;
        if (name === "email") setEmail(value);
        else if (name === "password") setPassword(value);
    }

    const onSubmit = async (event) => {
        event.preventDefault();
        try {
            await signInWithEmailAndPassword(authService, email, password);
            navigate('/Main');
        } catch (error) {
            setError(error.message);
        }
    }

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
                            onChange={onChange} />
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
                            onChange={onChange} />
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