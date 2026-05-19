class UserModel {
  final String username;
  final String email;
  final String password;

  const UserModel({
    required this.username,
    required this.email,
    required this.password,
  });

  Map<String, dynamic> toMap() => {
        'username': username,
        'email': email,
        'password': password,
      };

  factory UserModel.fromMap(Map<String, dynamic> map) => UserModel(
        username: map['username'] as String,
        email: map['email'] as String,
        password: map['password'] as String,
      );
}