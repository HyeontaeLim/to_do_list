import 'dart:ffi';

import 'package:to_do_list_project/addMemoForm.dart';

class Memo{
  final int memoId;
  final String memo;
  final DateTime created;
  final DateTime dTime;
  bool isCompleted;
  final int memberId;

  Memo({
    required this.memoId,
    required this.memo,
    required this.created,
    required this.dTime,
    required this.isCompleted,
    required this.memberId
  });

  factory Memo.fromJson(Map<String,dynamic> json) => Memo(
    memoId: json["memoId"],
    memo: json["memo"],
    created: DateTime.parse(json["created"]),
    dTime: DateTime.parse(json["dTime"]),
    isCompleted: json["isCompleted"],
    memberId: json["memberId"],
  );
}

class AddUpdateMemo{
  final String memo;
  final DateTime dTime;
  final bool isCompleted;

  AddUpdateMemo({
    required this.memo,
    required this.dTime,
    required this.isCompleted
  });

  factory AddUpdateMemo.fromJson(Map<String, dynamic> json) => AddUpdateMemo(
      memo: json["memo"],
      dTime: json["dTime"],
      isCompleted: json["isCompleted"]
  );

  Map<String, dynamic> toJson() => {
    'memo': memo,
    'dTime': dTime.toIso8601String(),
    'isCompleted': isCompleted
  };
}
