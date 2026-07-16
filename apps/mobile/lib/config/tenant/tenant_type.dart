/// Mirrors the backend's Identity.Domain.Enums.TenantType — classifies what kind
/// of business the tenant runs. Delivered at build time via TENANT_TYPE in the
/// tenant's .env JSON file (same mechanism as the other tenant/feature config),
/// fetched from the backend by set_tenant_branding.sh before the build runs.
///
/// Only used to decide which pages/tabs the app was built with — it does not
/// gate anything at runtime. FeatureFlags (see feature_flags.dart) still control
/// which of those tabs are actually shown, since flags can be toggled per-tenant
/// independently of this type.
enum TenantType { rental, farming }

TenantType tenantTypeFromString(String raw) => switch (raw) {
      'Farming' => TenantType.farming,
      _ => TenantType.rental,
    };
