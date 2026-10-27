# BiblioTrack

Aplicación de escritorio para gestionar los libros y préstamos de una biblioteca personal. Desarrollada con Flutter, Riverpod y SQLite mediante Drift.

**Tema A · SIS048 - Desarrollo de Software II · Universidad Andina del Cusco · 2026-II**

## Funciones

- Consultar el catálogo y filtrar los libros por género.
- Agregar libros con título, autor, año y género.
- Eliminar libros con confirmación.
- Registrar préstamos de libros disponibles.
- Registrar devoluciones y actualizar la disponibilidad.
- Consultar los préstamos activos e identificar los vencidos.

El catálogo muestra el número de libros disponibles y se actualiza al registrar cambios.

## Requisitos

- Flutter y Dart disponibles en `PATH`.
- Windows con el Modo para desarrolladores activado.
- Visual Studio con la carga **Desarrollo para el escritorio con C++**, incluidas las herramientas MSVC, CMake y Windows SDK.

Verificado en Windows con Flutter **3.41.2** y Dart **3.11.0**. Las versiones de los paquetes se conservan en `pubspec.lock`.

Para revisar el entorno:

```powershell
flutter doctor -v
```

## Instalación y ejecución

Abra una terminal en la carpeta del proyecto y ejecute:

```powershell
flutter pub get --enforce-lockfile
dart run build_runner build
flutter run -d windows
```

`build_runner` genera `lib/core/database/app_database.g.dart`. Es necesario ejecutarlo después de modificar el esquema de la base de datos.

También puede iniciar la aplicación con doble clic en `ABRIR_BIBLIOTRACK.cmd`, o desde PowerShell:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\EJECUTAR_WINDOWS.ps1
```

El iniciador comprueba las dependencias, genera el archivo de Drift si falta y abre la aplicación en Windows.

## Estructura

```text
lib/
  core/
    database/       Tablas, DAOs y conexión SQLite
    di/             Registro de dependencias
    errors/         Tipos de fallos
    router/         Rutas de navegación
    usecases/       Contrato base de casos de uso
  features/books/
    domain/         Entidades y contratos de repositorios
    data/           Modelos e implementaciones de repositorios
    presentation/   Providers, controladores, pantallas y widgets
test/              Pruebas del proyecto
documentacion/     Diagramas y requisitos del informe
windows/           Plataforma de escritorio
```

Los libros y préstamos se guardan en `bibliotrack.db`, dentro del directorio de documentos de la aplicación. Los préstamos están vinculados a los libros mediante una clave foránea. Eliminar un libro también elimina sus préstamos asociados.

## Verificación

```powershell
flutter analyze
flutter test test/bibliotrack_test.dart -v
```

Resultado verificado el 27 de octubre de 2026: análisis sin problemas y **19 pruebas aprobadas**. El archivo de pruebas conserva su contenido original.

## Compilar para Windows

```powershell
flutter build windows --release
```

La compilación queda en `build/windows/x64/runner/Release/`. Para distribuir la aplicación, copie esa carpeta completa, incluido el ejecutable, las bibliotecas y `data/`.
