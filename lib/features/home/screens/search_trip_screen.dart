import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/primary_button.dart';

class SearchTripScreen extends StatefulWidget {
  const SearchTripScreen({super.key});

  @override
  State<SearchTripScreen> createState() => _SearchTripScreenState();
}

class _SearchTripScreenState extends State<SearchTripScreen> {
  final _fromController = TextEditingController(text: 'Central Station (NYC)');
  final _toController = TextEditingController(text: 'Union Station (WDC)');
  bool _isSearching = false;

  @override
  void dispose() {
    _fromController.dispose();
    _toController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Routes'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    TextField(
                      controller: _fromController,
                      decoration: const InputDecoration(
                        labelText: 'From Station/Terminal',
                        prefixIcon: Icon(Icons.departure_board, color: AppColors.primary),
                      ),
                    ),
                    AppSpacing.vMD,
                    IconButton(
                      icon: const Icon(Icons.swap_vert_rounded, color: AppColors.primary),
                      onPressed: () {
                        final temp = _fromController.text;
                        setState(() {
                          _fromController.text = _toController.text;
                          _toController.text = temp;
                        });
                      },
                    ),
                    TextField(
                      controller: _toController,
                      decoration: const InputDecoration(
                        labelText: 'To Station/Terminal',
                        prefixIcon: Icon(Icons.location_on, color: AppColors.secondary),
                      ),
                    ),
                    const SizedBox(height: 24),
                    PrimaryButton(
                      text: 'Search Connections',
                      isLoading: _isSearching,
                      onPressed: () {
                        setState(() => _isSearching = true);
                        Future.delayed(const Duration(seconds: 1000), () {
                          if (mounted) setState(() => _isSearching = false);
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Search Results',
                  style: AppTextStyles.title(
                    color: isDark ? Colors.white : AppColors.textPrimaryLight,
                  ).copyWith(fontWeight: FontWeight.bold),
                ),
                Text(
                  '2 items located',
                  style: AppTextStyles.caption(),
                ),
              ],
            ),
            AppSpacing.vMD,

            _isSearching
                ? const Center(child: CircularProgressIndicator())
                : Column(
                    children: [
                      _buildResultCard(
                        num: 'RAIL-EXP-440',
                        name: 'Acela High Speed Rail',
                        time: '10:00 AM - 01:30 PM (3h 30m)',
                        price: '\$78.00',
                      ),
                      AppSpacing.vMD,
                      _buildResultCard(
                        num: 'BUS-LINE-12',
                        name: 'Greyhound Cruiser (AC)',
                        time: '01:45 PM - 06:15 PM (4h 30m)',
                        price: '\$32.00',
                      ),
                    ],
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultCard({
    required String num,
    required String name,
    required String time,
    required String price,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    num,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                      fontSize: 12,
                    ),
                  ),
                ),
                Text(
                  price,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    color: AppColors.secondary,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              name,
              style: AppTextStyles.title(
                color: isDark ? Colors.white : AppColors.textPrimaryLight,
              ).copyWith(fontSize: 16),
            ),
            AppSpacing.vSM,
            const Divider(),
            AppSpacing.vSM,
            Row(
              children: [
                const Icon(Icons.schedule, size: 16, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(time, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
