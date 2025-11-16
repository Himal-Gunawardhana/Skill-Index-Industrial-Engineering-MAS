import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import '../models/style_model.dart';
import '../models/operation_model.dart';
import '../models/user.dart';
import '../models/assessment_model.dart';
import '../models/timer_data.dart';
import '../services/api_service.dart';

class AssessmentProvider with ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();

  // Data lists
  List<StyleModel> styles = [];
  List<OperationModel> operations = [];
  List<UserModel> ieUsers = [];

  // Selected values
  String? selectedStyleId;
  String? selectedOperationId;
  String selectedShift = 'A';
  int selectedModule = 1;
  String? selectedIEId;
  DateTime assessmentDate = DateTime.now();

  // Timers
  List<TimerData> timers = [];
  final List<Timer?> _activeTimers = List.filled(10, null);

  // State
  bool isLoading = false;
  bool isSaving = false;
  AssessmentModel? lastSavedAssessment;

  AssessmentProvider() {
    // Initialize 10 timers - only first one unlocked
    for (int i = 0; i < 10; i++) {
      timers.add(
        TimerData(
          index: i,
          isLocked: i != 0, // Only first timer (index 0) is unlocked
        ),
      );
    }
  }

  StyleModel? get selectedStyle {
    if (selectedStyleId == null) return null;
    return styles.firstWhere((s) => s.id == selectedStyleId);
  }

  OperationModel? get selectedOperation {
    if (selectedOperationId == null) return null;
    return operations.firstWhere((o) => o.id == selectedOperationId);
  }

  UserModel? get selectedIE {
    if (selectedIEId == null) return null;
    return ieUsers.firstWhere((u) => u.id == selectedIEId);
  }

  Future<void> loadData() async {
    isLoading = true;
    notifyListeners();

    try {
      final results = await Future.wait([
        _firebaseService.getStyles(),
        _firebaseService.getOperations(),
        _firebaseService.getAllIEUsers(),
      ]);

      styles = results[0] as List<StyleModel>;
      operations = results[1] as List<OperationModel>;
      ieUsers = results[2] as List<UserModel>;

      // Automatically set current logged-in user as responsible IE
      final currentUser = _firebaseService.currentUser;
      if (currentUser != null) {
        final userData = await _firebaseService.getUserData(currentUser.uid);
        if (userData != null) {
          // Add current user to IE users list if not already there
          if (!ieUsers.any((u) => u.id == userData.id)) {
            ieUsers.add(userData);
          }
          selectedIEId = userData.id;
        } else if (ieUsers.isNotEmpty) {
          selectedIEId = ieUsers.first.id;
        }
      } else if (ieUsers.isNotEmpty) {
        selectedIEId = ieUsers.first.id;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error loading data: $e');
      }
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void setSelectedStyle(String styleId) {
    selectedStyleId = styleId;
    notifyListeners();
  }

  void setSelectedOperation(String operationId) {
    selectedOperationId = operationId;
    notifyListeners();
  }

  void setSelectedShift(String shift) {
    selectedShift = shift;
    notifyListeners();
  }

  void setSelectedModule(int module) {
    selectedModule = module;
    notifyListeners();
  }

  void setSelectedIE(String ieId) {
    selectedIEId = ieId;
    notifyListeners();
  }

  String getFormattedDate() {
    return DateFormat('dd MMM yyyy').format(assessmentDate);
  }

  // Timer controls
  void startTimer(int index) {
    if (_activeTimers[index] != null) return; // Already running

    timers[index].isRunning = true;
    timers[index].hasRun = true; // Mark that this timer has been used

    _activeTimers[index] = Timer.periodic(const Duration(milliseconds: 100), (
      timer,
    ) {
      timers[index].elapsedSeconds += 0.1;
      notifyListeners();
    });

    notifyListeners();
  }

  void pauseTimer(int index) {
    _activeTimers[index]?.cancel();
    _activeTimers[index] = null;
    timers[index].isRunning = false;

    // Unlock next timer if exists when paused
    if (index < timers.length - 1) {
      timers[index + 1].isLocked = false;
    }

    notifyListeners();
  }

  void stopTimer(int index) {
    _activeTimers[index]?.cancel();
    _activeTimers[index] = null;
    timers[index].isRunning = false;

    // Unlock next timer if exists
    if (index < timers.length - 1) {
      timers[index + 1].isLocked = false;
    }

    notifyListeners();
  }

  void resetTimer(int index) {
    _activeTimers[index]?.cancel();
    _activeTimers[index] = null;
    timers[index].elapsedSeconds = 0.0;
    timers[index].isRunning = false;
    timers[index].hasRun = false; // Reset the hasRun flag
    notifyListeners();
  }

  int getRunTimersCount() {
    return timers.where((t) => t.hasRun && t.elapsedSeconds > 0).length;
  }

  double getAverageTime() {
    final runTimers = timers
        .where((t) => t.hasRun && t.elapsedSeconds > 0)
        .toList();
    if (runTimers.isEmpty) return 0.0;

    final sum = runTimers.fold<double>(
      0.0,
      (sum, timer) => sum + timer.elapsedSeconds,
    );
    return sum / runTimers.length;
  }

  Future<void> saveAssessment({
    required String teamMember,
    required String epf,
    required int numberOfGoodGarments,
  }) async {
    if (selectedStyle == null || selectedOperation == null) {
      throw Exception('Please complete all required fields');
    }

    isSaving = true;
    notifyListeners();

    try {
      // Get current user's first name
      final currentUser = _firebaseService.currentUser;
      if (currentUser == null) {
        throw Exception('User not logged in');
      }

      final userData = await _firebaseService.getUserData(currentUser.uid);
      final userName = userData?.name ?? 'Unknown';
      final firstName = userName.split(' ').first; // Extract first name
      final smv = selectedOperation!.smv; // Get SMV from selected operation
      final machineType = selectedOperation!.machineType; // Get machineType from selected operation
      final ssv = smv * 60; // SSV = SMV * 60
      final avgTime = getAverageTime();
      final efficiency = avgTime > 0 ? (ssv / avgTime) * 100 : 0.0;
      final runTimersCount = getRunTimersCount();
      final ftt = runTimersCount > 0
          ? (numberOfGoodGarments / runTimersCount) * 100
          : 0.0;

      final skillLevel = AssessmentModel.calculateSkillLevel(ftt, efficiency);

      // Collect only the values from run timers
      final timerValues = timers
          .where((t) => t.hasRun && t.elapsedSeconds > 0)
          .map((t) => t.elapsedSeconds)
          .toList();

      final assessment = AssessmentModel(
        id: '',
        styleId: selectedStyleId!,
        styleName: selectedStyle!.name,
        operationId: selectedOperationId!,
        operationName: selectedOperation!.name,
        smv: smv,
        machineType: machineType,
        shift: selectedShift,
        teamMember: teamMember,
        epf: epf,
        date: assessmentDate,
        responsibleIE: firstName, // Use first name only
        moduleNumber: selectedModule,
        timerValues: timerValues,
        numberOfGoodGarments: numberOfGoodGarments,
        ssv: ssv,
        averageTime: avgTime,
        efficiency: efficiency,
        ftt: ftt,
        skillLevel: skillLevel,
        createdBy: _firebaseService.currentUser!.uid,
      );

      await _firebaseService.saveAssessment(assessment);
      lastSavedAssessment = assessment;
    } catch (e) {
      if (kDebugMode) {
        print('Error saving assessment: $e');
      }
      rethrow;
    } finally {
      isSaving = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    // Cancel all active timers
    for (var timer in _activeTimers) {
      timer?.cancel();
    }
    super.dispose();
  }
}
