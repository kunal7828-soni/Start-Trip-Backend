import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class WorkerScreen extends StatefulWidget {
  const WorkerScreen({super.key});

  @override
  State<WorkerScreen> createState() => _WorkerScreenState();
}

class _WorkerScreenState extends State<WorkerScreen> {
  final List<Map<String, dynamic>> _mockWorkers = [
    {
      'name': 'Carlos Mendez',
      'role': 'Local Tour Guide & Driver',
      'rating': 4.9,
      'trips': 142,
      'isOnline': true,
      'bio': 'Native translator and private driver specializing in historic hiking trails and city transfers.',
    },
    {
      'name': 'Akiro Tanaka',
      'role': 'Regional Transit Assistant',
      'rating': 4.7,
      'trips': 98,
      'isOnline': false,
      'bio': 'Specialized guide for Japanese rail tours and ticket arrangements. Speaks English & Japanese.',
    }
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Travel Partners'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(20.0),
        itemCount: _mockWorkers.length,
        itemBuilder: (context, index) {
          final worker = _mockWorkers[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 20.0),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Avatar
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: AppColors.primary.withOpacity(0.1),
                        child: Text(
                          worker['name'][0],
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  worker['name'],
                                  style: theme.textTheme.titleLarge?.copyWith(fontSize: 18),
                                ),
                                const Spacer(),
                                Icon(
                                  Icons.circle,
                                  size: 12,
                                  color: worker['isOnline'] ? AppColors.success : Colors.grey,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  worker['isOnline'] ? 'Active' : 'Offline',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: worker['isOnline'] ? AppColors.success : Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              worker['role'],
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Divider(),
                  const SizedBox(height: 8),
                  Text(
                    worker['bio'],
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Icon(Icons.star, color: AppColors.warning, size: 20),
                      const SizedBox(width: 4),
                      Text(
                        '${worker['rating']}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 6),
                      Text('(${worker['trips']} journeys completed)', style: const TextStyle(color: Colors.grey, fontSize: 13)),
                      const Spacer(),
                      ElevatedButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Requesting connection with ${worker['name']}...')),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          minimumSize: const Size(80, 36),
                        ),
                        child: const Text('Contact', style: TextStyle(fontSize: 13)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
