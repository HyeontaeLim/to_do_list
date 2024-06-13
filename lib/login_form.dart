class LoginForm {
  final String username;
  final String password;

  LoginForm(
      {required this.username,
        required this.password});

  factory LoginForm.fromJson(Map<String, dynamic> json) => LoginForm(
    username : json["username"],
      password: json["password"]);

  Map<String, dynamic> toJson() => {
    'username': username,
    'password': password
  };
}