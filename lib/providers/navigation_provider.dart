import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Navigation controller state manager for the main Traveler Bottom Tab Bar.
class TravelerNavNotifier extends StateNotifier<int> {
  TravelerNavNotifier() : super(0);

  void setIndex(int index) {
    state = index;
  }

  void reset() {
    state = 0;
  }
}

final travelerNavProvider = StateNotifierProvider<TravelerNavNotifier, int>((ref) {
  return TravelerNavNotifier();
});

/// Navigation controller state manager for the Worker Bottom Tab Bar.
class WorkerNavNotifier extends StateNotifier<int> {
  WorkerNavNotifier() : super(0);

  void setIndex(int index) {
    state = index;
  }

  void reset() {
    state = 0;
  }
}

final workerNavProvider = StateNotifierProvider<WorkerNavNotifier, int>((ref) {
  return WorkerNavNotifier();
});
