class UserModel {
  final String id;
  final String name;
  final String email;
  final int age;

  UserModel(
      {required this.id,
      required this.name,
      required this.email,
      required this.age});

  factory UserModel.fromJson(Map<String, dynamic> data) =>
      //any type of data can be gotten hence dynamic
      UserModel(
          id: data['id'],
          name: data['name'],
          email: data['email'],
          age: data['age']);

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'email': email,
        'age': age,
      };
}

class PasswordModel {
  final int? id;
  final String field;
  final String password;
  bool visible;

  PasswordModel({
    this.id,
    this.field = '',
    required this.password,
    this.visible = false,
  });

  factory PasswordModel.fromJson(Map<String, dynamic> data) =>
      //any type of data can be gotten hence dynamic
      PasswordModel(
        id: data['id'] as int?,
        field: data['field'] as String,
        password: data['password'] as String,
      );

  factory PasswordModel.fromMap(Map<String, dynamic> map) {
    return PasswordModel(
      id: map['id'],
      field: map['field'] as String,
      password: map['password'],
    );
  }

  PasswordModel copyWith({int? id, String? password, String? field, bool? visible}) {
    return PasswordModel(
      id: id ?? this.id,
      password: password ?? this.password,
      field: field ?? this.field,
      visible: visible ?? this.visible,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'field': field,
        'password': password,
      };
}
