import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../models/bus_schedule_model.dart';

/// Highly interactive, modern 2x2 seat selection grid matching premium flight & bus operators UI layouts.
/// Provides real-time visual seat booking states, tap animations, and pricing sum calculations.
class SeatLayoutWidget extends StatefulWidget {
  final List<BusSeat> seats;
  final double seatPrice;
  final Function(List<String> selectedSeats, double totalPrice) onSelectionChanged;

  const SeatLayoutWidget({
    super.key,
    required this.seats,
    required this.seatPrice,
    required this.onSelectionChanged,
  });

  @override
  State<SeatLayoutWidget> createState() => _SeatLayoutWidgetState();
}

class _SeatLayoutWidgetState extends State<SeatLayoutWidget> {
  final Set<String> _selectedSeats = {};

  void _onSeatTap(BusSeat seat) {
    if (seat.isBooked) return;

    setState(() {
      if (_selectedSeats.contains(seat.label)) {
        _selectedSeats.remove(seat.label);
      } else {
        _selectedSeats.add(seat.label);
      }
    });

    final totalPrice = _selectedSeats.length * widget.seatPrice;
    widget.onSelectionChanged(_selectedSeats.toList(), totalPrice);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Group seats by rows
    final Map<int, List<BusSeat>> rowsMap = {};
    for (final seat in widget.seats) {
      rowsMap.putIfAbsent(seat.row, () => []).add(seat);
    }

    final sortedRowsKeys = rowsMap.keys.toList()..sort();

    return Column(
      children: [
        // 1. Seat State Legend Indicators
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildLegendItem('Booked', isDark ? Colors.white24 : Colors.black12, isDark ? Colors.white30 : Colors.black38),
            _buildLegendItem('Available', isDark ? AppColors.cardDark : Colors.white, isDark ? Colors.white30 : Colors.black26),
            _buildLegendItem('Selected', AppColors.primary, Colors.white),
          ],
        ),
        const SizedBox(height: 24),

        // 2. Main Bus steering wheel mockup panel
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isDark ? AppColors.cardDark.withOpacity(0.4) : Colors.black54.withOpacity(0.04),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Front of Bus',
                style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold, letterSpacing: 1),
              ),
              const Icon(Icons.radio_button_checked, size: 24, color: AppColors.primary), // Represents steering wheel
            ],
          ),
        ),
        const SizedBox(height: 20),

        // 3. Grid seat list
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: sortedRowsKeys.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final rowNum = sortedRowsKeys[index];
            final List<BusSeat> rowSeats = rowsMap[rowNum]!..sort((a, b) => a.col.compareTo(b.col));

            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Column 1
                if (rowSeats.isNotEmpty) _buildSeatButton(rowSeats[0], isDark),
                // Column 2
                if (rowSeats.length > 1) _buildSeatButton(rowSeats[1], isDark),
                
                // Bus Central Aisle Gap space
                Container(
                  width: 30,
                  alignment: Alignment.center,
                  child: Text(
                    rowNum.toString(),
                    style: theme.textTheme.bodySmall?.copyWith(color: isDark ? Colors.white24 : Colors.black26),
                  ),
                ),

                // Column 3
                if (rowSeats.length > 2) _buildSeatButton(rowSeats[2], isDark),
                // Column 4
                if (rowSeats.length > 3) _buildSeatButton(rowSeats[3], isDark),
              ],
            );
          },
        ),
        
        // 4. Quick Checkout price summary bottom card
        if (_selectedSeats.isNotEmpty) ...[
          const SizedBox(height: 24),
          Card(
            color: AppColors.primary.withOpacity(0.08),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: const BorderSide(color: AppColors.primary, width: 0.5),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Selected Seats: ${_selectedSeats.join(', ')}',
                        style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Total Price (+GST & Booking)',
                        style: theme.textTheme.bodySmall?.copyWith(color: isDark ? Colors.white60 : Colors.black54),
                      ),
                    ],
                  ),
                  Text(
                    '₹${(_selectedSeats.length * widget.seatPrice).toStringAsFixed(2)}',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: AppColors.secondary,
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ],
    );
  }

  Widget _buildLegendItem(String title, Color bg, Color border) {
    return Row(
      children: [
        Container(
          width: 18,
          height: 18,
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: border),
          ),
        ),
        const SizedBox(width: 8),
        Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildSeatButton(BusSeat seat, bool isDark) {
    final isSelected = _selectedSeats.contains(seat.label);
    
    Color bg = isDark ? AppColors.cardDark : Colors.white;
    Color border = isDark ? Colors.white10 : Colors.black26;
    Color text = isDark ? Colors.white : Colors.black87;

    if (seat.isBooked) {
      bg = isDark ? Colors.white10 : Colors.black54.withOpacity(0.06);
      border = isDark ? Colors.transparent : Colors.black12;
      text = isDark ? Colors.white24 : Colors.black26;
    } else if (isSelected) {
      bg = AppColors.primary;
      border = Colors.transparent;
      text = Colors.white;
    }

    return GestureDetector(
      onTap: () => _onSeatTap(seat),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: border, width: 1.5),
          boxShadow: isSelected ? [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.2),
              blurRadius: 6,
              offset: const Offset(0, 3),
            )
          ] : null,
        ),
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              seat.isSleeper ? Icons.airline_seat_flat_angled : Icons.airline_seat_recline_normal,
              size: 16,
              color: text,
            ),
            const SizedBox(height: 2),
            Text(
              seat.label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: text,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
