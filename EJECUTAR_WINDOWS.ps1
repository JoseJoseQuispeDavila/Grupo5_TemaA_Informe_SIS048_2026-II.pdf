$ErrorActionPreference = 'Stop'
Set-Location -LiteralPath $PSScriptRoot

function Invoke-ProjectCommand {
    param([string]$Program, [string[]]$CommandArgs)
    & $Program @CommandArgs
    if ($LASTEXITCODE -ne 0) {
        throw "Fallo el comando: $Program $($CommandArgs -join ' ')"
    }
}

try {
    if (-not (Get-Command flutter -ErrorAction SilentlyContinue)) {
        throw 'Flutter no esta en PATH. Agregue la carpeta flutter\bin y vuelva a abrir la terminal.'
    }
    if (-not (Test-Path -LiteralPath 'windows\CMakeLists.txt')) {
        throw 'No se encuentra la plataforma Windows del proyecto.'
    }

    Invoke-ProjectCommand -Program 'flutter' -CommandArgs @('pub', 'get', '--enforce-lockfile')
    if (-not (Test-Path -LiteralPath 'lib\core\database\app_database.g.dart')) {
        Invoke-ProjectCommand -Program 'dart' -CommandArgs @('run', 'build_runner', 'build')
    }
    Invoke-ProjectCommand -Program 'flutter' -CommandArgs @('run', '-d', 'windows')
} catch {
    Write-Host "`nNo se pudo iniciar BiblioTrack: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host 'Si Flutter indica que faltan herramientas de Visual Studio, instale Desarrollo para el escritorio con C++.'
    Write-Host 'Si indica que faltan enlaces simbolicos (symlink), active Modo para desarrolladores en Configuracion de Windows.'
    exit 1
}
