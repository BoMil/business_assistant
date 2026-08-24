import 'package:business_assistant/core/shared/enums/cubit_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:business_assistant/config/tenant/tenant_config.dart';
import 'package:business_assistant/config/translations/translation_storage.dart';
import 'package:business_assistant/core/features/authentication/cubits/user_info/user_info_cubit.dart';
import 'package:business_assistant/core/shared/widgets/images/loaded_image.dart';
import 'package:business_assistant/theme/get_theme_color.dart';
import 'package:business_assistant/theme/theme_constants.dart';
import 'package:skeletonizer/skeletonizer.dart';

/// Header shown at the top of the Events/Inventory/Clients tabs — tenant
/// logo + name on the left, notifications and the user's avatar on the right.
///
/// Meant to be passed to PageFrame's `pageHeader` slot, which pins it above
/// pageBody so the page's own scrolling never carries the header away.
///
/// Notifications and the avatar have no backend support yet: the bell shows
/// a "Coming soon" toast on tap, and the avatar falls back to a generic
/// person icon since there's no user profile image to load.
class MainHeader extends StatelessWidget {
  const MainHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final tenant = TenantConfig();
    final theme = context.colors;
    final firstName = context.watch<UserInfoCubit>().state.firstName;
    final String userImageUrl = context.watch<UserInfoCubit>().state.imgUrl ?? '';
    final t = TranslationStorage.translation;

    return Container(
      decoration: BoxDecoration(
        color: theme.baseWhite,
        border: Border(bottom: BorderSide(color: theme.primaryText.withValues(alpha: 0.08))),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 10, offset: const Offset(0, 3))],
      ),
      padding: const EdgeInsets.symmetric(horizontal: ThemeConstants.headerPadding, vertical: 12),
      child: Row(
        children: [
          // SvgPicture.asset(tenant.logoPath, height: 32),
          Image.asset(tenant.logoPath, height: 32),

          const SizedBox(width: 10),
          Expanded(
            child: Skeletonizer(
              enabled: context.watch<UserInfoCubit>().state.currentState == CubitState.loading,
              child: Text(
                firstName != null ? t.welcomeUser(firstName) : t.welcomeGeneric,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: theme.primaryText),
              ),
            ),
          ),
          // const SizedBox(width: 10),
          // SelectableIcon(
          //   padding: const EdgeInsets.all(8),
          //   itemPressed: () => ToastMessage().showInfoToast(text: t.notificationsComingSoonToast),
          //   iconWidget: SvgPicture.asset(
          //     'assets/svg/notification_bell.svg',
          //     width: 20,
          //     height: 20,
          //     colorFilter: ColorFilter.mode(theme.primaryText, BlendMode.srcIn),
          //   ),
          // ),
          const SizedBox(width: 10),
          LoadedImage(
            imageUrl: userImageUrl,
            width: 36,
            height: 36,
            boxShape: BoxShape.circle,
            alternativeWidget: CircleAvatar(
              radius: 18,
              backgroundColor: theme.secondaryBackground,
              child: Icon(Icons.person, size: 20, color: theme.primaryText.withValues(alpha: 0.5)),
            ),
          ),
          // const SizedBox(width: 10),
          // const LanguageSwitcher(),
        ],
      ),
    );
  }
}
