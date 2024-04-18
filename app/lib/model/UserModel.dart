class UserModel {
  int? id;
  String email;
  String username;
  String password;
  bool isAdmin;

  UserModel({this.id, required this.email,required this.username,required this.password, this.isAdmin = false,});

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['userId'],
      email: map['email'],
      username: map['username'],
      password: map['password'],
      isAdmin: map['isAdmin'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': id,
      'email': email,
      'username': username,
      'password': password,
      'isAdmin': isAdmin,
    };
  }
}
