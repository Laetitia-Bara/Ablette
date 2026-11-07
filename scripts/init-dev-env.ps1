[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
$taskRepository = Split-Path -Parent $PSScriptRoot
$taskEnvPath = Join-Path $taskRepository '.env'
if (Test-Path -LiteralPath $taskEnvPath) {
    Write-Output '.env existe déjà : configuration conservée.'
    exit 0
}
$taskRandomBytes = New-Object byte[] 32
$taskRandom = [System.Security.Cryptography.RandomNumberGenerator]::Create()
try { $taskRandom.GetBytes($taskRandomBytes) } finally { $taskRandom.Dispose() }
$taskDatabasePassword = -join ($taskRandomBytes | ForEach-Object { $_.ToString('x2') })
$taskConfiguration = @"
# Local development only. Never commit this file.
POSTGRES_DB=ablette
POSTGRES_USER=ablette
POSTGRES_PASSWORD=$taskDatabasePassword
APP_PORT=8081
API_PORT=8080
DB_PORT=5432
"@
[System.IO.File]::WriteAllText($taskEnvPath, $taskConfiguration + "`n", [System.Text.UTF8Encoding]::new($false))
Write-Output '.env créé avec un mot de passe aléatoire. Aucun secret affiché.'
