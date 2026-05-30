import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../models/bus_schedule_model.dart';
import '../models/train_schedule_model.dart';

/// Highly stylized, premium travel result card displaying schedules, fares, and connections details.
class TransportResultCard extends StatelessWidget {
  final TrainScheduleModel? train;
  final BusScheduleModel? bus;
  final VoidCallback onTap;

  const TransportResultCard({
    super.key,
    this.train,
    this.bus,
    required this.onTap,
  }) : assert(train != null || bus != null);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final isTrain = train != null;
    final name = isTrain ? train!.trainName : bus!.operatorName;
    final code = isTrain ? train!.trainNumber : bus!.busType;
    
    final departure = isTrain ? train!.departureTime : bus!.departureTime;
    final arrival = isTrain ? train!.arrivalTime : bus!.arrivalTime;
    final duration = isTrain ? train!.formattedDuration : bus!.formattedDuration;

    final source = isTrain ? train!.sourceStationCode : bus!.sourceStopCode;
    final dest = isTrain ? train!.destStationCode : bus!.destStopCode;

    // Find the minimum fare amount
    double minFare = 0.0;
    if (isTrain) {
      minFare = train!.baseFares.values.reduce((min, val) => val < min ? val : min);
    } else {
      minFare = bus!.fareAmount;
    }

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      color: isDark ? AppColors.cardDark : Colors.white,
      shadowColor: Colors.black.withOpacity(isDark ? 0.25 : 0.06),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Top Header: Category Tag & Pricing details
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Category tag
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: (isTrain ? AppColors.primary : AppColors.secondary).withOpacity(0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isTrain ? Icons.train_outlined : Icons.directions_bus_outlined,
                          size: 14,
                          color: isTrain ? AppColors.primary : AppColors.secondary,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          isTrain ? 'TRAIN • $code' : 'BUS • $code',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: isTrain ? AppColors.primary : AppColors.secondary,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Fare price
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        'from ',
                        style: theme.textTheme.bodySmall?.copyWith(color: isDark ? Colors.white38 : Colors.black38),
                      ),
                      Text(
                        '₹${minFare.toStringAsFixed(0)}',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w900,
                          color: AppColors.secondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // 2. Main Title: Provider / Train Name
              Text(
                name,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 18),

              // 3. Timetable Connector Layout (Source -> Duration -> Dest)
              Row(
                children: [
                  // Source block
                  _buildStopBlock(context, time: departure, code: source, alignment: CrossAxisAlignment.start),
                  
                  // Duration spacer line
                  Expanded(
                    child: Column(
                      children: [
                        Text(
                          duration,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: isDark ? Colors.white38 : Colors.black38,
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                              ),
                            ),
                            Expanded(
                              child: Container(
                                height: 1,
                                color: isDark ? Colors.white24 : Colors.black12,
                              ),
                            ),
                            const Icon(Icons.chevron_right_rounded, size: 14, color: AppColors.primary),
                            Expanded(
                              child: Container(
                                height: 1,
                                color: isDark ? Colors.white24 : Colors.black12,
                              ),
                            ),
                            Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                color: AppColors.secondary,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Destination block
                  _buildStopBlock(context, time: arrival, code: dest, alignment: CrossAxisAlignment.end),
                ],
              ),
              
              // 4. Footer coach badges
              if (isTrain && train!.coachesAvailable.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Divider(height: 1, thickness: 0.5),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Text(
                      'Tiers: ',
                      style: theme.textTheme.bodySmall?.copyWith(color: isDark ? Colors.white38 : Colors.black38),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Wrap(
                        spacing: 6,
                        children: train!.coachesAvailable.map((coach) {
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: isDark ? Colors.white10 : Colors.black54.withOpacity(0.04),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              coach,
                              style: theme.textTheme.bodySmall?.copyWith(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white70 : Colors.black87,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                )
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStopBlock(
    BuildContext context, {
    required String time,
    required String code,
    required CrossAxisAlignment alignment,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: alignment,
      children: [
        Text(
          time,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w900,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          code,
          style: theme.textTheme.bodySmall?.copyWith(
            color: isDark ? Colors.white60 : Colors.black54,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}
