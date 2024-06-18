import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:to_do_list_project/memo_form.dart';

import 'ValidationResult.dart';
import 'memo.dart';

class CorrectMemoForm extends StatefulWidget {
  final List<Memo> list;
  final Function getMemoList;
  final Function(int) setWidgetIndex;
  final int memoIndex;


  const CorrectMemoForm({required this.list,
    required this.getMemoList,
    required this.setWidgetIndex,
    required this.memoIndex,
    super.key});

  @override
  State<CorrectMemoForm> createState() => _CorrectMemoFormState();
}

class _CorrectMemoFormState extends State<CorrectMemoForm> {

  @override
  Widget build(BuildContext context) {
    return MemoForm(list: widget.list,
      getMemoList: widget.getMemoList,
      setWidgetIndex: widget.setWidgetIndex,
      httpRequest: putMemo,
      initSelectedDay: widget.list[widget.memoIndex].dTime,
      initSelectedTime: TimeOfDay.fromDateTime(widget.list[widget.memoIndex].dTime),
      initInputData: TextEditingController(text: widget.list[widget.memoIndex].memo),
      confirmText: "수정",
    );
  }

  Future<Response> putMemo(jSessionId, inputData, selectedDay) {
    return http.put(
      Uri.http(
          '10.0.2.2:8080', '/memos/${widget.list[widget.memoIndex].memoId}'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Cookie': 'JSESSIONID=$jSessionId'
      },
      body: jsonEncode(AddUpdateMemo(
          memo: inputData,
          dTime: selectedDay,
          isCompleted: widget.list[widget.memoIndex].isCompleted)
          .toJson()),
    );
  }

}
