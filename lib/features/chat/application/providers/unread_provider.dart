import 'package:flutter_riverpod/flutter_riverpod.dart';

final friendUnreadProvider = StateNotifierProvider<UnreadNotifier, Map<int, int>>(
  (ref) => UnreadNotifier(),
);

final groupUnreadProvider = StateNotifierProvider<UnreadNotifier, Map<int, int>>(
  (ref) => UnreadNotifier(),
);

class UnreadNotifier extends StateNotifier<Map<int, int>> {
  UnreadNotifier() : super({});

  // Increment unread count for a given ID (friend or group)
  void increment(int id) {
    state = {
      ...state,
      id: (state[id] ?? 0) + 1,
    };
  }

  // Clear unread count for a given ID (on chat open)
  void clear(int id) {
    if (state.containsKey(id)) {
      final updated = Map<int, int>.from(state);
      updated.remove(id);
      state = updated;
    }
  }

  // Set count directly (used for missed messages)
  void setCount(int id, int count) {
    state = {
      ...state,
      id: count,
    };
  }

  // Clear all (e.g. on logout)
  void clearAll() {
    state = {};
  }
}
