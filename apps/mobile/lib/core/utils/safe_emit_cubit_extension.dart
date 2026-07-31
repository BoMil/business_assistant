import 'package:flutter_bloc/flutter_bloc.dart';

/// Emits only if the cubit hasn't been closed yet.
///
/// Needed by PaginationCubitBase subclasses: a page fetch is in flight, the
/// user navigates away (closing the cubit), then the response arrives and
/// tries to emit — without this guard that throws "Cannot emit new states
/// after calling close".
extension SafeEmitCubitExtension<S> on Cubit<S> {
  void safeEmit(S state) {
    if (isClosed) return;
    // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
    emit(state);
  }
}
