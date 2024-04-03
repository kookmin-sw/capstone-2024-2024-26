import React, { useState } from 'react';
import { signInWithEmailAndPassword } from "firebase/auth";
import { authService } from '../firebase/fbInstance';
import { useNavigate } from "react-router-dom";
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
            navigate('/main');
        } catch (error) {
            setError(error.message);
        }
    }

    return (
        <div>
            <form onSubmit={onSubmit}>
                <input
                    name="email"
                    type="text"
                    placeholder='Email'
                    required
                    value={email}
                    onChange={onChange} />
                <input
                    name="password"
                    type="password"
                    placeholder="Password"
                    required
                    value={password}
                    onChange={onChange} />
                <input
                    type="submit"
                    value="Login"/>
            </form>
            {error && <p>{error}</p>}
        </div>
    )
}

export default Login;