import React, { useState } from "react";
import { Link } from "react-router-dom"
import SidebarItem from "./element.jsx"
import '../styles/sidebar.css';

function SideBar() {

    const [dropdownOpen, setDropdownOpen] = useState(false);


    const menus = [
        { name: "home", path: "/main"},
        { name: "회원 관리", path: "/member"},
        { name: "예약 확인", path: "/reserve"},
        {
            name: "예약 관리", path: "", subMenus: [
                { name: "강의실", path: "/room" },
                { name: "공유공간", path: "/club" }
            ]
        },
        { name: "문의 관리", path: "/inquiry"},
        { name: "알림 관리", path: "/notification"},
        { name: "공간 관리", path: "/page-management"},
        { name: "혼잡도 관리", path: "/traffic"},
    ];

    const handleDropdown = () => {
        setDropdownOpen(!dropdownOpen);
    };
    
    return (
        <div className="sidebar_middle">
            <div className="sidebar">
                {menus.map((menu, index) => {
                    if (menu.name === "예약 관리") {
                        return (
                            <div key={index}>
                                <div onClick={handleDropdown}>
                                    <SidebarItem menu={menu} isActive={dropdownOpen} />
                                </div>
                                {dropdownOpen && menu.subMenus.map((subMenu) => (
                                    <Link to={subMenu.path} key={subMenu.name}>
                                        <SidebarItem menu={subMenu} isSubMenu={true} />
                                    </Link>
                                ))}
                            </div>
                        );
                    } else {
                        return (
                            <Link to={menu.path} key={index}>
                                <SidebarItem menu={menu} />
                            </Link>
                        );
                    }
                })}
            </div>
        </div>
    );
}

export default SideBar;