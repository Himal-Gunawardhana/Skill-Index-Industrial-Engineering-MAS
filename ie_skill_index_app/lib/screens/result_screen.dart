import 'package:flutter/material.dart';
import '../models/assessment_model.dart';
import '../widgets/custom_app_bar.dart';
import 'home_screen.dart';

class ResultScreen extends StatelessWidget {
  final AssessmentModel assessment;

  const ResultScreen({Key? key, required this.assessment}) : super(key: key);

  Color _getSkillLevelColor(int level) {
    switch (level) {
      case 1:
        return Colors.red;
      case 2:
        return Colors.orange;
      case 3:
        return Colors.blue;
      case 4:
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String _getSkillLevelDescription(int level) {
    switch (level) {
      case 1:
        return 'Beginner - FTT 100%, Efficiency < 40%';
      case 2:
        return 'Intermediate - FTT 100%, Efficiency 40-60%';
      case 3:
        return 'Advanced - FTT 100%, Efficiency 60-80%';
      case 4:
        return 'Expert - FTT 100%, Efficiency > 80%';
      default:
        return 'Unknown';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Assessment Results'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Skill Level Card (prominent display)
            Card(
              elevation: 4,
              color: _getSkillLevelColor(assessment.skillLevel),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    const Icon(Icons.stars, size: 64, color: Colors.white),
                    const SizedBox(height: 12),
                    Text(
                      'Skill Level ${assessment.skillLevel}',
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _getSkillLevelDescription(assessment.skillLevel),
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Key Metrics
            _buildSectionTitle(context, 'Key Metrics'),
            _buildMetricCard(
              context,
              'Efficiency',
              '${assessment.efficiency.toStringAsFixed(2)}%',
              Icons.trending_up,
              Colors.blue,
            ),
            const SizedBox(height: 12),
            _buildMetricCard(
              context,
              'First Time Through (FTT)',
              '${assessment.ftt.toStringAsFixed(2)}%',
              Icons.check_circle_outline,
              Colors.green,
            ),
            const SizedBox(height: 12),
            _buildMetricCard(
              context,
              'SSV (Standard Second Value)',
              assessment.ssv.toStringAsFixed(2),
              Icons.timer,
              Colors.orange,
            ),
            const SizedBox(height: 12),
            _buildMetricCard(
              context,
              'Average Time',
              '${assessment.averageTime.toStringAsFixed(2)} sec',
              Icons.av_timer,
              Colors.purple,
            ),
            const SizedBox(height: 24),

            // Work Details
            _buildSectionTitle(context, 'Work Details'),
            _buildInfoCard(context, [
              _buildInfoRow('Style', assessment.styleName),
              _buildInfoRow('Operation', assessment.operationName),
              _buildInfoRow('SMV', assessment.smv.toStringAsFixed(2)),
              _buildInfoRow('Machine Type', assessment.machineType),
              _buildInfoRow('Team Member', assessment.teamMember),
              _buildInfoRow('EPF', assessment.epf),
              _buildInfoRow('Shift', assessment.shift),
              _buildInfoRow('Module', 'Module ${assessment.moduleNumber}'),
              _buildInfoRow('Responsible IE', assessment.responsibleIE),
              _buildInfoRow('Date', assessment.date.toString().split(' ')[0]),
            ]),
            const SizedBox(height: 24),

            // Timer Details
            _buildSectionTitle(context, 'Timer Details'),
            _buildInfoCard(context, [
              _buildInfoRow(
                'Timers Run',
                '${assessment.timerValues.length} out of 10',
              ),
              _buildInfoRow(
                'Good Garments',
                assessment.numberOfGoodGarments.toString(),
              ),
            ]),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Timer Values (seconds):',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: assessment.timerValues
                          .asMap()
                          .entries
                          .map(
                            (entry) => Chip(
                              label: Text(
                                '${entry.key + 1}: ${entry.value.toStringAsFixed(1)}s',
                              ),
                              backgroundColor: Colors.blue[100],
                            ),
                          )
                          .toList(),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Action Buttons
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const HomeScreen()),
                  (route) => false,
                );
              },
              icon: const Icon(Icons.home),
              label: const Text('Back to Home'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(
        title,
        style: Theme.of(
          context,
        ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildMetricCard(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 32),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context, List<Widget> children) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: children,
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          Text(value, style: const TextStyle(color: Colors.black87)),
        ],
      ),
    );
  }
}
