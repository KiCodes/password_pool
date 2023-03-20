class UserModel{
  final String id;
  final String name;
  final String email;
  final int age;

  UserModel({required this.id,required this.name,required this.email,required  this.age});

  factory UserModel.fromJson(Map<String, dynamic> data) =>
  //any type of data can be gotten hence dynamic
      UserModel(
          id: data['id'],
          name: data['name'],
          email: data['email'],
          age: data['age']);

  Map<String, dynamic> toMap()=>{
  'id': id,
  'name': name,
  'email':email,
  'age': age,
  };
}