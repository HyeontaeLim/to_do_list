class Member {
  final String id;
  final String password;
  final String name;
  final Gender gender;

  Member(
      {required this.id,
      required this.password,
      required this.name,
      required this.gender});

  factory Member.fromJson(Map<String, dynamic> json) => Member(
      id: json["id"],
      password: json["password"],
      name: json["name"],
      gender: json["gender"]);

  Map<String, dynamic> toJson() => {
    'id': id,
    'password': password,
    'name': name,
    'gender': gender
  };
}

enum Gender { MALE, FEMALE }
