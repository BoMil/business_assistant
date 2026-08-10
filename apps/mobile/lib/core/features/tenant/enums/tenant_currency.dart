/// Mirrors the backend's Tenant.Currency (ISO 4217 code, e.g. "EUR", "RSD") —
/// delivered to the app via CURRENCY in the tenant's .env JSON file (same
/// build-time mechanism as TenantType, see config/tenant/tenant_config.dart).
enum TenantCurrency { eur, rsd }

TenantCurrency tenantCurrencyFromString(String raw) => switch (raw) {
      'RSD' => TenantCurrency.rsd,
      _ => TenantCurrency.eur,
    };
