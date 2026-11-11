<p align="center">
  <img src="https://cdn.simpleicons.org/flutter/02569B" width="72" alt="Flutter logo" />
</p>

<h1 align="center">Reservaditos — App del residente</h1>

<p align="center">
  <a href="https://github.com/kingperseocs/reservaditos-mobileapp/actions/workflows/ci.yml"><img src="https://github.com/kingperseocs/reservaditos-mobileapp/actions/workflows/ci.yml/badge.svg" alt="CI" /></a>
  <img src="https://img.shields.io/badge/Flutter-3.47-02569B?logo=flutter&logoColor=white" alt="Flutter 3.47" />
  <img src="https://img.shields.io/badge/Dart-3.13-0175C2?logo=dart&logoColor=white" alt="Dart 3.13" />
  <img src="https://img.shields.io/badge/Riverpod-3-00B4D8" alt="Riverpod 3" />
  <img src="https://img.shields.io/badge/Android-✓-3DDC84?logo=android&logoColor=white" alt="Android" />
  <img src="https://img.shields.io/badge/iOS-código_listo-000000?logo=apple&logoColor=white" alt="iOS" />
  <a href="LICENSE"><img src="https://img.shields.io/badge/license-MIT-blue" alt="License: MIT" /></a>
</p>

App del residente del **Edificio Demo**: ve las áreas comunes, elige fecha y horario, pide la reserva, sigue su estado mientras la administración la revisa y paga con el link cuando la aprueban. Consume la API de [reservaditos-backend](https://github.com/kingperseocs/reservaditos-backend); la administración aprueba en [reservaditos-webapp](https://github.com/kingperseocs/reservaditos-webapp).

## Requisitos
- Flutter **3.47.9** (stable, la misma versión fija del CI) · Dart 3.13
- Android Studio (SDK y emulador) · VS Code con la extensión Flutter
- El backend corriendo en tu PC en el puerto 8000 (ver su README)

## Cómo correrlo
```bash
flutter pub get
flutter emulators --launch Pixel_9_Pro
flutter run
```
Desde el emulador de Android, `10.0.2.2` es tu PC, así que la app llega al backend en `http://10.0.2.2:8000/v1` sin configurar nada.

Otros casos, con `--dart-define`:
```bash
# Celular físico en la misma red Wi-Fi (usa la IP de tu PC)
flutter run --dart-define=API_BASE_URL=http://192.168.1.50:8000/v1

# Probar como la residente con cuota vencida
flutter run --dart-define=RESIDENT_ID=rosa-medina
```

## Tests
```bash
flutter analyze
flutter test
```
El workflow `.github/workflows/ci.yml` corre formato, análisis, tests y el build del APK en cada push.

## Estructura
```
lib/
  core/       configuración, cliente HTTP, rutas, tema (colores del Figma, Inter)
  shared/     widgets y formateadores reutilizables
  features/
    areas/        pantalla 1 · Áreas del edificio
    booking/      pantalla 2 · Elegir fecha y horario
    reservation/  pantalla 3 · Mi reserva (estados y pago)
    standing/     pantalla 4 · No está al día
```
Cada feature tiene `data/` (modelos + repositorio HTTP), `application/` (estado con Riverpod) y `presentation/` (pantallas y widgets).

## Android e iOS
El código es uno solo para ambas plataformas. Se desarrolló y probó en **Android** (emulador Pixel 9 Pro) desde Windows 11. Compilar para **iOS** requiere macOS con Xcode (`flutter run` en el simulador de iPhone o `flutter build ipa`); el proyecto `ios/` ya está configurado y no necesita cambios de código.

## Pantallas
| # | Pantalla | Qué hace |
|---|---|---|
| 1 | Áreas del edificio | Áreas con tarifa, garantía y «Disponible hoy» / «Sin horarios hoy». Si hay una reserva en curso, muestra «Tu reserva» arriba. |
| 2 | Elegir fecha y horario | Calendario del mes (puntos verdes = días con horarios), horarios Libre / Ocupado / Elegido, total y «Pedir reserva». |
| 3 | Mi reserva | Esperando aprobación · Aprobada (hora límite, contador y «Pagar S/ 150») · Confirmada (comprobante) · Vencida · Rechazada (motivo) · Devuelta. **Se actualiza sola cada 10 s**, así que cuando la administración aprueba en la web, la app lo muestra sin recargar. |
| 4 | No está al día | Al tocar «Reservar», la app consulta al backend; si hay una cuota vencida (pasado el día de gracia) muestra «Aún no puedes reservar» con el monto y la fecha. |

Flujo de punta a punta: **pides en la app → la solicitud aparece en la web → la administración aprueba → la app pasa sola a «Aprobada» → pagas → «Confirmada» con código.**

## Decisiones y supuestos
- **Sin login.** Igual que el backend y la web: la identidad va en el header `x-user-id` (por defecto `ana-perez`, configurable con `--dart-define=RESIDENT_ID`).
- **Hora del edificio.** Las horas (límite de pago, comprobante) y el «hoy» del calendario se muestran en hora de Lima (UTC−5), como el backend, sin importar la zona horaria del teléfono. El emulador de Android viene en UTC y sin esto mostraba horas equivocadas.
- **Actualización por polling (10 s)** en «Mi reserva» mientras la reserva espera aprobación o pago; se detiene en los estados finales. No hacen falta notificaciones push para la prueba.
- **Pago simulado.** «Pagar S/ 150» usa el link de pago que entrega el backend al aprobar (`POST /payments/{token}`); no hay pasarela real.
- **«Tu reserva» en la pantalla 1** no está en el Figma: sin ese acceso, si el residente sale de «Mi reserva» no puede volver a ver el estado ni pagar.
- **Estado «Devuelta»** no está entre los 5 del Figma; lo produce el backend cuando la administración suspende el área (regla 6) y sigue el mismo estilo.
- **«Ver mi cuota»** (pantalla 4): el backend no tiene pago de cuotas; cierra la hoja y avisa que estará disponible pronto.
- **Las reglas viven en el backend.** La app no calcula plazos ni prioridades: muestra lo que responde la API y su mensaje de error en español.
- **Fuente Inter incluida en la app** (no se descarga), para que funcione sin internet y en los tests.

## Cómo usé IA mientras programaba
Usé **Claude Code** como asistente, por pasos y con revisión mía antes de avanzar:

- **Reglas para la IA en el repo:** [CLAUDE/rules.md](CLAUDE/rules.md) define rol, objetivo, contrato con el backend, arquitectura por features con Riverpod y convenciones.
- **Teoría y entorno primero:** antes de programar repasamos cómo funciona Flutter, por qué iOS no se compila en Windows y cómo llega el emulador al backend (`10.0.2.2`); preparé el entorno (Flutter 3.47, licencias, emulador).
- **Pantallas contra el backend real:** cada pantalla se probó en el emulador, comparando con su captura del Figma, y el flujo completo se recorrió con la web de la administración aprobando de verdad.
- **Bugs encontrados en esas pruebas:** horas en UTC en vez de hora de Lima, la tarjeta «Tu reserva» que no se refrescaba, un spinner que seguía girando detrás de la hoja de la pantalla 4 y textos que se desbordaban en pantallas angostas o con letra grande.
- **Tests:** formateadores, modelos y widget tests de cada pantalla y estado con repositorios falsos (sin backend).

Lo que no delegué: las decisiones de alcance y diseño, la revisión del código y las pruebas finales.

> Reglas del proyecto para el desarrollo asistido: [CLAUDE/rules.md](CLAUDE/rules.md).

## Licencia
Distribuido bajo la licencia [MIT](LICENSE). La fuente Inter se distribuye bajo la [SIL Open Font License](assets/fonts/OFL.txt).
