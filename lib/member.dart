class Member {
  final String id;
  final String password;
  final String name;
  final Gender gender;
  final String email;

  Member(
      {required this.id,
      required this.password,
      required this.name,
      required this.gender,
      required this.email});

  factory Member.fromJson(Map<String, dynamic> json) => Member(
      id: json["id"],
      password: json["password"],
      name: json["name"],
      gender: json["gender"],
      email: json["email"]);

  Map<String, dynamic> toJson() => {
    'id': id,
    'password': password,
    'name': name,
    'gender': gender,
    'email': email
  };
}

enum Gender { MALE, FEMALE }
