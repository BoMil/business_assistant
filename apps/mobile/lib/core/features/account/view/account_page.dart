import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:business_assistant/config/translations/translation_storage.dart';
import 'package:business_assistant/core/features/authentication/cubits/user_info/user_info_cubit.dart';
import 'package:business_assistant/core/shared/pages/page_frame/page_frame.dart';
import 'package:business_assistant/core/shared/widgets/cards/card_frame.dart';
import 'package:business_assistant/core/shared/widgets/cards/selectable_item.dart';
import 'package:business_assistant/core/shared/widgets/images/loaded_image.dart';
import 'package:business_assistant/core/utils/toast_message.dart';
import 'package:business_assistant/theme/get_theme_color.dart';

/// Account tab — the logged-in user's profile (avatar, name, email, contact
/// number), sourced from UserInfoCubit. Unlike the other tabs, this page has
/// no MainHeader — there's no tenant/notifications context to show here.
class AccountPage extends StatelessWidget {
  const AccountPage({super.key});

  @override
  Widget build(BuildContext context) {
    final t = TranslationStorage.translation;
    final theme = context.colors;

    return BlocConsumer<UserInfoCubit, UserInfoState>(
      listenWhen: (previous, current) => previous.errorMessage != current.errorMessage,
      listener: (context, state) {
        if (state.errorMessage != null) {
          ToastMessage().showErrorToast(text: state.errorMessage!);
        }
      },
      builder: (context, state) {
        final fullName = [state.firstName, state.lastName].where((part) => (part ?? '').isNotEmpty).join(' ');

        return PageFrame(
          isHeaderVisible: false,
          pageBody: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 60),

                // User Image
                Center(
                  child: GestureDetector(
                    onTap: state.isUploadingImage ? null : context.read<UserInfoCubit>().pickAndUploadImage,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        LoadedImage(
                          imageUrl: state.imgUrl ?? '',
                          width: 120,
                          height: 120,
                          boxShape: BoxShape.circle,
                          alternativeWidget: CircleAvatar(
                            radius: 60,
                            backgroundColor: theme.secondaryBackground,
                            child: Icon(Icons.person, size: 56, color: theme.primaryText.withValues(alpha: 0.4)),
                          ),
                        ),
                        if (state.isUploadingImage)
                          Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.3),
                              shape: BoxShape.circle,
                            ),
                            child: const Center(child: CircularProgressIndicator(color: Colors.white)),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Center(
                  child: Text(
                    t.accountTapToChangeLabel,
                    style: TextStyle(
                      color: theme.primaryText.withValues(alpha: 0.6),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // User details
                CardFrame(
                  padding: EdgeInsets.zero,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(22),
                    child: Column(
                      children: [
                        _AccountInfoRow(title: t.accountNameLabel, value: fullName),
                        Divider(height: 1, color: theme.primaryText.withValues(alpha: 0.09)),
                        _AccountInfoRow(title: t.email, value: state.email ?? ''),
                        Divider(height: 1, color: theme.primaryText.withValues(alpha: 0.09)),
                        _AccountInfoRow(title: t.accountContactNumberLabel, value: state.phoneNumber ?? ''),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _AccountInfoRow extends StatelessWidget {
  final String title;
  final String value;

  const _AccountInfoRow({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = context.colors;
    return SelectableItem(
      title: title,
      textColor: theme.primaryText,
      fontSize: 15,
      itemPressed: () {
        // TODO: open the edit page for this field once it exists.
      },
      rightContent: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(value, style: TextStyle(color: theme.primaryText.withValues(alpha: 0.5), fontSize: 15)),
          const SizedBox(width: 6),
          Icon(Icons.chevron_right, color: theme.primaryText.withValues(alpha: 0.4)),
        ],
      ),
    );
  }
}
