import { Box, Typography } from '@mui/material'
import { Link, NavLink, Outlet } from 'react-router'
import { CarIcon } from './CarIcon'

function Brand() {
  return (
    <Link
      to="/garage"
      className="brand"
      aria-label="Ablette, accueil du garage"
    >
      <span className="brand-icon">
        <CarIcon />
      </span>
      <span>
        ablette<span className="brand-dot">.</span>
      </span>
    </Link>
  )
}

export function AppLayout() {
  return (
    <div className="app-shell">
      <a className="skip-link" href="#main-content">
        Aller au contenu
      </a>
      <aside className="sidebar">
        <Brand />
        <Typography className="nav-label" component="p">
          VOTRE ESPACE
        </Typography>
        <nav aria-label="Navigation principale">
          <NavLink to="/garage" className="nav-item">
            <CarIcon fontSize="small" /> Mon garage
          </NavLink>
        </nav>
        <div className="sidebar-note">
          <span className="note-line" />
          <p>
            Un garage bien suivi.
            <br />
            <strong>L’esprit tranquille.</strong>
          </p>
          <span className="note-caption">VOTRE CARNET AUTOMOBILE</span>
        </div>
      </aside>
      <div className="workspace">
        <header className="topbar">
          <div className="mobile-brand">
            <Brand />
          </div>
          <span className="desktop-crumb">
            Mon espace <span>/</span> <strong>Garage</strong>
          </span>
          <Box className="garage-label">
            <span /> Votre carnet automobile
          </Box>
        </header>
        <main id="main-content" className="page-content" tabIndex={-1}>
          <Outlet />
        </main>
        <footer className="page-footer">
          <span>Ablette</span>
          <span>Le plaisir de prendre soin de son véhicule.</span>
        </footer>
      </div>
    </div>
  )
}
