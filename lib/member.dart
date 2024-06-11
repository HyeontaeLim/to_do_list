
class Member {
  final int memberId;
  final String username;
  final String password;
  final String name;
  final Gender gender;
  final String email;

  Member(
      {required this.memberId,
      required this.username,
      required this.password,
      required this.name,
      required this.gender,
      required this.email});

  factory Member.fromJson(Map<String, dynamic> json) => Member(
      memberId: json["memberId"],
      username: json["memberId"],
      password: json["password"],
      name: json["name"],
      gender: json["gender"],
      email: json["email"]);

  Map<String, dynamic> toJson() => {
        'memberId': memberId,
        'username': username,
        'password': password,
        'name': name,
        'gender': gender,
        'email': email
      };
}

class AddUpdateMember {
  final String username;
  final String password;
  final String name;
  final Gender? gender;
  final String email;

  AddUpdateMember(
      {required this.username,
        required this.password,
        required this.name,
        required this.gender,
        required this.email});

  factory AddUpdateMember.fromJson(Map<String, dynamic> json) => AddUpdateMember(
      username: json["memberId"],
      password: json["password"],
      name: json["name"],
      gender: GenderExtension.fromValue(json["gender"]),
      email: json["email"]);

  Map<String, dynamic> toJson() => {
    'username': username,
    'password': password,
    'name': name,
    'gender': gender.value,
    'email': email
  };
}

enum Gender {
  MALE,
  FEMALE
}
  extension GenderExtension on Gender? {
  String? get value {
    if(this == Gender.MALE) {
      return "MALE";
    }else if(this == Gender.FEMALE) {
      return "FEMALE";
    }
    return null;
  }

  static Gender fromValue(String value) {
    switch (value) {
      case "MALE":
        return Gender.MALE;
      case "FEMALE":
        return Gender.FEMALE;
      default:
        throw ArgumentError("Unknown enum value: $value");
    }
  }
}

