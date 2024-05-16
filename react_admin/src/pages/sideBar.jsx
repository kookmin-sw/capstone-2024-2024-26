import React from "react";
import { Link } from "react-router-dom"
import SidebarItem from "./element.jsx"
import '../styles/sidebar.css';

function SideBar() {


    const menus = [
        { name: "home", path: "/main"},
        { name: "회원 관리", path: "/member"},
        { name: "문의 관리", path: "/inquiry"},
        { name: "공간 관리", path: "/page-management"},
        { name: "알림 관리", path: "/notification"},
        { name: "예약 관리", path: "/reserve"},
        { name: "혼잡도 관리", path: "/traffic"},
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