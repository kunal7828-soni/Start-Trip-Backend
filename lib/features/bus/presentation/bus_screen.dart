import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class BusScreen extends StatefulWidget {
  const BusScreen({super.key});

  @override
  State<BusScreen> createState() => _BusScreenState();
}

class _BusScreenState extends State<BusScreen> {
  final _fromController = TextEditingController(text: 'NYC Port Authority');
  final _toController = TextEditingController(text: 'Washington Union');
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
        title: const Text('Bus Reservation'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Search Panel Card
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    TextField(
                      controller: _fromController,
                      decoration: const InputDecoration(
                        labelText: 'From Terminal',
                        prefixIcon: Icon(Icons.bus_alert_rounded, color: AppColors.primary),
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
                        labelText: 'To Terminal',
                        prefixIcon: Icon(Icons.bus_alert_outlined, color: AppColors.secondary),
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.search_rounded),
                      label: const Text('Search Bus Schedules'),
                      onPressed: () {
                        setState(() => _isSearching = true);
                        Future.delayed(const Duration(seconds: 1), () {
                          if (mounted) setState(() => _isSearching = false);
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 56),
                        backgroundColor: AppColors.primary,
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
                  'Available Bus Lines',
                  style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                Text(
                  '3 buses found',
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
            const SizedBox(height: 16),

            _isSearching
                ? const Center(child: CircularProgressIndicator())
                : Column(
                    children: [
                      _buildBusCard(
                        operator: 'Greyhound Cruiser',
                        busType: 'Premium Sleeper (AC)',
                        time: '09:00 AM - 01:30 PM',
                        seats: '18 seats left',
                        fare: '\$35.00',
                      ),
                      const SizedBox(height: 16),
                      _buildBusCard(
                        operator: 'Bolt Express',
                        busType: 'Standard Business (AC)',
                        time: '01:15 PM - 05:45 PM',
                        seats: '6 seats left',
                        fare: '\$29.00',
                      ),
                    ],
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildBusCard({
    required String operator,
    required String busType,
    required String time,
    required String seats,
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
                    busType,
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
              operator,
              style: theme.textTheme.titleLarge?.copyWith(fontSize: 18),
            ),
            const SizedBox(height: 8),
            const Divider(),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.event_seat_rounded, size: 16, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(seats, style: const TextStyle(fontWeight: FontWeight.w500)),
                const Spacer(),
                Text(time, style: const TextStyle(color: Colors.grey)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
