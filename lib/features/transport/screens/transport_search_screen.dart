import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../models/station_model.dart';
import '../providers/transport_providers.dart';
import '../widgets/transport_filter_sheet.dart';
import '../widgets/transport_result_card.dart';
import 'train_details_screen.dart';
import 'bus_details_screen.dart';

/// Consolidated, premium Transport Search dashboard for Trip Buddy.
/// Integrates multi-transport tab filters, historical search chips, autocompletes,
/// and responsive results matching Material 3 specifications.
class TransportSearchScreen extends ConsumerStatefulWidget {
  const TransportSearchScreen({super.key});

  @override
  ConsumerState<TransportSearchScreen> createState() => _TransportSearchScreenState();
}

class _TransportSearchScreenState extends ConsumerState<TransportSearchScreen> {
  final TextEditingController _sourceController = TextEditingController();
  final TextEditingController _destController = TextEditingController();

  List<StationModel> _sourceSuggestions = [];
  List<StationModel> _destSuggestions = [];
  bool _showSourceSuggestions = false;
  bool _showDestSuggestions = false;

  @override
  void initState() {
    super.initState();
    final query = ref.read(transportSearchQueryProvider);
    _sourceController.text = '${query.sourceName} (${query.sourceCode})';
    _destController.text = '${query.destName} (${query.destCode})';
  }

  @override
  void dispose() {
    _sourceController.dispose();
    _destController.dispose();
    super.dispose();
  }

  void _triggerSourceAutocomplete(String val) async {
    final repo = ref.read(transportRepositoryProvider);
    final suggestions = await repo.getStationsAutocomplete(val);
    setState(() {
      _sourceSuggestions = suggestions;
      _showSourceSuggestions = suggestions.isNotEmpty;
    });
  }

  void _triggerDestAutocomplete(String val) async {
    final repo = ref.read(transportRepositoryProvider);
    final suggestions = await repo.getStationsAutocomplete(val);
    setState(() {
      _destSuggestions = suggestions;
      _showDestSuggestions = suggestions.isNotEmpty;
    });
  }

  void _selectSource(StationModel station) {
    final query = ref.read(transportSearchQueryProvider);
    ref.read(transportSearchQueryProvider.notifier).state = query.copyWith(
      sourceName: station.name,
      sourceCode: station.code,
    );
    _sourceController.text = '${station.name} (${station.code})';
    setState(() {
      _showSourceSuggestions = false;
    });
  }

  void _selectDest(StationModel station) {
    final query = ref.read(transportSearchQueryProvider);
    ref.read(transportSearchQueryProvider.notifier).state = query.copyWith(
      destName: station.name,
      destCode: station.code,
    );
    _destController.text = '${station.name} (${station.code})';
    setState(() {
      _showDestSuggestions = false;
    });
  }

  Future<void> _selectDate() async {
    final query = ref.read(transportSearchQueryProvider);
    final picked = await showDatePicker(
      context: context,
      initialDate: query.travelDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
    );
    if (picked != null) {
      ref.read(transportSearchQueryProvider.notifier).state = query.copyWith(travelDate: picked);
    }
  }

  void _swapTerminals() {
    final query = ref.read(transportSearchQueryProvider);
    final tempName = query.sourceName;
    final tempCode = query.sourceCode;

    ref.read(transportSearchQueryProvider.notifier).state = query.copyWith(
      sourceName: query.destName,
      sourceCode: query.destCode,
      destName: tempName,
      destCode: tempCode,
    );

    _sourceController.text = '${query.destName} (${query.destCode})';
    _destController.text = '$tempName ($tempCode)';
  }

  @override
  Widget build(BuildContext context) {
    final query = ref.watch(transportSearchQueryProvider);
    final history = ref.watch(searchHistoryProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final trainAsync = ref.watch(trainResultsProvider);
    final busAsync = ref.watch(busResultsProvider);

    final filteredTrains = ref.watch(filteredTrainsProvider);
    final filteredBuses = ref.watch(filteredBusesProvider);

    final isAll = query.transportType == 'all';
    final isTrain = query.transportType == 'train';
    final isBus = query.transportType == 'bus';

    final totalFound = (isAll || isTrain ? filteredTrains.length : 0) + 
                       (isAll || isBus ? filteredBuses.length : 0);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Transports'),
      ),
      body: Stack(
        children: [
          // Main scroll panel contents
          ListView(
            padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 80.0),
            children: [
              // 1. Inputs Core Card
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                color: isDark ? AppColors.cardDark : Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Source Field
                      TextField(
                        controller: _sourceController,
                        onChanged: _triggerSourceAutocomplete,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                        decoration: const InputDecoration(
                          labelText: 'From Station / Terminal',
                          prefixIcon: Icon(Icons.departure_board, color: AppColors.primary),
                        ),
                      ),
                      
                      // Source suggestions overlay dropdown
                      if (_showSourceSuggestions)
                        _buildSuggestionsList(_sourceSuggestions, _selectSource, isDark),
                        
                      const SizedBox(height: 10),

                      // Swap Button row
                      Center(
                        child: FloatingActionButton.small(
                          heroTag: 'swap_terminals_btn',
                          backgroundColor: AppColors.primary.withOpacity(0.12),
                          foregroundColor: AppColors.primary,
                          elevation: 0,
                          onPressed: _swapTerminals,
                          child: const Icon(Icons.swap_vert),
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Destination Field
                      TextField(
                        controller: _destController,
                        onChanged: _triggerDestAutocomplete,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                        decoration: const InputDecoration(
                          labelText: 'To Station / Terminal',
                          prefixIcon: Icon(Icons.location_on, color: AppColors.secondary),
                        ),
                      ),

                      // Dest suggestions overlay dropdown
                      if (_showDestSuggestions)
                        _buildSuggestionsList(_destSuggestions, _selectDest, isDark),

                      const SizedBox(height: 20),

                      // Travel Date Selector
                      InkWell(
                        onTap: _selectDate,
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          decoration: BoxDecoration(
                            border: Border.all(color: isDark ? Colors.white10 : Colors.black12),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.calendar_month, color: AppColors.primary, size: 20),
                                  const SizedBox(width: 12),
                                  Text(
                                    '${query.travelDate.day} ${_getMonthName(query.travelDate.month)} ${query.travelDate.year}',
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              const Icon(Icons.arrow_drop_down, color: AppColors.primary),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Type filters selector tabs
                      Row(
                        children: [
                          _buildTabFilter(ref, 'All', 'all'),
                          const SizedBox(width: 8),
                          _buildTabFilter(ref, 'Trains', 'train'),
                          const SizedBox(width: 8),
                          _buildTabFilter(ref, 'Buses', 'bus'),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // 2. Search History section
              if (history.isNotEmpty) ...[
                const SizedBox(height: 24),
                Row(
                  children: [
                    const Icon(Icons.history, size: 18, color: AppColors.primary),
                    const SizedBox(width: 8),
                    Text(
                      'Recent Searches',
                      style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 48,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: history.length,
                    separatorBuilder: (context, index) => const SizedBox(width: 10),
                    itemBuilder: (context, index) {
                      final item = history[index];
                      return ActionChip(
                        label: Text('${item.sourceCode} ➔ ${item.destCode}'),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        backgroundColor: isDark ? AppColors.cardDark : Colors.white,
                        onPressed: () {
                          ref.read(transportSearchQueryProvider.notifier).state = item;
                          _sourceController.text = '${item.sourceName} (${item.sourceCode})';
                          _destController.text = '${item.destName} (${item.destCode})';
                          // Trigger new search history logging
                          ref.read(searchHistoryProvider.notifier).addSearch(item);
                        },
                      );
                    },
                  ),
                ),
              ],

              // 3. Search Results block
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Search Results',
                    style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '$totalFound options found',
                    style: theme.textTheme.bodySmall?.copyWith(color: isDark ? Colors.white38 : Colors.black38),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Renders shimmers or actual lists
              if (trainAsync.isLoading || busAsync.isLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 40.0),
                    child: CircularProgressIndicator(color: AppColors.primary),
                  ),
                )
              else if (trainAsync.hasError || busAsync.hasError)
                _buildErrorCard(theme, isDark)
              else if (totalFound == 0)
                _buildEmptyStateCard(theme, isDark)
              else
                Column(
                  children: [
                    // Trains lists
                    if (isAll || isTrain)
                      ...filteredTrains.map((t) => Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: TransportResultCard(
                          train: t,
                          onTap: () {
                            // Launch train stops timeline
                            Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => TrainDetailsScreen(train: t),
                            ));
                          },
                        ),
                      )),
                    // Buses lists
                    if (isAll || isBus)
                      ...filteredBuses.map((b) => Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: TransportResultCard(
                          bus: b,
                          onTap: () {
                            // Launch bus interactive seating sheet
                            Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => BusDetailsScreen(bus: b),
                            ));
                          },
                        ),
                      )),
                  ],
                ),
            ],
          ),

          // F. Floating filter FAB HUD on bottom
          Positioned(
            left: 0,
            right: 0,
            bottom: 16,
            child: Center(
              child: FloatingActionButton.extended(
                heroTag: 'floating_filters_fab',
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (context) => const TransportFilterSheet(),
                  );
                },
                icon: const Icon(Icons.tune),
                label: const Text('Filter & Sort', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionsList(
    List<StationModel> suggestions,
    Function(StationModel) onSelect,
    bool isDark,
  ) {
    return Container(
      constraints: const BoxConstraints(maxHeight: 180),
      margin: const EdgeInsets.only(top: 4),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark.withOpacity(0.98) : Colors.white.withOpacity(0.98),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? Colors.white10 : Colors.black12),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: ListView.separated(
          shrinkWrap: true,
          padding: EdgeInsets.zero,
          itemCount: suggestions.length,
          separatorBuilder: (context, index) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final suggestion = suggestions[index];
            return ListTile(
              leading: Icon(
                suggestion.isTrainStation ? Icons.train : Icons.directions_bus,
                color: AppColors.primary,
                size: 18,
              ),
              title: Text(
                suggestion.name,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
              subtitle: Text(
                '${suggestion.city} (${suggestion.code})',
                style: TextStyle(color: isDark ? Colors.white60 : Colors.black54, fontSize: 11),
              ),
              onTap: () => onSelect(suggestion),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTabFilter(WidgetRef ref, String label, String type) {
    final query = ref.watch(transportSearchQueryProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final isSelected = query.transportType == type;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          ref.read(transportSearchQueryProvider.notifier).state = query.copyWith(transportType: type);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected 
                ? AppColors.primary 
                : (isDark ? AppColors.bgDark : Colors.black54.withOpacity(0.04)),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected 
                  ? Colors.transparent 
                  : (isDark ? Colors.white10 : Colors.black12),
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: isSelected ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyStateCard(ThemeData theme, bool isDark) {
    return Card(
      color: isDark ? AppColors.cardDark : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 20),
        child: Column(
          children: [
            const Icon(Icons.search_off, size: 64, color: AppColors.secondary),
            const SizedBox(height: 16),
            Text(
              'No Connections Located',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(
              'Try altering the search stations criteria or clearing selected sorting filters.',
              style: theme.textTheme.bodySmall?.copyWith(color: isDark ? Colors.white60 : Colors.black54),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorCard(ThemeData theme, bool isDark) {
    return Card(
      color: AppColors.error.withOpacity(0.12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
        child: Column(
          children: [
            const Icon(Icons.error_outline, size: 48, color: AppColors.error),
            const SizedBox(height: 16),
            Text(
              'Search Connection Timeout',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: AppColors.error),
            ),
            const SizedBox(height: 6),
            Text(
              'Verify network connectivity or try searching standard mock stations NDLS ➔ BPL.',
              style: theme.textTheme.bodySmall?.copyWith(color: isDark ? Colors.white70 : Colors.black87),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  String _getMonthName(int month) {
    const list = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return list[month - 1];
  }
}
