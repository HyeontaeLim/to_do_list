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

