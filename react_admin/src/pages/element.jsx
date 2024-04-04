import React from "react";
import '../styles/item.css';


function SidebarItem({ menu, isActive }) {
    return isActive === true ? (
        <div className="sidebar-item">
            <p className="sidebar_menu">{menu.name}</p>
        </div>
    ) : (
        <div className="sidebar-item">
            <p className="sidebar_menu">{menu.name}</p>
        </div>
    );
}

export default SidebarItem;