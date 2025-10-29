class UserModel {
  final String id;
  final String name;
  final String email;
  final bool isAdmin;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.isAdmin = false,
  });

  factory UserModel.fromMap(Map<String, dynamic> map, String id) {
    return UserModel(
      id: id,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      isAdmin: map['isAdmin'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {'name': name, 'email': email, 'isAdmin': isAdmin};
  }
}
