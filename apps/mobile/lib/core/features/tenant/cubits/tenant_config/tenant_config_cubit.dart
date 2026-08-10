import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:business_assistant/config/tenant/tenant_config.dart';
import 'package:business_assistant/core/features/tenant/enums/tenant_currency.dart';

part 'tenant_config_state.dart';

/// Global (app-scoped) cubit exposing the tenant's currency for display —
/// see TenantConfig for how the underlying code is delivered at build time.
class TenantConfigCubit extends Cubit<TenantConfigState> {
  TenantConfigCubit() : super(_buildState());

  static TenantConfigState _buildState() {
    final currency = tenantCurrencyFromString(TenantConfig().currency);
    return TenantConfigState(currency: currency, currencySymbol: _currencySymbolFor(currency));
  }

  static String _currencySymbolFor(TenantCurrency currency) => switch (currency) {
        TenantCurrency.eur => '€',
        TenantCurrency.rsd => 'RSD',
      };
}
