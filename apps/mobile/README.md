# business_assistant (mobile)

Flutter mobile client for the **Business Operations Platform** — a white-label,
multi-tenant app. The same codebase is rebranded per tenant (app name, colors,
icon, splash screen) at build time via environment config and CI.

## Tech stack

- **State management:** `flutter_bloc` (Cubit pattern)
- **Navigation:** `go_router` (declarative, with auth redirect support)
- **HTTP:** `dio`
- **Auth storage:** `flutter_secure_storage` (JWT access + refresh tokens) + `jwt_decode`
- **Localization:** ARB-based, English (`en`) and Serbian (`sr`)
- **Branding assets:** `flutter_svg`, `flutter_launcher_icons`, `flutter_native_splash`

## Project structure

```
apps/mobile/
├── android/                    # Android platform project
├── ios/                        # iOS platform project
├── assets/
│   ├── svg/                    # Shared vector assets (all tenants)
│   └── tenants/
│       └── demo/                # Per-tenant branding: logo.svg, app_icon.png, splash_logo.png
├── .env/                        # Per-tenant, per-environment config (json)
│   ├── demo.development.json
│   ├── demo.staging.json
│   └── demo.production.json
├── lib/
│   ├── main.dart                # App entry point
│   ├── config/
│   │   ├── constants/            # API endpoints, secure storage keys
│   │   ├── environment/          # Reads .env/*.json into a typed Environment
│   │   ├── routes/               # go_router setup, route names, auth redirect
│   │   ├── tenant/               # Tenant config + feature flags
│   │   └── translations/         # Language enum, translation storage
│   ├── core/
│   │   ├── features/
│   │   │   └── authentication/   # Feature module: cubits, models, views
│   │   │       ├── cubits/       # auth_cubit, login_cubit (+ states)
│   │   │       ├── models/       # requests/ and responses/
│   │   │       └── view/         # landing_page, login_page, initial_screen
│   │   ├── shared/
│   │   │   └── widgets/          # Reusable widgets (e.g. header_bar)
│   │   └── utils/
│   │       ├── api/               # api_response, dio interceptor
│   │       ├── stream_to_listenable.dart
│   │       └── toast_message.dart
│   ├── theme/                    # Colors, themes, shadows, input styles
│   └── l10n/                     # app_en.arb, app_sr.arb (source translations)
├── scripts/
│   └── set_tenant_branding.sh    # Generates launcher icons + splash per tenant (CI)
├── test/
├── pubspec.yaml
└── l10n.yaml
```

Feature modules (e.g. `authentication`) live under `lib/core/features/<feature>/`,
each split into `cubits/`, `models/`, and `view/`. New features should follow the
same layout.

## Getting started

Flutter version is pinned via [FVM](https://fvm.app/) in `.fvmrc` (`3.41.9`).

```bash
fvm install
fvm flutter pub get
fvm flutter run
```

## Environment / tenant config

Runtime config (server address, tenant id, branding colors, feature flags) is
loaded from `.env/<tenant>.<environment>.json`, e.g. `.env/demo.development.json`.
`lib/config/environment/environment.dart` reads this into a typed config, and
`lib/config/tenant/feature_flags.dart` exposes the `FEATURE_*` flags.

## Tenant branding (CI)

`scripts/set_tenant_branding.sh` runs in the GitHub Actions workflow
(`.github/workflows/mobile-android.yml`) before the build step. Given
`TENANT_ID`, `APP_NAME`, `PACKAGE_NAME`, it:

1. Validates that `assets/tenants/$TENANT_ID/{logo.svg,app_icon.png,splash_logo.png}` exist
2. Ensures the tenant asset directory is listed in `pubspec.yaml`
3. Generates `flutter_launcher_icons.yaml` / `flutter_native_splash.yaml` and runs the generators

## Localization

Source strings live in `lib/l10n/app_en.arb` and `lib/l10n/app_sr.arb`.
Generated Dart (`AppLocalizations`) is produced by `flutter gen-l10n` (configured
in `l10n.yaml`) and is **not** committed — run `fvm flutter pub get` (or
`flutter gen-l10n`) after cloning.
