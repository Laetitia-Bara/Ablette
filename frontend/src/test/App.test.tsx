import { render, screen, waitFor } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { CssBaseline, ThemeProvider } from '@mui/material'
import { QueryClient, QueryClientProvider } from '@tanstack/react-query'
import { MemoryRouter } from 'react-router'
import { afterEach, describe, expect, it, vi } from 'vitest'
import { App } from '../App'
import { theme } from '../theme'
import { type Vehicle } from '../api/vehicles'

const vehicle: Vehicle = {
  id: '31dfde45-1fc5-4e3c-9048-56888eb778fd',
  nickname: 'La bleue',
  brand: 'Renault',
  model: 'Clio',
  year: 2020,
  engine: '1.0 TCe 100',
  fuel: 'PETROL',
  currentMileage: 42000,
  createdAt: '2026-10-21T14:00:00Z',
}

function response(body: unknown, status = 200) {
  return new Response(JSON.stringify(body), {
    status,
    headers: { 'Content-Type': 'application/json' },
  })
}

function mount(path = '/garage') {
  const client = new QueryClient({
    defaultOptions: { queries: { retry: false }, mutations: { retry: false } },
  })
  return render(
    <ThemeProvider theme={theme}>
      <CssBaseline />
      <QueryClientProvider client={client}>
        <MemoryRouter initialEntries={[path]}>
          <App />
        </MemoryRouter>
      </QueryClientProvider>
    </ThemeProvider>,
  )
}

async function fillVehicle(user: ReturnType<typeof userEvent.setup>) {
  await user.type(await screen.findByLabelText(/Surnom/), 'La bleue')
  await user.type(screen.getByLabelText(/Marque/), 'Renault')
  await user.type(screen.getByLabelText(/Modèle/), 'Clio')
  await user.type(screen.getByLabelText(/^Année/), '2020')
  await user.type(screen.getByLabelText(/Motorisation/), '1.0 TCe 100')
  await user.selectOptions(screen.getByLabelText(/Carburant/), 'PETROL')
  await user.type(screen.getByLabelText(/Kilométrage actuel/), '42000')
}

afterEach(() => {
  vi.unstubAllGlobals()
})

describe('Garage', () => {
  it('attend la réponse du serveur puis présente un garage vide sans données de démonstration', async () => {
    let resolveRequest: (value: Response) => void = () => undefined
    const fetchMock = vi.fn(
      () =>
        new Promise<Response>((resolve) => {
          resolveRequest = resolve
        }),
    )
    vi.stubGlobal('fetch', fetchMock)
    mount()
    expect(screen.getByRole('status')).toHaveTextContent(
      'Ouverture de votre garage',
    )
    resolveRequest(response([]))
    expect(
      await screen.findByRole('heading', {
        name: 'Faisons une place à votre véhicule.',
      }),
    ).toBeInTheDocument()
    expect(screen.queryByRole('article')).not.toBeInTheDocument()
    expect(fetchMock).toHaveBeenCalledWith(
      '/api/v1/vehicles',
      expect.objectContaining({ cache: 'no-store' }),
    )
  })

  it('crée via POST, recharge la liste et relit les véhicules après une nouvelle ouverture', async () => {
    const user = userEvent.setup()
    const saved: Vehicle[] = []
    const fetchMock = vi.fn(async (_url: string, init?: RequestInit) => {
      if (init?.method === 'POST') {
        expect(JSON.parse(init.body as string)).toEqual({
          nickname: 'La bleue',
          brand: 'Renault',
          model: 'Clio',
          year: 2020,
          engine: '1.0 TCe 100',
          fuel: 'PETROL',
          currentMileage: 42000,
        })
        saved.push(vehicle)
        return response(vehicle, 201)
      }
      return response(saved)
    })
    vi.stubGlobal('fetch', fetchMock)
    const firstMount = mount()
    await screen.findByRole('heading', {
      name: 'Faisons une place à votre véhicule.',
    })
    await user.click(screen.getByRole('link', { name: 'Ajouter un véhicule' }))
    await fillVehicle(user)
    await user.click(
      await screen.findByRole('button', { name: 'Ajouter au garage' }),
    )
    expect(
      await screen.findByRole('article', { name: 'La bleue' }),
    ).toHaveTextContent('Renault Clio · 2020')
    expect(screen.getByRole('alert')).toHaveTextContent(
      'Votre véhicule a bien été ajouté',
    )
    expect(
      fetchMock.mock.calls.filter(([, init]) => init?.method !== 'POST'),
    ).toHaveLength(2)
    firstMount.unmount()
    mount()
    expect(
      await screen.findByRole('article', { name: 'La bleue' }),
    ).toBeInTheDocument()
    expect(
      fetchMock.mock.calls.filter(([, init]) => init?.method !== 'POST'),
    ).toHaveLength(3)
  })

  it('permet de réessayer après une erreur réseau sans afficher un faux garage vide', async () => {
    const user = userEvent.setup()
    const fetchMock = vi
      .fn()
      .mockRejectedValueOnce(new TypeError('Failed to fetch'))
      .mockResolvedValueOnce(response([vehicle]))
    vi.stubGlobal('fetch', fetchMock)
    mount()
    expect(await screen.findByRole('alert')).toHaveTextContent(
      'Connexion impossible',
    )
    expect(
      screen.queryByText('Faisons une place à votre véhicule.'),
    ).not.toBeInTheDocument()
    await user.click(screen.getByRole('button', { name: 'Réessayer' }))
    expect(
      await screen.findByRole('article', { name: 'La bleue' }),
    ).toBeInTheDocument()
  })

  it('refuse les champs manquants et le kilométrage négatif avant tout appel API', async () => {
    const user = userEvent.setup()
    const fetchMock = vi.fn()
    vi.stubGlobal('fetch', fetchMock)
    mount('/garage/new')
    await user.click(screen.getByRole('button', { name: 'Ajouter au garage' }))
    expect(screen.getByLabelText(/Marque/)).toHaveFocus()
    expect(screen.getByLabelText(/Marque/)).toHaveAttribute(
      'aria-invalid',
      'true',
    )
    expect(screen.getAllByText('Ce champ est obligatoire.')).toHaveLength(4)
    await fillVehicle(user)
    await user.clear(screen.getByLabelText(/Kilométrage actuel/))
    await user.type(screen.getByLabelText(/Kilométrage actuel/), '-20')
    await user.click(screen.getByRole('button', { name: 'Ajouter au garage' }))
    expect(
      screen.getByText('Indiquez un kilométrage entier positif ou nul.'),
    ).toBeInTheDocument()
    expect(fetchMock).not.toHaveBeenCalled()
  })

  it('présente les erreurs de validation de l’API sous leur champ et conserve les saisies', async () => {
    const user = userEvent.setup()
    vi.stubGlobal(
      'fetch',
      vi.fn().mockResolvedValue(
        response(
          {
            detail: 'Les données sont invalides.',
            errors: { year: 'Cette année n’est pas acceptée.' },
          },
          400,
        ),
      ),
    )
    mount('/garage/new')
    await fillVehicle(user)
    await user.click(screen.getByRole('button', { name: 'Ajouter au garage' }))
    expect(await screen.findByRole('alert')).toHaveTextContent(
      'Les données sont invalides.',
    )
    await waitFor(() =>
      expect(screen.getByLabelText(/^Année/)).toHaveAttribute(
        'aria-invalid',
        'true',
      ),
    )
    expect(
      screen.getByText('Cette année n’est pas acceptée.'),
    ).toBeInTheDocument()
    expect(screen.getByLabelText(/Marque/)).toHaveValue('Renault')
  })
})
