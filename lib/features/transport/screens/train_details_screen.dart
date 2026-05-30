import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../models/train_schedule_model.dart';

/// Detailed Train Routes schedule and Intermediate stopping platforms display screen.
class TrainDetailsScreen extends StatelessWidget {
  final TrainScheduleModel train;

  const TrainDetailsScreen({
    super.key,
    required this.train,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text('${train.trainNumber} • Route Schedule'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. Train Meta details card
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
                        Text(
                          train.trainName,
                          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            train.trainNumber,
                            style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary, fontSize: 11),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Divider(),
                    const SizedBox(height: 12),
                    _buildMetaRow(context, 'From Code', train.sourceStationCode, Icons.departure_board),
                    const SizedBox(height: 10),
                    _buildMetaRow(context, 'To Code', train.destStationCode, Icons.location_on),
                    const SizedBox(height: 10),
                    _buildMetaRow(context, 'Estimated Duration', train.formattedDuration, Icons.timer),
                    const SizedBox(height: 10),
                    _buildMetaRow(
                      context,
                      'Runs On Days',
                      train.runsOnDays.map((d) => _getDayLetter(d)).join(' '),
                      Icons.calendar_month,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 28),

            // 2. Intermediate Stops Timeline Header
            Row(
              children: [
                const Icon(Icons.alt_route, size: 20, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(
                  'Intermediate Stations Timeline',
                  style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 3. Vertical Timeline Stops list
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: train.intermediateStops.length,
              itemBuilder: (context, index) {
                final stop = train.intermediateStops[index];
                final isFirst = index == 0;
                final isLast = index == train.intermediateStops.length - 1;

                return IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Timeline indicator column
                      Column(
                        children: [
                          Container(
                            width: 14,
                            height: 14,
                            decoration: BoxDecoration(
                              color: isFirst 
                                  ? AppColors.primary 
                                  : (isLast ? AppColors.secondary : Colors.transparent),
                              border: Border.all(
                                color: isFirst || isLast 
                                    ? Colors.transparent 
                                    : (isDark ? Colors.white60 : Colors.black45),
                                width: 2,
                              ),
                              shape: BoxShape.circle,
                            ),
                          ),
                          if (!isLast)
                            Expanded(
                              child: Container(
                                width: 2,
                                color: isDark ? Colors.white24 : Colors.black12,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(width: 16),

                      // Timeline details Card
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 20.0),
                          child: Container(
                            padding: const EdgeInsets.all(16.0),
                            decoration: BoxDecoration(
                              color: isDark ? AppColors.cardDark : Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: isDark ? Colors.white10 : Colors.black12),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        stop.stationName,
                                        style: const TextStyle(fontWeight: FontWeight.bold),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Platform ${stop.platform}',
                                      style: theme.textTheme.bodySmall?.copyWith(
                                        color: AppColors.secondary,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    _buildTimeLabel(context, 'Arr', stop.arrivalTime),
                                    _buildTimeLabel(context, 'Halt', isFirst || isLast ? '--' : '${stop.haltMinutes}m'),
                                    _buildTimeLabel(context, 'Dep', stop.departureTime),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetaRow(BuildContext context, String label, String value, IconData icon) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.primary),
        const SizedBox(width: 10),
        Text(
          '$label: ',
          style: TextStyle(color: isDark ? Colors.white38 : Colors.black38, fontSize: 13),
        ),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
        ),
      ],
    );
  }

  Widget _buildTimeLabel(BuildContext context, String label, String time) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(color: isDark ? Colors.white38 : Colors.black38),
        ),
        const SizedBox(height: 3),
        Text(
          time,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
        ),
      ],
    );
  }

  String _getDayLetter(int day) {
    const map = {1: 'M', 2: 'T', 3: 'W', 4: 'T', 5: 'F', 6: 'S', 7: 'S'};
    return map[day] ?? '';
  }
}
