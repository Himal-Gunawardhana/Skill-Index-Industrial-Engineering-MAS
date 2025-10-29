import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/assessment_provider.dart';

class TimerWidget extends StatelessWidget {
  final int timerIndex;

  const TimerWidget({Key? key, required this.timerIndex}) : super(key: key);

  String _formatTime(double seconds) {
    final minutes = (seconds / 60).floor();
    final secs = (seconds % 60).floor();
    final millis = ((seconds - seconds.floor()) * 10).floor();
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}.${millis}';
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AssessmentProvider>(
      builder: (context, provider, child) {
        final timer = provider.timers[timerIndex];
        final isRunning = timer.isRunning;
        final hasRun = timer.hasRun;

        return Card(
          elevation: hasRun ? 3 : 1,
          color: hasRun ? Colors.blue[50] : null,
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                // Timer number
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: hasRun ? Colors.blue : Colors.grey[300],
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '${timerIndex + 1}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: hasRun ? Colors.white : Colors.black87,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Timer display
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _formatTime(timer.elapsedSeconds),
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            fontFamily: 'monospace',
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Control buttons
                if (!isRunning && timer.elapsedSeconds == 0)
                  // Start button (only when timer is at 0)
                  IconButton(
                    icon: const Icon(Icons.play_arrow),
                    color: Colors.green,
                    onPressed: () {
                      provider.startTimer(timerIndex);
                    },
                    tooltip: 'Start',
                  ),

                if (isRunning)
                  // Pause button (when running)
                  IconButton(
                    icon: const Icon(Icons.pause),
                    color: Colors.orange,
                    onPressed: () {
                      provider.pauseTimer(timerIndex);
                    },
                    tooltip: 'Pause',
                  ),

                if (!isRunning && timer.elapsedSeconds > 0)
                  // Resume button (when paused)
                  IconButton(
                    icon: const Icon(Icons.play_arrow),
                    color: Colors.green,
                    onPressed: () {
                      provider.startTimer(timerIndex);
                    },
                    tooltip: 'Resume',
                  ),

                if (!isRunning && timer.elapsedSeconds > 0)
                  // Stop button (when paused, to finalize)
                  IconButton(
                    icon: const Icon(Icons.stop),
                    color: Colors.red,
                    onPressed: () {
                      provider.stopTimer(timerIndex);
                    },
                    tooltip: 'Stop',
                  ),

                if (timer.elapsedSeconds > 0)
                  // Reset button
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    color: Colors.blue,
                    onPressed: () {
                      provider.resetTimer(timerIndex);
                    },
                    tooltip: 'Reset',
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
