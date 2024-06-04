//import 'dart:html';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:to_do_list_project/addMemoForm.dart';
import 'package:to_do_list_project/mainPage.dart';
import 'dart:convert';

import 'memo.dart';

void main() {
  runApp(MaterialApp(home: MyApp()));
}

class MyApp extends StatefulWidget {
  MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  var list = [];
  var inputData = TextEditingController();
  var inputHour = TextEditingController();
  var inputMinute = TextEditingController();
  var inputSeconds = TextEditingController();
  DateTime selectedDay = DateTime.now();
  DateTime today = DateTime.now();
  String? _orderType = "dTimeDsc";
  int widgetNum = 1;

  @override
  Widget build(BuildContext context) {
    List<Widget> widgets = [
      main
      addMemoForm(inputData: inputData, inputHour: inputHour, inputMinute: inputMinute, selectedDay: selectedDay, list: list, getMemoList: getMemoList)
    ];

    return Scaffold(
        floatingActionButton: FloatingActionButton(
            child: Icon(Icons.add), onPressed: () {}),
        appBar: AppBar(title: Text('To-do list', style: TextStyle(
            fontWeight: FontWeight.bold, fontStyle: FontStyle.italic)),
            actions: [DropdownButtonHideUnderline(child: DropdownButton(value: _orderType, icon: Icon(Icons.sort), iconSize: 35, items: const[
              DropdownMenuItem(
                  value: 'createdDsc',
                  child: Text('오래된 순')
              ),
              DropdownMenuItem(
                  value: 'createdAsc',
                  child: Text('최신순')
              ),
              DropdownMenuItem(
                  value: 'dTimeDsc',
                  child: Text('가까운 목표 순')
              ),
              DropdownMenuItem(
                  value: 'dTimeAsc',
                  child: Text('먼 목표 순')
              ),
            ], onChanged: (newValue) {
              _orderType = newValue!;
              getMemoList();
            },)) ],
            backgroundColor: Color(0xBCDDF1FF)),
        body: Center(
          child: ,
        ),
    );
  }

  getMemoList () async {
    var res = await http.get(Uri.http('10.0.2.2:8080', '/memos', {'orderType': _orderType}));
    setState(() {
      var parsedBody = jsonDecode(res.body);
      list.clear();
      for (var memo in parsedBody) {
        list.add(Memo.fromJson(memo));
      }
      print(parsedBody);
    });
  }

  postMemo() async {

  }
}




