$ErrorActionPreference = "Stop"
Set-Location $PSScriptRoot
if (-not (Get-Command flutter -ErrorAction SilentlyContinue)) {
  throw "Flutter no esta en PATH. Abra la terminal de Android Studio con Flutter configurado."
}
function Invoke-FlutterStep {
  param([string[]]$StepArgs)
  & flutter @StepArgs
  if ($LASTEXITCODE -ne 0) { throw "Fallo flutter $StepArgs" }
}
# Conserva el codigo y los manifiestos al generar las plataformas faltantes.
if (-not (Test-Path "android") -or -not (Test-Path "windows")) {
  $backup = Join-Path ([IO.Path]::GetTempPath()) ([guid]::NewGuid().ToString())
  New-Item -ItemType Directory -Path $backup | Out-Null
  foreach ($item in @("lib", "test", "pubspec.yaml", "pubspec.lock")) {
    Copy-Item $item $backup -Recurse
  }
  try {
    Invoke-FlutterStep -StepArgs @("create", "--project-name", "bibliotrack", "--platforms=android,windows", ".")
  } finally {
    foreach ($item in @("lib", "test")) {
      if (Test-Path $item) { Remove-Item $item -Recurse -Force }
      Copy-Item (Join-Path $backup $item) . -Recurse
    }
    foreach ($item in @("pubspec.yaml", "pubspec.lock")) {
      Copy-Item (Join-Path $backup $item) . -Force
    }
    Remove-Item $backup -Recurse -Force
  }
}
New-Item -ItemType Directory -Path evidencias -Force | Out-Null
Start-Transcript -Path "evidencias/verificacion.txt" -Force
try {
  Invoke-FlutterStep -StepArgs @("--version")
  Invoke-FlutterStep -StepArgs @("pub", "get")
  & dart run build_runner build --delete-conflicting-outputs
  if ($LASTEXITCODE -ne 0) { throw "Fallo build_runner" }
  Invoke-FlutterStep -StepArgs @("analyze")
  Invoke-FlutterStep -StepArgs @("test", "test/bibliotrack_test.dart", "-v")
  $actual = (Get-FileHash "test/bibliotrack_test.dart" -Algorithm SHA256).Hash.ToLower()
  if ($actual -ne "2f55847a23ea7ce3922b6ebda91ec890e5924e47d5d25f31f3e2bb4843afc0bf") {
    throw "El archivo de pruebas fue modificado"
  }
} finally {
  Stop-Transcript
}
Write-Host "Verificacion terminada. Ejecute flutter devices y flutter run -d ID_DISPOSITIVO."
