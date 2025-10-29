class TimerData {
  final int index;
  double elapsedSeconds;
  bool isRunning;
  bool hasRun; // Track if this timer has been used

  TimerData({
    required this.index,
    this.elapsedSeconds = 0.0,
    this.isRunning = false,
    this.hasRun = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'index': index,
      'elapsedSeconds': elapsedSeconds,
      'isRunning': isRunning,
      'hasRun': hasRun,
    };
  }

  factory TimerData.fromMap(Map<String, dynamic> map) {
    return TimerData(
      index: map['index'] ?? 0,
      elapsedSeconds: (map['elapsedSeconds'] ?? 0).toDouble(),
      isRunning: map['isRunning'] ?? false,
      hasRun: map['hasRun'] ?? false,
    );
  }
}
