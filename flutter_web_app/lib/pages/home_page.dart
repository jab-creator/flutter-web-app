import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  final String currentUser;

  const HomePage({super.key, required this.currentUser});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Welcome back, $currentUser!',
            style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Flutter Web App Dashboard',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
          const SizedBox(height: 20),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'App Features',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'This Flutter web app demonstrates modern web development with Flutter.',
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 20),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      _buildFeatureChip('Responsive Design', Icons.devices),
                      _buildFeatureChip('Material Design 3', Icons.palette),
                      _buildFeatureChip('Authentication', Icons.security),
                      _buildFeatureChip('Task Management', Icons.task_alt),
                      _buildFeatureChip('Navigation', Icons.navigation),
                      _buildFeatureChip('State Management', Icons.settings),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          LayoutBuilder(
            builder: (context, constraints) {
              // Calculate grid height based on screen size
              final crossAxisCount = constraints.maxWidth > 600 ? 2 : 1;
              final itemHeight = 140.0;
              final gridHeight = (4 / crossAxisCount).ceil() * itemHeight + 
                                 ((4 / crossAxisCount).ceil() - 1) * 16; // spacing
              
              return SizedBox(
                height: gridHeight,
                child: GridView.count(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: constraints.maxWidth > 600 ? 1.5 : 2.5,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _buildInfoCard(
                      'Tasks',
                      'Manage your daily tasks',
                      Icons.task_alt,
                      Colors.blue,
                    ),
                    _buildInfoCard(
                      'Profile',
                      'View your profile info',
                      Icons.person,
                      Colors.green,
                    ),
                    _buildInfoCard(
                      'Settings',
                      'App configuration',
                      Icons.settings,
                      Colors.orange,
                    ),
                    _buildInfoCard(
                      'About',
                      'Learn about Flutter',
                      Icons.info,
                      Colors.purple,
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 20), // Bottom padding
        ],
      ),
    );
  }

  Widget _buildFeatureChip(String label, IconData icon) {
    return Chip(
      avatar: Icon(icon, size: 18),
      label: Text(label),
      backgroundColor: Colors.blue.shade50,
    );
  }

  Widget _buildInfoCard(String title, String subtitle, IconData icon, Color color) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: color),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }
}