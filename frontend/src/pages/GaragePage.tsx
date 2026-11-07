import {
  Alert,
  Box,
  Button,
  Chip,
  CircularProgress,
  Paper,
  Typography,
} from '@mui/material'
import { useQuery } from '@tanstack/react-query'
import { Link, useLocation } from 'react-router'
import {
  fuelLabels,
  getVehicles,
  vehicleKeys,
  type Vehicle,
} from '../api/vehicles'
import { CarIcon } from '../components/CarIcon'

const kilometers = new Intl.NumberFormat('fr-FR')

function VehicleCard({ vehicle }: { vehicle: Vehicle }) {
  const title = vehicle.nickname || `${vehicle.brand} ${vehicle.model}`
  return (
    <Paper component="article" className="vehicle-card" aria-label={title}>
      <div className="vehicle-card-top">
        <span className="vehicle-emblem">
          <CarIcon />
        </span>
        <Chip
          label={fuelLabels[vehicle.fuel]}
          size="small"
          className="fuel-chip"
        />
      </div>
      <Typography component="h2" variant="h2" className="vehicle-name">
        {title}
      </Typography>
      <Typography
        component="p"
        color="text.secondary"
        className="vehicle-subtitle"
      >
        {vehicle.brand} {vehicle.model} · {vehicle.year}
      </Typography>
      <div className="vehicle-mileage">
        <span className="metric-label">KILOMÉTRAGE ACTUEL</span>
        <strong>
          {kilometers.format(vehicle.currentMileage)} <small>km</small>
        </strong>
      </div>
      <dl className="vehicle-facts">
        <div>
          <dt>Motorisation</dt>
          <dd>{vehicle.engine}</dd>
        </div>
        <div>
          <dt>Année</dt>
          <dd>{vehicle.year}</dd>
        </div>
      </dl>
    </Paper>
  )
}

export function GaragePage() {
  const query = useQuery({ queryKey: vehicleKeys.all, queryFn: getVehicles })
  const location = useLocation()
  const created = Boolean(
    (location.state as { created?: boolean } | null)?.created,
  )
  return (
    <>
      <div className="page-heading">
        <div>
          <Typography className="eyebrow" component="p">
            BIENVENUE CHEZ VOUS
          </Typography>
          <Typography variant="h1" component="h1">
            Mon garage<span className="title-dot">.</span>
          </Typography>
          <Typography color="text.secondary" className="page-description">
            Tous vos véhicules, au même endroit.
          </Typography>
        </div>
        <Button
          component={Link}
          to="/garage/new"
          variant="contained"
          className="add-vehicle"
        >
          <span className="plus" aria-hidden="true">
            +
          </span>{' '}
          Ajouter un véhicule
        </Button>
      </div>
      {created && (
        <Alert severity="success" className="page-alert">
          Votre véhicule a bien été ajouté au garage.
        </Alert>
      )}
      {query.isPending && (
        <Box role="status" className="status-panel">
          <CircularProgress size={30} />
          <Typography>Ouverture de votre garage…</Typography>
        </Box>
      )}
      {query.isError && (
        <Alert
          severity="error"
          className="page-alert"
          action={
            <Button
              color="inherit"
              onClick={() => {
                void query.refetch()
              }}
              disabled={query.isFetching}
            >
              Réessayer
            </Button>
          }
        >
          {query.error.message}
        </Alert>
      )}
      {query.data && (
        <>
          <div className="section-heading">
            <Typography component="h2">
              Mes véhicules{' '}
              <span className="count-badge">{query.data.length}</span>
            </Typography>
            <span>Votre route commence ici</span>
          </div>
          {query.data.length === 0 ? (
            <Paper className="empty-garage">
              <div className="empty-illustration" aria-hidden="true">
                <span className="illustration-ring" />
                <CarIcon />
              </div>
              <Typography variant="h2" component="h3">
                Faisons une place à votre véhicule.
              </Typography>
              <Typography color="text.secondary" className="empty-description">
                Ajoutez votre premier véhicule pour retrouver
                <br className="desktop-break" /> ses informations dans votre
                garage.
              </Typography>
              <Button component={Link} to="/garage/new" variant="contained">
                <span className="plus" aria-hidden="true">
                  +
                </span>{' '}
                Ajouter mon premier véhicule
              </Button>
              <span className="empty-caption">
                Quelques informations suffisent pour commencer.
              </span>
            </Paper>
          ) : (
            <div className="vehicle-grid">
              {query.data.map((vehicle) => (
                <VehicleCard key={vehicle.id} vehicle={vehicle} />
              ))}
            </div>
          )}
        </>
      )}
      <div className="garage-footnote">
        <span aria-hidden="true">↗</span>
        <p>
          Un bon suivi commence par les bonnes informations.
          <br />
          <strong>
            Votre garage vous accompagne, kilomètre après kilomètre.
          </strong>
        </p>
      </div>
    </>
  )
}
