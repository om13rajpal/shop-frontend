import 'package:flutter_riverpod/flutter_riverpod.dart';

class WorkerNotifier extends StateNotifier<List<dynamic>> {
  WorkerNotifier() : super([]);

  void setWorkers(List<dynamic> workers) {
    state = workers;
  }

  void remove(dynamic id) {
    state = state.where((object) => id != object['id']).toList();
  }
}

final workerProvider = StateNotifierProvider<WorkerNotifier, List<dynamic>>(
  (ref) => WorkerNotifier(),
);
