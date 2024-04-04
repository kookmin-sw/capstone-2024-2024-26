import * as React from 'react';
import AppBar from '@mui/material/AppBar';
import Box from '@mui/material/Box';
import Toolbar from '@mui/material/Toolbar';
import Typography from '@mui/material/Typography';
import IconButton from '@mui/material/IconButton';
import MenuIcon from '@mui/icons-material/Menu';
import Container from '@mui/material/Container';
import Button from '@mui/material/Button';
import { Drawer, List, ListItem, ListItemButton, ListItemText } from "@mui/material";
import { useNavigate } from "react-router-dom";

const pages = ['Home', '회원관리', '문의 관리', '알림 관리', '페이지 관리'];
const paths = ['/', '/member', '/inquiry', '/notification', '/pageManagement'];

function AppNavBar() {
    const [anchorElNav, setAnchorElNav] = React.useState(false);

    const navigate = useNavigate();
    const navigatePage = (path) => {
        navigate(path);
        setAnchorElNav(false);
    };

    const toggleDrawer = (state) => (event) => {
        if (event.type === 'keydown' && (event.key === 'Tab' || event.key === 'Shift')) { return; }
        setAnchorElNav(state);
    }

    const handleLogout = () => {
    };

    return (
        <AppBar position="static" color="inherit" style={{ marginBottom: "5vh" }}>
            <Container maxWidth="xl">
                <Toolbar disableGutters>
                    <Typography
                        variant="h6"
                        noWrap
                        component="a"
                        onClick={() => navigatePage('/')}
                        sx={{ flexGrow: 1 }}>
                        <img src={"img/Logo_mini.png"} height={"50"} style={{ marginTop: 10 }} alt="Logo"/>
                    </Typography>
                    <Box sx={{ display: { xs: 'none', md: 'flex' } }}>
                        {pages.map((page, index) => (
                            <Button
                                key={page}
                                onClick={() => navigatePage(paths[index])}
                                sx={{ color: 'black' }}>
                                {page}
                            </Button>
                        ))}
                    </Box>
                    <IconButton
                        size="large"
                        onClick={toggleDrawer(true)}
                        color="inherit"
                        sx={{ display: { xs: 'block', md: 'none' } }}>
                        <MenuIcon />
                    </IconButton>
                    <Drawer
                        anchor='right'
                        open={anchorElNav}
                        onClose={toggleDrawer(false)}
                        sx={{ '& .MuiDrawer-paper': { width: 250 } }}>
                        <Box
                            role="presentation"
                            onClick={toggleDrawer(false)}
                            onKeyDown={toggleDrawer(false)}>
                            <List>
                                {pages.map((page, index) => (
                                    <ListItem key={page} onClick={() => navigatePage(paths[index])}>
                                        <ListItemButton>
                                            <ListItemText primary={page} />
                                        </ListItemButton>
                                    </ListItem>
                                ))}
                            </List>
                        </Box>
                    </Drawer>
                    <Button color="inherit" onClick={handleLogout} sx={{ display: { xs: 'none', md: 'flex' } }}>
                        Logout
                    </Button>
                </Toolbar>
            </Container>
        </AppBar>
    );
}

export default AppNavBar;