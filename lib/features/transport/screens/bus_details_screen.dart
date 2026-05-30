import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/custom_button.dart';
import '../models/bus_schedule_model.dart';
import '../widgets/seat_layout_widget.dart';

/// Detailed Bus Timetable schedules and Seats selection display screen.
class BusDetailsScreen extends StatefulWidget {
  final BusScheduleModel bus;

  const BusDetailsScreen({
    super.key,
    required this.bus,
  });

  @override
  State<BusDetailsScreen> createState() => _BusDetailsScreenState();
}

class _BusDetailsScreenState extends State<BusDetailsScreen> {
  List<String> _selectedSeats = [];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Seats & Timing'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. Bus Details Header Card
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              color: isDark ? AppColors.cardDark : Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            widget.bus.operatorName,
                            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          '₹${widget.bus.fareAmount.toStringAsFixed(0)}',
                          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900, color: AppColors.secondary),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      widget.bus.busType,
                      style: theme.textTheme.bodySmall?.copyWith(color: isDark ? Colors.white60 : Colors.black54),
                    ),
                    const Divider(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildTimeColumn(context, 'Departure', widget.bus.departureTime, widget.bus.sourceStopCode),
                        Column(
                          children: [
                            Text(
                              widget.bus.formattedDuration,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
                            ),
                            Icon(Icons.arrow_right_alt, color: AppColors.primary, size: 20),
                          ],
                        ),
                        _buildTimeColumn(context, 'Arrival', widget.bus.arrivalTime, widget.bus.destStopCode),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // 2. Pickup & Drop timelines
            Row(
              children: [
                const Icon(Icons.departure_board, size: 20, color: AppColors.primary),
                const SizedBox(width: 8),
                Text('Boarding & Drop Points', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? AppColors.cardDark : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: isDark ? Colors.white10 : Colors.black12),
              ),
              child: Column(
                children: [
                  _buildBoardingRow(context, 'Pickup: ', widget.bus.pickupPoints.first.location, widget.bus.pickupPoints.first.time),
                  const SizedBox(height: 12),
                  _buildBoardingRow(context, 'Drop: ', widget.bus.dropPoints.first.location, widget.bus.dropPoints.first.time),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // 3. Interactive Seat selection layout
            Row(
              children: [
                const Icon(Icons.event_seat, size: 20, color: AppColors.primary),
                const SizedBox(width: 8),
                Text('Select Seats Layout', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 16),
            SeatLayoutWidget(
              seats: widget.bus.seats,
              seatPrice: widget.bus.fareAmount,
              onSelectionChanged: (selected, total) {
                setState(() {
                  _selectedSeats = selected;
                });
              },
            ),
            const SizedBox(height: 28),

            // 4. Booking action button (mock action step)
            CustomButton(
              text: _selectedSeats.isEmpty ? 'Select Seats to Proceed' : 'Proceed with Booking',
              onPressed: _selectedSeats.isEmpty
                  ? null
                  : () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Selected Seats: ${_selectedSeats.join(', ')}. Initializing fare checks...'),
                          backgroundColor: AppColors.primary,
                        ),
                      );
                    },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeColumn(BuildContext context, String label, String time, String code) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      children: [
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(color: isDark ? Colors.white38 : Colors.black38),
        ),
        const SizedBox(height: 4),
        Text(time, style: const TextStyle(fontWeight: FontWeight.w900)),
        Text(code, style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 11)),
      ],
    );
  }

  Widget _buildBoardingRow(BuildContext context, String prefix, String loc, String time) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          prefix,
          style: TextStyle(color: isDark ? Colors.white38 : Colors.black38, fontWeight: FontWeight.bold, fontSize: 12),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(loc, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              const SizedBox(height: 2),
              Text(
                'Boarding Time: $time',
                style: theme.textTheme.bodySmall?.copyWith(color: AppColors.secondary, fontSize: 10, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
