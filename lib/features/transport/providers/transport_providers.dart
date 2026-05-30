import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../providers/global_providers.dart';
import '../models/bus_schedule_model.dart';
import '../models/train_schedule_model.dart';
import '../models/transport_query.dart';
import '../repositories/transport_repository.dart';

/// Injects transport repository binding.
final transportRepositoryProvider = Provider<TransportRepository>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return TransportRepositoryImpl(dioClient);
});

/// Manages active search parameters.
final transportSearchQueryProvider = StateProvider<TransportQuery>((ref) {
  return TransportQuery(
    sourceName: 'New Delhi Railway Station',
    sourceCode: 'NDLS',
    destName: 'Bhopal Junction Station',
    destCode: 'BPL',
    travelDate: DateTime.now().add(const Duration(days: 1)),
    transportType: 'all',
  );
});

/// Immutable class holding active filter selection variables.
class TransportFilterState {
  final String sortBy; // 'price', 'duration', 'departure'
  final List<String> selectedTrainCoaches;
  final List<String> selectedBusTypes;
  final double maxPrice;

  const TransportFilterState({
    this.sortBy = 'departure',
    this.selectedTrainCoaches = const [],
    this.selectedBusTypes = const [],
    this.maxPrice = 3000.0,
  });

  TransportFilterState copyWith({
    String? sortBy,
    List<String>? selectedTrainCoaches,
    List<String>? selectedBusTypes,
    double? maxPrice,
  }) {
    return TransportFilterState(
      sortBy: sortBy ?? this.sortBy,
      selectedTrainCoaches: selectedTrainCoaches ?? this.selectedTrainCoaches,
      selectedBusTypes: selectedBusTypes ?? this.selectedBusTypes,
      maxPrice: maxPrice ?? this.maxPrice,
    );
  }
}

/// Filter state manager provider.
class TransportFiltersNotifier extends StateNotifier<TransportFilterState> {
  TransportFiltersNotifier() : super(const TransportFilterState());

  void setSortBy(String sorting) {
    state = state.copyWith(sortBy: sorting);
  }

  void toggleCoach(String coach) {
    final list = List<String>.from(state.selectedTrainCoaches);
    if (list.contains(coach)) {
      list.remove(coach);
    } else {
      list.add(coach);
    }
    state = state.copyWith(selectedTrainCoaches: list);
  }

  void toggleBusType(String type) {
    final list = List<String>.from(state.selectedBusTypes);
    if (list.contains(type)) {
      list.remove(type);
    } else {
      list.add(type);
    }
    state = state.copyWith(selectedBusTypes: list);
  }

  void setMaxPrice(double price) {
    state = state.copyWith(maxPrice: price);
  }

  void reset() {
    state = const TransportFilterState();
  }
}

final transportFiltersProvider = StateNotifierProvider<TransportFiltersNotifier, TransportFilterState>((ref) {
  return TransportFiltersNotifier();
});

/// Historical searches notifier.
class SearchHistoryNotifier extends StateNotifier<List<TransportQuery>> {
  final TransportRepository _repository;

  SearchHistoryNotifier(this._repository) : super([]) {
    loadHistory();
  }

  Future<void> loadHistory() async {
    final list = await _repository.getRecentSearches();
    state = list;
  }

  Future<void> addSearch(TransportQuery query) async {
    await _repository.saveRecentSearch(query);
    await loadHistory();
  }
}

final searchHistoryProvider = StateNotifierProvider<SearchHistoryNotifier, List<TransportQuery>>((ref) {
  final repo = ref.watch(transportRepositoryProvider);
  return SearchHistoryNotifier(repo);
});

/// Future provider querying raw train schedules.
final trainResultsProvider = FutureProvider<List<TrainScheduleModel>>((ref) async {
  final query = ref.watch(transportSearchQueryProvider);
  final repo = ref.watch(transportRepositoryProvider);

  if (!query.isValid) return [];
  return repo.searchTrains(query);
});

/// Future provider querying raw bus schedules.
final busResultsProvider = FutureProvider<List<BusScheduleModel>>((ref) async {
  final query = ref.watch(transportSearchQueryProvider);
  final repo = ref.watch(transportRepositoryProvider);

  if (!query.isValid) return [];
  return repo.searchBuses(query);
});

/// Dynamic provider delivering sorted and filtered trains list.
final filteredTrainsProvider = Provider<List<TrainScheduleModel>>((ref) {
  final rawTrains = ref.watch(trainResultsProvider).value ?? [];
  final filters = ref.watch(transportFiltersProvider);

  var list = List<TrainScheduleModel>.from(rawTrains);

  // Apply Coach tier filters (match if train has any selected coach)
  if (filters.selectedTrainCoaches.isNotEmpty) {
    list = list.where((train) {
      return train.coachesAvailable.any((c) => filters.selectedTrainCoaches.contains(c));
    }).toList();
  }

  // Apply price filters (match base fares <= maxPrice)
  list = list.where((train) {
    final minimumFare = train.baseFares.values.reduce((min, val) => val < min ? val : min);
    return minimumFare <= filters.maxPrice;
  }).toList();

  // Apply sorting algorithms
  if (filters.sortBy == 'price') {
    list.sort((a, b) {
      final minA = a.baseFares.values.reduce((min, val) => val < min ? val : min);
      final minB = b.baseFares.values.reduce((min, val) => val < min ? val : min);
      return minA.compareTo(minB);
    });
  } else if (filters.sortBy == 'duration') {
    list.sort((a, b) => a.durationMinutes.compareTo(b.durationMinutes));
  } else {
    // Departure sorting
    list.sort((a, b) => a.departureTime.compareTo(b.departureTime));
  }

  return list;
});

/// Dynamic provider delivering sorted and filtered buses list.
final filteredBusesProvider = Provider<List<BusScheduleModel>>((ref) {
  final rawBuses = ref.watch(busResultsProvider).value ?? [];
  final filters = ref.watch(transportFiltersProvider);

  var list = List<BusScheduleModel>.from(rawBuses);

  // Apply Bus Operator/Type filters
  if (filters.selectedBusTypes.isNotEmpty) {
    list = list.where((bus) {
      return filters.selectedBusTypes.any((t) => bus.busType.toLowerCase().contains(t.toLowerCase()));
    }).toList();
  }

  // Apply price filters
  list = list.where((bus) => bus.fareAmount <= filters.maxPrice).toList();

  // Apply sorting algorithms
  if (filters.sortBy == 'price') {
    list.sort((a, b) => a.fareAmount.compareTo(b.fareAmount));
  } else if (filters.sortBy == 'duration') {
    list.sort((a, b) => a.durationMinutes.compareTo(b.durationMinutes));
  } else {
    list.sort((a, b) => a.departureTime.compareTo(b.departureTime));
  }

  return list;
});
