import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/custom_button.dart';
import '../providers/transport_providers.dart';

/// Premium sliding bottom sheet filter panels providing sorting criteria, coach selectors, and price range sliders.
class TransportFilterSheet extends ConsumerWidget {
  const TransportFilterSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filters = ref.watch(transportFiltersProvider);
    final notifier = ref.read(transportFiltersProvider.notifier);
    
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final trainCoachesList = ['1A', '2A', '3A', 'SL'];
    final busTypeList = ['Volvo', 'AC', 'Sleeper', 'Seater'];

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.bgDark : Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
      ),
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Slide handle indicator
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? Colors.white24 : Colors.black12,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Filter & Sort',
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: () {
                  notifier.reset();
                },
                child: const Text('Reset All', style: TextStyle(color: AppColors.secondary)),
              ),
            ],
          ),
          const Divider(height: 20),

          // 1. Sort Section
          Text('Sort By', style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildSortChip(context, ref, 'Departure', 'departure'),
              _buildSortChip(context, ref, 'Price', 'price'),
              _buildSortChip(context, ref, 'Duration', 'duration'),
            ],
          ),
          const SizedBox(height: 24),

          // 2. Maximum Price Range Slider
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Max Fare Price', style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
              Text(
                '₹${filters.maxPrice.toStringAsFixed(0)}',
                style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold, color: AppColors.primary),
              ),
            ],
          ),
          const SizedBox(height: 6),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: AppColors.primary,
              inactiveTrackColor: isDark ? Colors.white10 : Colors.black12,
              thumbColor: AppColors.primary,
              overlayColor: AppColors.primary.withOpacity(0.12),
            ),
            child: Slider(
              min: 150.0,
              max: 3000.0,
              divisions: 15,
              value: filters.maxPrice,
              onChanged: (val) {
                notifier.setMaxPrice(val);
              },
            ),
          ),
          const SizedBox(height: 16),

          // 3. Train Coach filter tags (if searching train/all)
          Text('Train Coach Tier', style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: trainCoachesList.map((coach) {
              final isSelected = filters.selectedTrainCoaches.contains(coach);
              return FilterChip(
                label: Text(coach),
                selected: isSelected,
                selectedColor: AppColors.primary.withOpacity(0.12),
                checkmarkColor: AppColors.primary,
                labelStyle: TextStyle(
                  color: isSelected ? AppColors.primary : (isDark ? Colors.white70 : Colors.black87),
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
                onSelected: (_) => notifier.toggleCoach(coach),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),

          // 4. Bus Operator type tags (if searching bus/all)
          Text('Bus Coach Type', style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: busTypeList.map((type) {
              final isSelected = filters.selectedBusTypes.contains(type);
              return FilterChip(
                label: Text(type),
                selected: isSelected,
                selectedColor: AppColors.primary.withOpacity(0.12),
                checkmarkColor: AppColors.primary,
                labelStyle: TextStyle(
                  color: isSelected ? AppColors.primary : (isDark ? Colors.white70 : Colors.black87),
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
                onSelected: (_) => notifier.toggleBusType(type),
              );
            }).toList(),
          ),
          const SizedBox(height: 28),

          // Apply CTA Button
          CustomButton(
            text: 'Apply Filters',
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSortChip(BuildContext context, WidgetRef ref, String label, String key) {
    final filters = ref.watch(transportFiltersProvider);
    final notifier = ref.read(transportFiltersProvider.notifier);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final isSelected = filters.sortBy == key;

    return Expanded(
      child: GestureDetector(
        onTap: () => notifier.setSortBy(key),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 4.0),
          padding: const EdgeInsets.symmetric(vertical: 10.0),
          decoration: BoxDecoration(
            color: isSelected 
                ? AppColors.primary.withOpacity(0.12) 
                : (isDark ? AppColors.cardDark : Colors.white),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected 
                  ? AppColors.primary 
                  : (isDark ? Colors.white10 : Colors.black12),
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: isSelected ? AppColors.primary : (isDark ? Colors.white70 : Colors.black87),
            ),
          ),
        ),
      ),
    );
  }
}
