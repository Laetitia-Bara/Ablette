import { lazy, Suspense } from 'react'
import { Button, Typography } from '@mui/material'
import { Link, Navigate, Route, Routes } from 'react-router'
import { AppLayout } from './components/AppLayout'
import { GaragePage } from './pages/GaragePage'

const NewVehiclePage = lazy(async () => ({
  default: (await import('./pages/NewVehiclePage')).NewVehiclePage,
}))

export function App() {
  return (
    <Routes>
      <Route element={<AppLayout />}>
        <Route index element={<Navigate to="/garage" replace />} />
        <Route path="garage" element={<GaragePage />} />
        <Route
          path="garage/new"
          element={
            <Suspense fallback={<p role="status">Ouverture du formulaire…</p>}>
              <NewVehiclePage />
            </Suspense>
          }
        />
        <Route
          path="*"
          element={
            <div className="not-found">
              <Typography variant="h1" component="h1">
                Route inconnue.
              </Typography>
              <Typography>
                Cette page ne fait pas partie de votre garage.
              </Typography>
              <Button component={Link} to="/garage" variant="contained">
                Retrouver mon garage
              </Button>
            </div>
          }
        />
      </Route>
    </Routes>
  )
}
