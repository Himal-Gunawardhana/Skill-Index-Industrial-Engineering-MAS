import 'package:cloud_firestore/cloud_firestore.dart';

class AssessmentModel {
  final String id;
  final String styleId;
  final String styleName;
  final String operationId;
  final String operationName;
  final double smv;
  final String machineType;
  final String shift; // A or B
  final String teamMember;
  final String epf;
  final DateTime date;
  final String responsibleIE;
  final int moduleNumber; // 1-26
  final List<double> timerValues; // Only values from run timers
  final int numberOfGoodGarments;
  final double ssv; // SMV * 60
  final double averageTime;
  final double efficiency; // (SSV/avg) * 100
  final double ftt; // Number of good garments / count of timers run
  final int skillLevel; // 1-4
  final String createdBy; // User ID

  AssessmentModel({
    required this.id,
    required this.styleId,
    required this.styleName,
    required this.operationId,
    required this.operationName,
    required this.smv,
    this.machineType = '',
    required this.shift,
    required this.teamMember,
    required this.epf,
    required this.date,
    required this.responsibleIE,
    required this.moduleNumber,
    required this.timerValues,
    required this.numberOfGoodGarments,
    required this.ssv,
    required this.averageTime,
    required this.efficiency,
    required this.ftt,
    required this.skillLevel,
    required this.createdBy,
  });

  factory AssessmentModel.fromMap(Map<String, dynamic> map, String id) {
    return AssessmentModel(
      id: id,
      styleId: map['styleId'] ?? '',
      styleName: map['styleName'] ?? '',
      operationId: map['operationId'] ?? '',
      operationName: map['operationName'] ?? '',
      smv: (map['smv'] ?? 0).toDouble(),
      machineType: map['machineType'] ?? '',
      shift: map['shift'] ?? 'A',
      teamMember: map['teamMember'] ?? '',
      epf: map['epf'] ?? '',
      date: (map['date'] as Timestamp).toDate(),
      responsibleIE: map['responsibleIE'] ?? '',
      moduleNumber: map['moduleNumber'] ?? 1,
      timerValues: List<double>.from(map['timerValues'] ?? []),
      numberOfGoodGarments: map['numberOfGoodGarments'] ?? 0,
      ssv: (map['ssv'] ?? 0).toDouble(),
      averageTime: (map['averageTime'] ?? 0).toDouble(),
      efficiency: (map['efficiency'] ?? 0).toDouble(),
      ftt: (map['ftt'] ?? 0).toDouble(),
      skillLevel: map['skillLevel'] ?? 1,
      createdBy: map['createdBy'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'styleId': styleId,
      'styleName': styleName,
      'operationId': operationId,
      'operationName': operationName,
      'smv': smv,
      'machineType': machineType,
      'shift': shift,
      'teamMember': teamMember,
      'epf': epf,
      'date': Timestamp.fromDate(date),
      'responsibleIE': responsibleIE,
      'moduleNumber': moduleNumber,
      'timerValues': timerValues,
      'numberOfGoodGarments': numberOfGoodGarments,
      'ssv': ssv,
      'averageTime': averageTime,
      'efficiency': efficiency,
      'ftt': ftt,
      'skillLevel': skillLevel,
      'createdBy': createdBy,
    };
  }

  // Calculate skill level based on FTT and Efficiency
  static int calculateSkillLevel(double ftt, double efficiency) {
    if (ftt == 100.0) {
      if (efficiency < 40) return 1;
      if (efficiency < 60) return 2;
      if (efficiency < 80) return 3;
      return 4; // efficiency >= 80
    }
    return 1; // Default if FTT is not 100%
  }
}
