import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:to_do_list_project/addMemoForm.dart';
import 'package:to_do_list_project/correctMemoForm.dart';
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

  List<Memo> list = [];
  DateTime selectedDay = DateTime.now();
  DateTime today = DateTime.now();
  String? _orderType = "dTimeDsc";
  int _widgetIndex = 0;
  int _memoIndex = 0;


  int get widgetIndex => _widgetIndex;

  setWidgetIndex(int value) {
    setState(() {
      _widgetIndex = value;
    });
  }
  setIndex(int value, int memoIndex) {
    setState(() {
      _widgetIndex = value;
      _memoIndex = memoIndex;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getMemoList();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> widgets = [
      mainPage(list: list, getMemoList: getMemoList, setIndex: (widgetIndex, memoIndex) => setIndex(widgetIndex, memoIndex)),
      addMemoForm(list: list, getMemoList: getMemoList, setWidgetIndex: (index) => setWidgetIndex(index)),
      correctMemoForm(list: list, getMemoList: getMemoList, setWidgetIndex: (index) => setWidgetIndex(index), memoIndex: _memoIndex)
    ];

    return Scaffold(
      floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add), onPressed: (){setWidgetIndex(1);}),
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
        child: widgets[_widgetIndex],
      ),
    );
  }

  getMemoList() async {
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
}