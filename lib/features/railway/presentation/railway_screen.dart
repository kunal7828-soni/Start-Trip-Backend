import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class RailwayScreen extends StatefulWidget {
  const RailwayScreen({super.key});

  @override
  State<RailwayScreen> createState() => _RailwayScreenState();
}

class _RailwayScreenState extends State<RailwayScreen> {
  final _fromController = TextEditingController(text: 'New York Central');
  final _toController = TextEditingController(text: 'Boston South Station');
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Railway Search'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Selection Panel Card
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    TextField(
                      controller: _fromController,
                      decoration: const InputDecoration(
                        labelText: 'From Station',
                        prefixIcon: Icon(Icons.departure_board, color: AppColors.primary),
                      ),
                    ),
                    const SizedBox(height: 16),
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
                        labelText: 'To Station',
                        prefixIcon: Icon(Icons.location_on, color: AppColors.secondary),
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.search_rounded),
                      label: const Text('Search Train Routes'),
                      onPressed: () {
                        setState(() => _isSearching = true);
                        Future.delayed(const Duration(seconds: 1), () {
                          if (mounted) setState(() => _isSearching = false);
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 56),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Search Results Segment
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Available Connections',
                  style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                Text(
                  '2 routes found',
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
            const SizedBox(height: 16),

            _isSearching
                ? const Center(child: CircularProgressIndicator())
                : Column(
                    children: [
                      _buildTrainCard(
                        trainNum: 'EXP-1092',
                        trainName: 'Silver Meteor Express',
                        time: '08:30 AM - 12:45 PM',
                        duration: '4h 15m',
                        fare: '\$48.50',
                      ),
                      const SizedBox(height: 16),
                      _buildTrainCard(
                        trainNum: 'ACELA-220',
                        trainName: 'Acela Bullet Speed',
                        time: '11:15 AM - 02:30 PM',
                        duration: '3h 15m',
                        fare: '\$82.00',
                      ),
                    ],
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrainCard({
    required String trainNum,
    required String trainName,
    required String time,
    required String duration,
    required String fare,
  }) {
    final theme = Theme.of(context);
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
                    trainNum,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                      fontSize: 12,
                    ),
                  ),
                ),
                Text(
                  fare,
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
              trainName,
              style: theme.textTheme.titleLarge?.copyWith(fontSize: 18),
            ),
            const SizedBox(height: 8),
            const Divider(),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.schedule, size: 16, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(time, style: const TextStyle(fontWeight: FontWeight.w500)),
                const Spacer(),
                Text(duration, style: const TextStyle(color: Colors.grey)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
