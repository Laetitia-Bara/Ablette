import SvgIcon, { type SvgIconProps } from '@mui/material/SvgIcon'

export function CarIcon(props: SvgIconProps) {
  return (
    <SvgIcon {...props} viewBox="0 0 24 24">
      <path d="m5 6-3 8v6h3v-2h14v2h3v-6l-3-8a2 2 0 0 0-2-1H7a2 2 0 0 0-2 1Zm2 .9h10L19 12H5l2-5.1ZM6 16a1.5 1.5 0 1 1 0-3 1.5 1.5 0 0 1 0 3Zm12 0a1.5 1.5 0 1 1 0-3 1.5 1.5 0 0 1 0 3Z" />
    </SvgIcon>
  )
}
