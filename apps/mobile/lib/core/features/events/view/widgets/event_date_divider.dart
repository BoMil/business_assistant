import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:business_assistant/config/translations/translation_storage.dart';
import 'package:business_assistant/theme/get_theme_color.dart';

/// Divider inserted between groups of events that fall on different days on the Events list.
class EventDateDivider extends StatelessWidget {
  final DateTime date;

  const EventDateDivider({super.key, required this.date});

  @override
  Widget build(BuildContext context) {
    final theme = context.colors;
    final dividerColor = theme.primaryText.withValues(alpha: 0.09);
    final dateFormat = DateFormat('EEE, d MMM yyyy', TranslationStorage().selectedLanguage.languageCode);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Expanded(child: Divider(color: dividerColor)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              dateFormat.format(date),
              style: TextStyle(color: theme.primaryText.withValues(alpha: 0.5), fontSize: 12, fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(child: Divider(color: dividerColor)),
        ],
      ),
    );
  }
}
