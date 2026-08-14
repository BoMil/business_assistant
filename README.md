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

First time only — Docker containers can't read your `dotnet user-secrets`, so Business's Blob Storage connection string is passed in via a gitignored `.env` file instead:

```bash
cp .env.example .env
# then edit .env and paste your real Azure Storage connection string
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

The Business service uploads images (e.g. asset photos) to Azure Blob Storage. Each tenant gets its own container (`tenant-{tenantId}`), created automatically on first upload — so no two clients share the same container.

`appsettings.json` only ever holds placeholder values (`BlobStorage:ConnectionString`, `Jwt:Secret`, etc.) — real secrets never go into the repo. Locally, each developer sets their own values via `dotnet user-secrets`, which stores them outside the repo (per machine, keyed by the project's `UserSecretsId`):

```bash
cd apps/backend/services/Business/Business.API
dotnet user-secrets set "BlobStorage:ConnectionString" "<your-azure-storage-connection-string>"
```

This is picked up automatically when running in the `Development` environment (the local default) — no other setup needed. In production, these values come from Key Vault / App Service configuration instead of a file.

When running via `docker compose` instead, the container can't see your host's user-secrets, so the same connection string is passed via the gitignored `.env` file (see "Whole backend stack" above) — `docker-compose.override.yml` maps it to `BlobStorage__ConnectionString`.

## Roadmap

| Phase | Features |
|-------|----------|
| V1    | Identity, Tenants, Assets, Transactions, Dashboard, Reporting |
| V2    | Inventory, Events, Customers |
| V3    | Poultry (egg production, feed consumption, recipes, sales) |
