import React from "react";
import { Link } from "react-router-dom"
import { useNavigate } from "react-router-dom";
import { authService } from '../firebase/fbInstance';
import SidebarItem from "./element.jsx"
import '../styles/sidebar.css';

function SideBar() {


    const navigate = useNavigate(); // useHistory 훅을 사용하여 history 객체 생성

    const handleLogout = async () => {
          try {
            await authService.signOut(); // Firebase의 signOut 메서드를 사용하여 로그아웃
            navigate('/'); // 로그아웃 후 login 페이지로 이동
        } catch (error) {
            console.error('로그아웃 에러:', error);
        }
    };

    const menus = [
        { name: "home", path: "/main"},
        { name: "회원 관리", path: "/member"},
        { name: "문의 관리", path: "/inquiry"},
        { name: "페이지 관리", path: "/page-management"},
        { name: "알림 관리", path: "/notification"},
        { name: "예약 관리", path: "/reserve"},
    ];
    
    return(
            <div className="sidebar_middle">
                <div className="sidebar">
                    {menus.map((menu, index) =>{
                        return(
                            <Link to={menu.path} key={index}>
                                <SidebarItem
                                menu={menu}
                                />
                            </Link>
                        );
                        })}
                </div>
            </div>
    );

}

export default SideBar;