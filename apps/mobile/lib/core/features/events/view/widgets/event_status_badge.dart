import 'package:flutter/material.dart';
import 'package:business_assistant/config/translations/translation_storage.dart';
import 'package:business_assistant/core/features/events/models/enums/event_status.dart';
import 'package:business_assistant/theme/get_theme_color.dart';
import 'package:business_assistant/theme/theme_color.dart';

/// Colored pill showing a Rental event's derived lifecycle status
/// (Pending/InProgress/Finished/Canceled) — see EventStatus.
class EventStatusBadge extends StatelessWidget {
  final EventStatus status;

  const EventStatusBadge({super.key, required this.status});

  Color _colorFor(ThemeColor theme) => switch (status) {
        EventStatus.pending => theme.statusPending,
        EventStatus.inProgress => theme.brandPrimary,
        EventStatus.finished => theme.statusFinished,
        EventStatus.canceled => theme.brandError,
      };

  String _labelFor() => switch (status) {
        EventStatus.pending => TranslationStorage.translation.eventStatusPending,
        EventStatus.inProgress => TranslationStorage.translation.eventStatusInProgress,
        EventStatus.finished => TranslationStorage.translation.eventStatusFinished,
        EventStatus.canceled => TranslationStorage.translation.eventStatusCanceled,
      };

  @override
  Widget build(BuildContext context) {
    final color = _colorFor(context.colors);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(20)),
      child: Text(
        _labelFor(),
        style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
  }
}
