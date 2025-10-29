class StyleModel {
  final String id;
  final String name;
  final double smv; // Standard Minute Value

  StyleModel({required this.id, required this.name, required this.smv});

  factory StyleModel.fromMap(Map<String, dynamic> map, String id) {
    return StyleModel(
      id: id,
      name: map['name'] ?? '',
      smv: (map['smv'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {'name': name, 'smv': smv};
  }
}
