class StyleModel {
  final String id;
  final String name;

  StyleModel({required this.id, required this.name});

  factory StyleModel.fromMap(Map<String, dynamic> map, String id) {
    return StyleModel(id: id, name: map['name'] ?? '');
  }

  Map<String, dynamic> toMap() {
    return {'name': name};
  }
}
