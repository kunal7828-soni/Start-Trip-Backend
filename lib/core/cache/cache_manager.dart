import '../utils/logger.dart';

/// Clean Architecture core caching engine.
/// Handles high-performance in-memory caching of search histories, popular routes,
/// and stops metadata to guarantee instant state management without package overhead.
class CacheManager {
  static final CacheManager _instance = CacheManager._internal();
  factory CacheManager() => _instance;
  CacheManager._internal();

  final Map<String, dynamic> _memoryCache = {};

  /// Initialize and load persistent cache parameters.
  Future<void> init() async {
    // In-memory cache manager ready. No external database drivers needed.
    AppLogger.i('High-performance In-Memory Session Cache initialized successfully.');
    
    // Seed default search history for visual demo polish
    write('search_history', [
      {'source': 'NDLS', 'source_name': 'New Delhi Railway Station', 'dest': 'BPL', 'dest_name': 'Bhopal Junction', 'type': 'train'},
      {'source': 'BOM', 'source_name': 'Mumbai Central Terminal', 'dest': 'MAO', 'dest_name': 'Madgaon Station', 'type': 'train'},
      {'source': 'ISBT-BPL', 'source_name': 'Bhopal ISBT', 'dest': 'ISBT-IND', 'dest_name': 'Indore Central bus stand', 'type': 'bus'},
    ]);
  }

  /// Write a key-value pair to memory cache.
  void write(String key, dynamic value) {
    _memoryCache[key] = value;
    AppLogger.d('Cache write: "$key" = $value');
  }

  /// Read a cached value by key.
  T? read<T>(String key) {
    if (_memoryCache.containsKey(key)) {
      try {
        return _memoryCache[key] as T;
      } catch (e) {
        AppLogger.w('Cache read type mismatch for key "$key": $e');
      }
    }
    return null;
  }

  /// Delete a cached value.
  void remove(String key) {
    _memoryCache.remove(key);
    AppLogger.d('Cache remove: "$key"');
  }

  /// Clear all cache registers.
  void clear() {
    _memoryCache.clear();
    AppLogger.i('Cache cleared.');
  }
}
