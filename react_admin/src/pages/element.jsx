import React from 'react';
import '../styles/item.css';

function SidebarItem({ menu, isActive, isSubMenu = false }) {
    // isSubMenu prop에 따라 클래스를 조건부로 추가
    const itemClass = `sidebar-item ${isSubMenu ? 'sub-menu' : ''}`;

    return (
        <div className={itemClass}>
            <p className="sidebar_menu">{menu.name}</p>
        </div>
    );
}

export default SidebarItem;