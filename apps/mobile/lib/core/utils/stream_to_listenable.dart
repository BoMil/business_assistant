import 'dart:async';
import 'package:flutter/material.dart';

/// Wraps one or more Streams as a ChangeNotifier so they can be used as
/// GoRouter's refreshListenable.
///
/// GoRouter only accepts a Listenable for its refreshListenable parameter, but
/// our auth state lives in a Stream (emitted by AuthCubit). This adapter
/// bridges the two: every time a Stream emits, notifyListeners() is called and
/// GoRouter re-evaluates its redirect logic.
///
/// Usage in routes.dart:
///   refreshListenable: StreamToListenable([RouterState().authCubit.stream]),
class StreamToListenable extends ChangeNotifier {
  late final List<StreamSubscription> subscriptions;

  StreamToListenable(List<Stream> streams) {
    subscriptions = [];
    for (var stream in streams) {
      // asBroadcastStream() allows multiple listeners on the same stream
      var sub = stream.asBroadcastStream().listen(_onEvent);
      subscriptions.add(sub);
    }
    // Notify immediately so the router runs redirect on first build
    notifyListeners();
  }

  @override
  void dispose() {
    for (var sub in subscriptions) {
      sub.cancel();
    }
    super.dispose();
  }

  void _onEvent(dynamic event) => notifyListeners();
}
