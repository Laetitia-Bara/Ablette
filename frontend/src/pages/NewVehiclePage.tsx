import { useRef, useState, type FormEvent } from 'react'
import {
  Alert,
  Button,
  CircularProgress,
  Paper,
  TextField,
  Typography,
} from '@mui/material'
import { useMutation, useQueryClient } from '@tanstack/react-query'
import { Link, useNavigate } from 'react-router'
import {
  ApiError,
  createVehicle,
  fuelLabels,
  vehicleKeys,
  type Fuel,
  type VehicleInput,
} from '../api/vehicles'
import { CarIcon } from '../components/CarIcon'

type FormValues = { [K in keyof VehicleInput]: string }
const initialValues: FormValues = {
  nickname: '',
  brand: '',
  model: '',
  year: '',
  engine: '',
  fuel: '',
  currentMileage: '',
}

export function NewVehiclePage() {
  const [values, setValues] = useState(initialValues)
  const [errors, setErrors] = useState<Record<string, string>>({})
  const formRef = useRef<HTMLFormElement>(null)
  const queryClient = useQueryClient()
  const navigate = useNavigate()
  const mutation = useMutation({
    mutationFn: createVehicle,
    onSuccess: async () => {
      await queryClient.invalidateQueries({ queryKey: vehicleKeys.all })
      await navigate('/garage', { state: { created: true }, replace: true })
    },
    onError: (error) => {
      if (error instanceof ApiError) setErrors(error.fields)
    },
  })

  function update(field: keyof FormValues, value: string) {
    setValues((previous) => ({ ...previous, [field]: value }))
    setErrors((previous) => ({ ...previous, [field]: '' }))
  }

  function submit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault()
    if (mutation.isPending) return
    const validation: Record<string, string> = {}
    const maxYear = new Date().getFullYear() + 1
    for (const field of ['brand', 'model', 'engine', 'fuel'] as const) {
      if (!values[field].trim()) validation[field] = 'Ce champ est obligatoire.'
    }
    if (
      !/^\d{4}$/.test(values.year) ||
      Number(values.year) < 1900 ||
      Number(values.year) > maxYear
    )
      validation.year = `Indiquez une année entre 1900 et ${maxYear}.`
    if (
      !/^\d+$/.test(values.currentMileage) ||
      Number(values.currentMileage) > 2147483647
    )
      validation.currentMileage =
        'Indiquez un kilométrage entier positif ou nul.'
    setErrors(validation)
    if (Object.keys(validation).length) {
      const firstField = Object.keys(validation)[0]
      formRef.current
        ?.querySelector<HTMLElement>(`[name="${firstField}"]`)
        ?.focus()
      return
    }
    mutation.mutate({
      nickname: values.nickname.trim() || null,
      brand: values.brand.trim(),
      model: values.model.trim(),
      engine: values.engine.trim(),
      year: Number(values.year),
      fuel: values.fuel as Fuel,
      currentMileage: Number(values.currentMileage),
    })
  }

  const textField = (
    field: keyof FormValues,
    label: string,
    maxLength: number,
    helper?: string,
  ) => (
    <TextField
      id={field}
      name={field}
      label={label}
      value={values[field]}
      onChange={(event) => update(field, event.target.value)}
      error={Boolean(errors[field])}
      helperText={errors[field] || helper}
      required={field !== 'nickname'}
      disabled={mutation.isPending}
      slotProps={{ htmlInput: { maxLength } }}
    />
  )

  return (
    <div className="form-page">
      <Button
        component={Link}
        to="/garage"
        className="back-button"
        color="inherit"
      >
        <span aria-hidden="true">←</span> Retour au garage
      </Button>
      <div className="form-heading">
        <Typography className="eyebrow" component="p">
          AGRANDISSEZ VOTRE GARAGE
        </Typography>
        <Typography variant="h1" component="h1">
          Un nouveau compagnon<span className="title-dot">.</span>
        </Typography>
        <Typography color="text.secondary" className="page-description">
          Renseignez votre véhicule. On s’occupe de lui faire une place.
        </Typography>
      </div>
      <Paper className="vehicle-form-paper">
        <div className="form-intro">
          <span className="vehicle-emblem">
            <CarIcon />
          </span>
          <div>
            <Typography component="h2" variant="h2">
              Les informations du véhicule
            </Typography>
            <Typography variant="body2" color="text.secondary">
              Les champs marqués d’un * sont obligatoires.
            </Typography>
          </div>
        </div>
        <form
          ref={formRef}
          onSubmit={submit}
          noValidate
          aria-label="Ajouter un véhicule"
        >
          {mutation.isError && (
            <Alert severity="error" className="form-error">
              {mutation.error.message}
            </Alert>
          )}
          <div className="form-fields">
            <div className="full-width">
              {textField(
                'nickname',
                'Surnom (facultatif)',
                80,
                'Un petit nom pour le retrouver facilement.',
              )}
            </div>
            {textField('brand', 'Marque', 80)}
            {textField('model', 'Modèle', 80)}
            <TextField
              id="year"
              name="year"
              label="Année"
              value={values.year}
              onChange={(event) => update('year', event.target.value)}
              required
              disabled={mutation.isPending}
              error={Boolean(errors.year)}
              helperText={errors.year}
              slotProps={{ htmlInput: { inputMode: 'numeric', maxLength: 4 } }}
            />
            {textField(
              'engine',
              'Motorisation',
              120,
              'Par exemple : 1.2 TCe 100 ou 100 kW.',
            )}
            <TextField
              select
              id="fuel"
              name="fuel"
              label="Carburant"
              value={values.fuel}
              onChange={(event) => update('fuel', event.target.value)}
              required
              disabled={mutation.isPending}
              error={Boolean(errors.fuel)}
              helperText={errors.fuel}
              slotProps={{ select: { native: true } }}
            >
              <option value="" aria-label="Choisir un carburant" />
              {Object.entries(fuelLabels).map(([value, label]) => (
                <option key={value} value={value}>
                  {label}
                </option>
              ))}
            </TextField>
            <TextField
              id="currentMileage"
              name="currentMileage"
              label="Kilométrage actuel (km)"
              value={values.currentMileage}
              onChange={(event) => update('currentMileage', event.target.value)}
              required
              disabled={mutation.isPending}
              error={Boolean(errors.currentMileage)}
              helperText={
                errors.currentMileage ||
                'Le nombre de kilomètres affiché au compteur.'
              }
              slotProps={{ htmlInput: { inputMode: 'numeric', maxLength: 10 } }}
            />
          </div>
          <div className="form-actions">
            <Button
              component={Link}
              to="/garage"
              color="inherit"
              disabled={mutation.isPending}
            >
              Annuler
            </Button>
            <Button
              type="submit"
              variant="contained"
              disabled={mutation.isPending}
              startIcon={
                mutation.isPending ? (
                  <CircularProgress size={18} color="inherit" />
                ) : undefined
              }
            >
              {mutation.isPending ? 'Enregistrement…' : 'Ajouter au garage'}
            </Button>
          </div>
        </form>
      </Paper>
      <p className="form-note">
        Vous pourrez retrouver ces informations dans votre garage.
      </p>
    </div>
  )
}
