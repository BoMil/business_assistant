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
│   │   │   ├── pages/
│   │   │   │   └── page_frame/    # PageFrame — shared screen scaffold (header + padding)
│   │   │   └── widgets/
│   │   │       ├── buttons/       # CustomOutlinedButton, ButtonWithLoadingState
│   │   │       ├── input_fields/  # PrimaryInputField, InputLabel
│   │   │       └── screens/       # header_bar
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

These files contain real API keys/DSNs (Google Places, Sentry) and are
gitignored — only `.env/<tenant>.<environment>.json.example` (blank secret
fields) is committed. For local dev, copy the `.example` file and fill in
`GOOGLE_PLACES_API_KEY`/`SENTRY_DSN` yourself; CI does the same from GitHub
Actions secrets (see below).

`TenantConfig` (colors, name) and `FeatureFlags` (`Rental`, `Inventory`,
`Reporting`, `Poultry`, `ThemeChange`, `Language`) are kept **1:1 with the
backend's `Tenant` entity** (Identity service) — same field names on both
sides, so a tenant's branding/feature-flags mean the same thing whether they
come from a local `.env` file or from the database via CI (see below).

## Tenant branding (CI)

`scripts/set_tenant_branding.sh` runs in the GitHub Actions workflow
(`.github/workflows/mobile-android.yml`) before the build step. Given
`TENANT_ID`, `APP_NAME`, `PACKAGE_NAME`, it:

1. Validates that `assets/tenants/$TENANT_ID/{logo.png,app_icon.png,splash_logo.png}` exist
2. Ensures the tenant asset directory is listed in `pubspec.yaml`
3. Generates `flutter_launcher_icons.yaml` / `flutter_native_splash.yaml` and runs the generators

Before that, a **"Materialize env file and inject secrets"** step copies the
committed `.env/<tenant>.<environment>.json.example` template to the real
(gitignored) filename and fills in `SERVER_ADDRESS`/`SENTRY_DSN`/
`GOOGLE_PLACES_API_KEY` from GitHub Actions secrets (`SERVER_ADDRESS` is a
per-Environment secret, see below).

Right after that, an optional **"Fetch tenant config from backend"** step calls
`GET /tenants/{slug}/config` on the Identity API (protected by an `X-Api-Key`
header) and merges the tenant's live colors/feature-flags from the database
into the `.env/<tenant>.<environment>.json` file before the build — only the
overlapping keys are overwritten, so `SERVER_ADDRESS`/`ENVIRONMENT`/
`PACKAGE_NAME`/`TENANT_ID` always come from the materialized file. This step
needs the `TENANT_CONFIG_API_URL` and `TENANT_CONFIG_API_KEY` secrets; if they
aren't set it's a no-op — but then the Firebase fields stay blank and push
notifications are silently disabled in that build.

## Play Store release (CI)

Workflow: `.github/workflows/mobile-android.yml` (repo root — GitHub ignores
workflow files anywhere else). Push to `main` touching `apps/mobile/**` →
`production` build → upload to the Play **Internal testing** track. Push to
`develop` → `staging` build (artifact only). Manual run (`workflow_dispatch`)
→ pick the environment.

### GitHub secrets

Repo-level (Settings → Secrets and variables → Actions):

| Secret | Value |
|---|---|
| `ANDROID_KEYSTORE_BASE64` | `base64 -i android/upload-keystore.jks \| pbcopy` |
| `ANDROID_KEYSTORE_PASSWORD` / `ANDROID_KEY_ALIAS` / `ANDROID_KEY_PASSWORD` | from `android/key.properties` |
| `SENTRY_DSN`, `GOOGLE_PLACES_API_KEY` | same values as the local `.env` file |
| `GOOGLE_PLAY_SERVICE_ACCOUNT_JSON` | full JSON key of the Play publishing service account |

Per GitHub Environment (Settings → Environments → `production`, later `staging`):

| Secret | Value |
|---|---|
| `SERVER_ADDRESS` | Gateway base URL (no trailing slash) |
| `TENANT_CONFIG_API_URL` | Gateway base URL + `/identity` |
| `TENANT_CONFIG_API_KEY` | `CiApiKey` of that backend (Key Vault secret `ci-api-key`) |

### One-time Play Console setup

1. Create the app in Play Console (package `com.businessassistant.<tenant>`),
   fill in App content: privacy policy URL, Data safety, content rating,
   target audience, and **App access** (reviewer login — the app is login-only).
2. Run the workflow once (`workflow_dispatch`, `production`). The publish step
   fails because the app has no release yet — expected. Download the `.aab`
   from the run's artifacts and upload it **manually** to Internal testing
   (Google doesn't allow the first release via API). Using the CI-built bundle
   keeps `versionCode` (= `github.run_number`) strictly increasing.
3. Service account: Google Cloud Console → enable *Google Play Android
   Developer API* → create a service account → JSON key → Play Console →
   Users and permissions → invite its email with release permissions for the
   app. Put the JSON in `GOOGLE_PLAY_SERVICE_ACCOUNT_JSON`.
4. From then on every push to `main` lands in Internal testing; promotion to
   Closed testing / Production is done by hand in Play Console. Personal
   developer accounts must run a closed test with ≥12 testers for 14 days
   before Production access is granted.

## Localization

Source strings live in `lib/l10n/app_en.arb` and `lib/l10n/app_sr.arb`.
Generated Dart (`AppLocalizations`) is produced by `flutter gen-l10n` (configured
in `l10n.yaml`) and is **not** committed — run `fvm flutter pub get` (or
`flutter gen-l10n`) after cloning.
