import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'About Flutter Web',
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Learn about this amazing framework',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.flutter_dash, size: 40, color: Colors.blue.shade600),
                              const SizedBox(width: 12),
                              const Text(
                                'Flutter Web',
                                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Flutter is Google\'s UI toolkit for building beautiful, natively compiled applications for mobile, web, desktop, and embedded devices from a single codebase.',
                            style: TextStyle(fontSize: 16, height: 1.5),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Key Features',
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 12),
                          _buildFeatureItem(
                            'Fast Development',
                            'Hot reload helps you quickly and easily experiment, build UIs, add features, and fix bugs.',
                            Icons.speed,
                          ),
                          _buildFeatureItem(
                            'Expressive UI',
                            'Quickly ship features with a focus on native end-user experiences.',
                            Icons.palette,
                          ),
                          _buildFeatureItem(
                            'Native Performance',
                            'Flutter\'s widgets incorporate all critical platform differences.',
                            Icons.flash_on,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'This Demo App',
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'This application demonstrates:',
                            style: TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 8),
                          _buildDemoFeature('Authentication flow with login/logout'),
                          _buildDemoFeature('Responsive Material Design 3 UI'),
                          _buildDemoFeature('Multi-page navigation'),
                          _buildDemoFeature('State management'),
                          _buildDemoFeature('Form validation'),
                          _buildDemoFeature('Task management functionality'),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(String title, String description, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.blue.shade600, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDemoFeature(String feature) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Row(
        children: [
          Icon(Icons.check_circle, color: Colors.green.shade600, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              feature,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}