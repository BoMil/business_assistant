# Business Assistant

A multi-tenant business operations platform for tracking assets, transactions, inventory, production, and reporting through a flexible modular system.

## Architecture

- **Backend**: .NET 8+, microservices, Clean Architecture + CQRS
- **Web**: Angular (latest), feature-based
- **Mobile**: Flutter (latest), feature-based, white-label support

## Repository Structure

```
business_assistant/
│
├── apps/
│   ├── backend/
│   │   ├── gateway/              # API Gateway
│   │   ├── services/
│   │   │   ├── identity-service/ # Auth, users, tenants
│   │   │   ├── business-service/ # Assets, transactions, inventory, events
│   │   │   ├── poultry-service/  # Egg production, feed, recipes
│   │   │   └── reporting-service/# Reports and analytics
│   │   └── shared/               # Shared contracts, events, common
│   ├── web/                      # Angular web app
│   └── mobile/                   # Flutter mobile app
│
├── docs/                         # Architecture diagrams, API docs
├── infrastructure/               # Docker, k8s, CI/CD configs
├── scripts/                      # Dev utility scripts
└── README.md
```

## Running Locally

**Prerequisites**: Docker Desktop, .NET 8 SDK. [Azure Data Studio](https://azure.microsoft.com/products/data-studio) is recommended for inspecting the database on Mac/Linux (no SSMS there).

### Whole backend stack (DB + both APIs + Gateway)

First time only — Docker containers can't read your `dotnet user-secrets`, so Business's Blob Storage connection string and the Sentry DSN are passed in via a gitignored `.env` file instead:

```bash
cp .env.example .env
# then edit .env and paste your real Azure Storage connection string and Sentry DSN
```

```bash
docker compose up --build
```

- API Gateway: http://localhost:5099 — **this is the only address the mobile/web app needs to know.** It routes `/identity/**` → Identity and `/business/**` → Business (see `apps/backend/gateway/Gateway.API`).
- Identity API (direct, for its own Swagger): http://localhost:5100/swagger
- Business API (direct, for its own Swagger): http://localhost:5101/swagger
- Stop: `docker compose down` (add `-v` to also wipe the DB data)

### Running a single microservice (DB in Docker, API on host)

Faster iteration/debugging than rebuilding the whole stack — start only the DB container:

```bash
docker compose up -d ba-db
```

Then run any service directly, e.g.:

```bash
cd apps/backend/services/Business/Business.API
dotnet run
```

(or hit Run/Debug in your IDE). Each service's `appsettings.Development.json` already points at `localhost,1433` with the `ba-db` container's SQL auth credentials, so no extra config is needed. EF Core migrations are applied automatically on startup.

If you also want to go through the Gateway while running services this way, run it the same way — its `appsettings.Development.json` already points at `http://localhost:5100`/`5101`:

```bash
cd apps/backend/gateway/Gateway.API
dotnet run
```

### Inspecting the database (Azure Data Studio)

Connect with:

- Server: `localhost,1433`
- Authentication type: SQL Login
- User: `SA`
- Password: `Password@12345#`
- Enable "Trust server certificate"

Each microservice has its own database on the same server: `IdentityDb`, `BusinessDb`.

## Blob Storage & Secrets

Both Business (e.g. asset photos) and Identity (user profile pictures) upload images to Azure Blob Storage via the shared `Shared.Infrastructure` blob service. Each tenant gets its own container (`tenant-{tenantId}`), created automatically on first upload — so no two clients share the same container.

`appsettings.json` only ever holds placeholder values (`BlobStorage:ConnectionString`, `Jwt:Secret`, etc.) — real secrets never go into the repo. Locally, each developer sets their own values via `dotnet user-secrets`, which stores them outside the repo (per machine, keyed by the project's `UserSecretsId`):

```bash
cd apps/backend/services/Business/Business.API
dotnet user-secrets set "BlobStorage:ConnectionString" "<your-azure-storage-connection-string>"
```

```bash
cd apps/backend/services/Identity/Identity.API
dotnet user-secrets set "BlobStorage:ConnectionString" "<your-azure-storage-connection-string>"
```

This is picked up automatically when running in the `Development` environment (the local default) — no other setup needed. In production, these values come from Key Vault / App Service configuration instead of a file.

When running via `docker compose` instead, the container can't see your host's user-secrets, so the same connection string is passed via the gitignored `.env` file (see "Whole backend stack" above) — `docker-compose.override.yml` maps it to `BlobStorage__ConnectionString`.

## Error Tracking (Sentry)

Identity and Business report unhandled exceptions and `LogError`/`LogCritical` calls to a shared backend Sentry project (via `Sentry.AspNetCore`, wired through `Shared.Presentation`'s `UseSentryIfEnabled()`) — `ServerName` is set to `"Identity"`/`"Business"` so events are distinguishable in the dashboard. **It's disabled in the `Development` environment**, so it won't fire during ordinary local development even with a DSN configured.

Same secrets pattern as Blob Storage above:

```bash
cd apps/backend/services/Business/Business.API
dotnet user-secrets set "Sentry:Dsn" "<your-sentry-dsn>"
```

```bash
cd apps/backend/services/Identity/Identity.API
dotnet user-secrets set "Sentry:Dsn" "<your-sentry-dsn>"
```

To actually see it report locally, run with a non-Development environment, e.g. `ASPNETCORE_ENVIRONMENT=Staging dotnet run`. Via `docker compose`, the DSN comes from the gitignored `.env` file (see "Whole backend stack" above) — `docker-compose.override.yml` maps it to `Sentry__Dsn`.

## Push Notifications

Firebase Cloud Messaging, one Firebase project per tenant (`Tenant.FirebaseConfig`, service-account credential encrypted at rest via `IDataProtector`). On login, the mobile app registers its FCM device token (`POST /identity/users/me/device-tokens`) — a user can have several (multi-device). Mobile shows the notification both in the background (FCM's default OS handling) and in the foreground (`flutter_local_notifications`, since FCM doesn't auto-display while the app is active).

Beyond that manual/per-user path, the system also broadcasts automatically: when any user creates an Event (Transaction) or Asset, every other user of that tenant gets pushed a notification — regardless of whether they're currently logged in, since it targets their stored device tokens, not an active session. This crosses a service boundary (Business creates the entity, Identity owns the push infrastructure), so it goes over a message bus (RabbitMQ + MassTransit) instead of a direct HTTP call:

1. Business publishes `TenantNotificationRequested` (tenant id, creator's user id to exclude, title, body) after saving.
2. Identity consumes it, looks up every device token belonging to that tenant except the creator's, and sends a push to each via Firebase.

See `CLAUDE.md`'s "Cross-service communication" section for why an event bus was chosen here instead of a synchronous internal endpoint.

## Roadmap

| Phase | Features |
|-------|----------|
| V1    | Identity, Tenants, Assets, Transactions, Dashboard, Reporting |
| V2    | Inventory, Events, Customers |
| V3    | Poultry (egg production, feed consumption, recipes, sales) |
