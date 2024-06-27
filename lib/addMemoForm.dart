import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:to_do_list_project/memo_form.dart';

import 'memo.dart';

class AddMemoForm extends StatefulWidget {
  final List<Memo> list;
  final Function() getMemoList;
  final Function(int) setWidgetIndex;

  const AddMemoForm(
      {required this.list,
      required this.getMemoList,
      required this.setWidgetIndex,
      super.key});

  @override
  State<AddMemoForm> createState() => _AddMemoFormState();
}

class _AddMemoFormState extends State<AddMemoForm> {
  @override
  Widget build(BuildContext context) {
    return MemoForm(
      list: widget.list,
      getMemoList: widget.getMemoList,
      setWidgetIndex: widget.setWidgetIndex,
      httpRequest: postMemo,
      initInputData: TextEditingController(),
      initSelectedDay: DateTime.now(),
      initSelectedTime: TimeOfDay.now(),
      confirmText: "추가",
    );
  }

  Future<Response> postMemo(String? jSessionId, String inputData, DateTime selectedDay) {
    return http.post(
      Uri.http('ec2-3-107-48-252.ap-southeast-2.compute.amazonaws.com:8080', '/memos'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Cookie': 'JSESSIONID=$jSessionId'
      },
      body: jsonEncode(AddUpdateMemo(
              memo: inputData, dTime: selectedDay, isCompleted: false)
          .toJson()),
    );
  }
}
