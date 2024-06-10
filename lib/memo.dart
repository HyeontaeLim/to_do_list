import 'package:to_do_list_project/addMemoForm.dart';

class Memo{
  final int id;
  final String memo;
  final DateTime created;
  final DateTime dTime;

  Memo({
    required this.id,
    required this.memo,
    required this.created,
    required this.dTime
  });

  factory Memo.fromJson(Map<String,dynamic> json) => Memo(
    id: json["id"],
    memo: json["memo"],
    created: DateTime.parse(json["created"]),
    dTime: DateTime.parse(json["dTime"])
  );
}

class AddUpdateMemo{
  final String memo;
  final DateTime dTime;

  AddUpdateMemo({
    required this.memo,
    required this.dTime
  });

  factory AddUpdateMemo.fromJson(Map<String, dynamic> json) => AddUpdateMemo(
      memo: json["memo"],
      dTime: json["dTime"]);

  Map<String, dynamic> toJson() => {
    'memo': memo,
    'dTime': dTime.toIso8601String()
  };
}
