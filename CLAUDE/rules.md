# Reservaditos App (Residente) — Rules

## Role
You act as a **senior mobile developer** (Flutter + Dart). You build screens that match the Figma, keep widgets small and typed, separate data, state and UI, and test logic and key widgets. If something is not in the design, follow the same visual language and write the assumption in the README.

## Product goal
Resident app for "Edificio Demo". The resident:
- **Screen 1 · Áreas del edificio:** sees the areas with fee, deposit and «Disponible hoy» / «Sin horarios hoy».
- **Screen 2 · Elegir fecha y horario:** picks a day in the month calendar and a slot (Libre / Ocupado / Elegido), sees the total and taps «Pedir reserva».
- **Screen 3 · Mi reserva:** sees the status and pays. States from the Figma: Esperando aprobación · Aprobada (deadline, countdown, «Pagar S/ 150») · Confirmada (receipt code) · Vencida · Rechazada (reason). Also Devuelta (area suspended).
- **Screen 4 · No está al día:** bottom sheet «Aún no puedes reservar» with the overdue amount and date.

The administration approves in the web; «Mi reserva» refreshes every 10 s so the change shows up on its own.

## Backend contract (repo `reservaditos-backend`, do not duplicate its rules)
- Base URL from `AppConfig` (`--dart-define=API_BASE_URL`, default `http://10.0.2.2:8000/v1` for the Android emulator). Header `x-user-id` (default `ana-perez`) is set in `apiClientProvider`.
- `GET /residents/me` · `GET /residents/me/standing` · `GET /areas` · `GET /areas/:id/availability?month` · `GET /areas/:id/slots?date` · `POST /reservations` · `GET /reservations/me` · `GET /reservations/:id` · `POST /payments/:token`
- Errors arrive as `ApiException { statusCode, code, message, details }`. Show `message`: it is already in Spanish.
- Business rules (deadlines, first request wins, grace day, refunds) live in the backend. The app displays and calls; it never re-implements them.

## Architecture (feature-first)
```
lib/
  core/       config, http (ApiClient + ApiException), router (go_router), theme (AppColors, AppTheme)
  shared/     widgets (StatusChip, AreaIcon, LoadingView, ErrorView), formatters
  features/<feature>/
    data/          models (fromJson) + repository (HTTP only, exposed with a Provider)
    application/   Riverpod providers/notifiers: state, loading, errors, polling
    presentation/  screens and widgets; read state with ref.watch, no HTTP
```
- Dependencies: `presentation → application → data → core`. Features may share models (booking returns a `Reservation`) but never screens or providers.
- State: **Riverpod 3** (`Provider`, `FutureProvider`, `Notifier`/`AsyncNotifier`). No `setState` for data coming from the backend.
- Navigation: **go_router**. Screen 4 is a bottom sheet over screen 1, not a route.

## Conventions
- **Code in English**; user-facing text in Spanish (copy from the Figma).
- Colors only from `AppColors`; text styles from the theme. Font Inter is bundled (`assets/fonts`).
- Dates: business dates are `yyyy-MM-dd` strings (`parseIsoDate`, `longDate`); instants are `DateTime` in UTC shown with `.toLocal()`. Money with `money()` → «S/ 150».
- `const` constructors, trailing commas, single quotes (see `analysis_options.yaml`).
- Accessibility: tappable areas ≥ 44 px, semantic labels on icon-only buttons.
- iOS: the code is cross-platform; it is built on macOS (Xcode) — not possible on Windows.
- Commits: Conventional Commits, no AI co-author trailers.

## Testing
- `flutter test`: formatters and models (unit), providers with fake repositories (`ProviderScope(overrides: …)`), and widget tests for each screen state.
- No real backend in tests.

## Pipeline
`.github/workflows/ci.yml` on every push and pull request: `flutter pub get` → `dart format --set-exit-if-changed` → `flutter analyze` → `flutter test` → `flutter build apk --debug`.

## Definition of Done
- Matches the Figma screenshot side by side on the emulator.
- Analyze, tests and the APK build are green.
- New assumptions are written in the README.
