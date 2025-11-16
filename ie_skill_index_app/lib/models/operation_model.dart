class OperationModel {
  final String id;
  final String name;
  final String description;
  final double smv;
  final String machineType;

  OperationModel({
    required this.id,
    required this.name,
    this.description = '',
    this.smv = 0.0,
    this.machineType = '',
  });

  factory OperationModel.fromMap(Map<String, dynamic> map, String id) {
    return OperationModel(
      id: id,
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      smv: (map['smv'] ?? 0).toDouble(),
      machineType: map['machineType'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'smv': smv,
      'machineType': machineType,
    };
  }
}
