class TimerData {
  final int index;
  double elapsedSeconds;
  bool isRunning;
  bool hasRun; // Track if this timer has been used
  bool isLocked; // Track if this timer is locked

  TimerData({
    required this.index,
    this.elapsedSeconds = 0.0,
    this.isRunning = false,
    this.hasRun = false,
    this.isLocked = true, // Locked by default
  });

  Map<String, dynamic> toMap() {
    return {
      'index': index,
      'elapsedSeconds': elapsedSeconds,
      'isRunning': isRunning,
      'hasRun': hasRun,
      'isLocked': isLocked,
    };
  }

  factory TimerData.fromMap(Map<String, dynamic> map) {
    return TimerData(
      index: map['index'] ?? 0,
      elapsedSeconds: (map['elapsedSeconds'] ?? 0).toDouble(),
      isRunning: map['isRunning'] ?? false,
      hasRun: map['hasRun'] ?? false,
      isLocked: map['isLocked'] ?? true,
    );
  }
}
