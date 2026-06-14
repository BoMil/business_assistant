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

## Roadmap

| Phase | Features |
|-------|----------|
| V1    | Identity, Tenants, Assets, Transactions, Dashboard, Reporting |
| V2    | Inventory, Events, Customers |
| V3    | Poultry (egg production, feed consumption, recipes, sales) |
