/// User Model
class User {
  final String id;
  final String email;
  final String name;
  final String? createdAt;

  User({
    required this.id,
    required this.email,
    required this.name,
    this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'] ?? json['id'] ?? '',
      email: json['email'] ?? '',
      name: json['profile']?['name'] ?? json['name'] ?? '',
      createdAt: json['createdAt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'createdAt': createdAt,
    };
  }

  User copyWith({
    String? id,
    String? email,
    String? name,
    String? createdAt,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
