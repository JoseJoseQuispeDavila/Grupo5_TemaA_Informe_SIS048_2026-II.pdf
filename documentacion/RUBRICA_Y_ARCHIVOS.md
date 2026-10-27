# Requisitos del informe - Tema A

SIS048 - Desarrollo de Software II - 2026-II.

## Correspondencia con la rúbrica

| Criterio | Puntos | Implementación o evidencia |
| --- | --- | --- |
| Corrección de errores | 5 | `lib/core/database/app_database.dart`: errores 2-7 corregidos; el marcador 1 es un falso positivo. |
| Reglas de negocio | 4 | `BookEntity` y `LoanEntity`: antigüedad, disponibilidad, año, vencimiento y devolución. |
| Repositorios | 4 | Validaciones, `Either<Failure, T>` y transacciones de préstamos y devoluciones. |
| Riverpod | 4 | Streams, filtro por género, contador y controladores. |
| Interfaz | 3 | Catálogo, alta, eliminación, préstamos y devoluciones. |
| Pruebas | 5 | 19 pruebas originales aprobadas. Falta incorporar la captura de la terminal al informe. |
| Diagramas | 4 | `casos_de_uso.png` y `clases.png`, pendientes de insertar en el informe. |
| Informe | 3 | Completar las explicaciones y reunir las capturas de funcionamiento. |

La rúbrica suma 32 puntos. La nota se calcula como `(puntaje obtenido / 32) × 20`.

## Secciones del informe

1. Análisis del código base: siete marcadores, claves foráneas y generación de código.
2. Capa Domain: métodos implementados y regla de dependencia.
3. Diagramas de casos de uso y clases, con explicación de sus relaciones.
4. Ejecución de las pruebas, resultados y explicación de las pruebas en memoria.
5. Capturas de la aplicación en funcionamiento.
6. Reflexión final y conclusiones.
7. Autoevaluación.

La plantilla incluye además los datos del estudiante, la declaración de honestidad académica y la lista de verificación de la entrega.

## Capturas pendientes

1. Terminal completa con `flutter test test/bibliotrack_test.dart -v` y el resultado de las 19 pruebas.
2. Catálogo con libros de al menos dos géneros y contador de disponibles.
3. Alta de un libro y confirmación de su eliminación.
4. Registro de un préstamo y cambio del libro a Prestado.
5. Devolución, salida de la lista de activos y cambio a Disponible.
6. Filtro por género aplicado sobre el catálogo.

Para iniciar la aplicación en Windows, use `ABRIR_BIBLIOTRACK.cmd` o `flutter run -d windows` desde la raíz del proyecto.

## Archivos de entrega

- Código: `ApellidoNombre_TemaA_SIS048_2026-II.zip`.
- Informe: `ApellidoNombre_TemaA_Informe_SIS048_2026-II.pdf`.

El ZIP debe incluir `lib/`, `test/` y `pubspec.yaml`. Para ejecutar esta versión en Windows, incluya también `pubspec.lock`, `windows/`, los iniciadores y la documentación. Excluya `build/` y `.dart_tool/`. El archivo de pruebas debe conservarse sin modificaciones.
