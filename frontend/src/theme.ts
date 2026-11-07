import { createTheme } from '@mui/material/styles'

export const theme = createTheme({
  palette: {
    primary: { main: '#245747', dark: '#193f35', contrastText: '#ffffff' },
    background: { default: '#f5f5ef', paper: '#ffffff' },
    text: { primary: '#20342d', secondary: '#64746c' },
    divider: '#e2e7de',
    error: { main: '#ac352b' },
  },
  typography: {
    fontFamily:
      '"Segoe UI", -apple-system, BlinkMacSystemFont, Arial, sans-serif',
    h1: {
      fontSize: '2.55rem',
      fontWeight: 700,
      letterSpacing: '-0.055em',
      lineHeight: 1.15,
    },
    h2: { fontSize: '1.35rem', fontWeight: 650, letterSpacing: '-0.025em' },
    button: { textTransform: 'none', fontWeight: 650, fontSize: '0.95rem' },
  },
  shape: { borderRadius: 14 },
  components: {
    MuiButton: {
      defaultProps: { disableElevation: true },
      styleOverrides: {
        root: { minHeight: 48, padding: '11px 20px', borderRadius: 11 },
      },
    },
    MuiTextField: { defaultProps: { fullWidth: true, variant: 'outlined' } },
    MuiOutlinedInput: {
      styleOverrides: { root: { borderRadius: 11, background: '#ffffff' } },
    },
    MuiAlert: { styleOverrides: { root: { borderRadius: 12 } } },
    MuiPaper: { defaultProps: { elevation: 0 } },
  },
})
