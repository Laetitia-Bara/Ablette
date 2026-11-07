export type Fuel = 'PETROL' | 'DIESEL' | 'HYBRID' | 'ELECTRIC' | 'LPG' | 'OTHER'

export const fuelLabels: Record<Fuel, string> = {
  PETROL: 'Essence',
  DIESEL: 'Diesel',
  HYBRID: 'Hybride',
  ELECTRIC: 'Électrique',
  LPG: 'GPL',
  OTHER: 'Autre',
}

export interface VehicleInput {
  nickname: string | null
  brand: string
  model: string
  year: number
  engine: string
  fuel: Fuel
  currentMileage: number
}

export interface Vehicle extends VehicleInput {
  id: string
  createdAt: string
}

interface ProblemDetail {
  detail?: string
  errors?: Record<string, string>
}

export class ApiError extends Error {
  constructor(
    public status: number,
    message: string,
    public fields: Record<string, string> = {},
  ) {
    super(message)
    this.name = 'ApiError'
  }
}

async function request<T>(path: string, init?: RequestInit): Promise<T> {
  let response: Response
  try {
    response = await fetch(`/api/v1${path}`, {
      ...init,
      headers: { Accept: 'application/json', ...init?.headers },
      credentials: 'same-origin',
      cache: 'no-store',
    })
  } catch {
    throw new ApiError(
      0,
      'Connexion impossible. Vérifiez votre connexion et réessayez.',
    )
  }
  if (!response.ok) {
    const problem = (await response.json().catch(() => ({}))) as ProblemDetail
    const fallback =
      response.status >= 500
        ? 'Le garage est momentanément indisponible. Réessayez dans un instant.'
        : 'La demande n’a pas pu être traitée. Réessayez.'
    throw new ApiError(
      response.status,
      problem.detail || fallback,
      problem.errors || {},
    )
  }
  return response.json() as Promise<T>
}

export const vehicleKeys = { all: ['vehicles'] as const }
export const getVehicles = () => request<Vehicle[]>('/vehicles')
export const createVehicle = (vehicle: VehicleInput) =>
  request<Vehicle>('/vehicles', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(vehicle),
  })
