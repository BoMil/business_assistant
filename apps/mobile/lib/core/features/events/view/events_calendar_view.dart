import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:business_assistant/config/routes/route_names.dart';
import 'package:business_assistant/core/features/events/cubits/events_calendar/events_calendar_cubit.dart';
import 'package:business_assistant/core/features/events/models/enums/event_status.dart';
import 'package:business_assistant/core/features/events/models/page_props/event_preview_page_props.dart';
import 'package:business_assistant/core/features/events/models/responses/event_response.dart';
import 'package:business_assistant/core/shared/enums/cubit_state.dart';
import 'package:business_assistant/theme/get_theme_color.dart';
import 'package:business_assistant/theme/theme_color.dart';

/// Events tab — Calendar view: a month grid with each day's events shown as
/// small colored chips (grouped by day server-side via EventsCalendarCubit).
/// Self-contained: owns its own cubit, unrelated to the List tab's EventsCubit.
class EventsCalendarView extends StatelessWidget {
  const EventsCalendarView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<EventsCalendarCubit>(
      create: (_) => EventsCalendarCubit()..loadMonth(DateTime.now()),
      child: const _EventsCalendarContent(),
    );
  }
}

class _EventsCalendarContent extends StatelessWidget {
  const _EventsCalendarContent();

  DateTime _dayKey(DateTime day) => DateTime(day.year, day.month, day.day);

  // Row height grows with the busiest day in the visible month so every
  // event chip fits without cropping (rowHeight is uniform across the grid).
  static const double _baseCellHeight = 40;
  static const double _chipHeight = 26;

  @override
  Widget build(BuildContext context) {
    final theme = context.colors;

    return BlocBuilder<EventsCalendarCubit, EventsCalendarState>(
      builder: (context, state) {
        final maxEventsPerDay = state.eventsByDay.values.fold<int>(
          0,
          (max, events) => events.length > max ? events.length : max,
        );
        final rowHeight = math.max(60.0, _baseCellHeight + maxEventsPerDay * _chipHeight);

        return SingleChildScrollView(
          child: Column(
            children: [
              TableCalendar<EventResponse>(
                firstDay: DateTime.utc(2020, 1, 1),
                lastDay: DateTime.utc(2035, 12, 31),
                focusedDay: state.focusedMonth,
                calendarFormat: CalendarFormat.month,
                rowHeight: rowHeight,
                daysOfWeekHeight: 24,
                headerStyle: const HeaderStyle(formatButtonVisible: false, titleCentered: true),
                calendarStyle: const CalendarStyle(markersMaxCount: 0),
                onPageChanged: (focusedDay) => context.read<EventsCalendarCubit>().loadMonth(focusedDay),
                eventLoader: (day) => state.eventsByDay[_dayKey(day)] ?? const [],
                calendarBuilders: CalendarBuilders(
                  defaultBuilder:
                      (context, day, focusedDay) =>
                          _DayCell(day: day, events: state.eventsByDay[_dayKey(day)] ?? const []),
                  todayBuilder:
                      (context, day, focusedDay) =>
                          _DayCell(day: day, events: state.eventsByDay[_dayKey(day)] ?? const [], isToday: true),
                  outsideBuilder: (context, day, focusedDay) => _DayCell(day: day, events: const [], isOutside: true),
                ),
              ),
              if (state.currentState == CubitState.error)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Text(state.errorMessage ?? '', style: TextStyle(color: theme.brandError)),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _DayCell extends StatelessWidget {
  final DateTime day;
  final List<EventResponse> events;
  final bool isToday;
  final bool isOutside;

  const _DayCell({required this.day, required this.events, this.isToday = false, this.isOutside = false});

  Color _colorFor(ThemeColor theme, EventStatus? status) => switch (status) {
    EventStatus.pending => theme.statusPending,
    EventStatus.inProgress => theme.brandPrimary,
    EventStatus.finished => theme.statusFinished,
    EventStatus.canceled => theme.brandError,
    null => theme.brandPrimary,
  };

  @override
  Widget build(BuildContext context) {
    final theme = context.colors;

    return Container(
      margin: const EdgeInsets.all(0.5),
      padding: const EdgeInsets.all(1),
      decoration: BoxDecoration(
        border: Border.all(color: theme.primaryText.withValues(alpha: 0.08)),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 20,
            height: 20,
            alignment: Alignment.center,
            decoration: isToday ? BoxDecoration(color: theme.brandPrimary, shape: BoxShape.circle) : null,
            child: Text(
              '${day.day}',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color:
                    isToday
                        ? Colors.white
                        : isOutside
                        ? theme.primaryText.withValues(alpha: 0.3)
                        : theme.primaryText,
              ),
            ),
          ),
          const SizedBox(height: 2),
          for (final event in events) _EventChip(event: event, color: _colorFor(theme, event.status)),
        ],
      ),
    );
  }
}

class _EventChip extends StatelessWidget {
  final EventResponse event;
  final Color color;

  const _EventChip({required this.event, required this.color});

  Future<void> _openPreview(BuildContext context) async {
    final cubit = context.read<EventsCalendarCubit>();
    final saved = await context.push<bool>(RouteNames.eventPreviewPage, extra: EventPreviewPageProps(event: event));
    if (saved == true) cubit.loadMonth(cubit.state.focusedMonth);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _openPreview(context),
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 1),
        padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 1),
        decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(3)),
        child: Text(
          event.title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: color, height: 1.1),
        ),
      ),
    );
  }
}
