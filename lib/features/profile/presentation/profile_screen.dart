import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // Centered User Header Card
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: AppColors.primary.withOpacity(0.1),
                    child: const Icon(
                      Icons.person,
                      size: 60,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Sarah Jenkins',
                    style: theme.textTheme.displayLarge?.copyWith(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'sarah.jenkins@example.com',
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 12),
                  Chip(
                    label: const Text('Premium Member'),
                    backgroundColor: AppColors.secondary.withOpacity(0.1),
                    labelStyle: const TextStyle(color: AppColors.secondary, fontWeight: FontWeight.bold),
                    side: BorderSide.none,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),

            // Profile Options
            _buildOptionCard(
              title: 'Saved Places & Bookmarks',
              icon: Icons.bookmark_border_rounded,
              color: Colors.amber,
              onTap: () {},
            ),
            const SizedBox(height: 12),
            _buildOptionCard(
              title: 'My Bookings History',
              icon: Icons.receipt_long_rounded,
              color: AppColors.primary,
              onTap: () {},
            ),
            const SizedBox(height: 12),
            _buildOptionCard(
              title: 'Location Permissions & Privacy',
              icon: Icons.security_rounded,
              color: Colors.green,
              onTap: () {},
            ),
            const SizedBox(height: 12),
            _buildOptionCard(
              title: 'Payment Methods',
              icon: Icons.credit_card,
              color: Colors.blue,
              onTap: () {},
            ),
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 24),

            // Logout Action Button
            ElevatedButton.icon(
              icon: const Icon(Icons.logout_rounded),
              label: const Text('Sign Out'),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Logging out of Trip Buddy...')),
                );
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 56),
                backgroundColor: AppColors.error,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionCard({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
