class OperationModel {
  final String id;
  final String name;
  final String description;

  OperationModel({required this.id, required this.name, this.description = ''});

  factory OperationModel.fromMap(Map<String, dynamic> map, String id) {
    return OperationModel(
      id: id,
      name: map['name'] ?? '',
      description: map['description'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {'name': name, 'description': description};
  }
}
