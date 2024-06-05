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

  List<Memo> _list = [];
  String? _orderType = "dTimeDsc";
  int _widgetIndex = 0;
  int _memoIndex = 0;
  final PageController _pageController = PageController(initialPage: 0, );


  int get widgetIndex => _widgetIndex;

  setWidgetIndex(int value) {
    setState(() {
      _widgetIndex = value;
    });
    _pageController.animateToPage(value, duration: Duration(milliseconds: 400), curve: Curves.ease);
  }

  setIndex(int value, int memoIndex) {
    setState(() {
      _widgetIndex = value;
      _memoIndex = memoIndex;
    });
    _pageController.animateToPage(value, duration: Duration(milliseconds: 400), curve: Curves.ease);
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
      mainPage(list: _list, getMemoList: getMemoList,setWidgetIndex: (widgetIndex) => setWidgetIndex(widgetIndex), setIndex: (widgetIndex, memoIndex) => setIndex(widgetIndex, memoIndex)),
      addMemoForm(list: _list, getMemoList: getMemoList, setWidgetIndex: (index) => setWidgetIndex(index)),
      correctMemoForm(list: _list, getMemoList: getMemoList, setWidgetIndex: (index) => setWidgetIndex(index), memoIndex: _memoIndex)
    ];

    return Scaffold(
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
      body: PageView(controller: _pageController, scrollDirection: Axis.vertical,children: widgets, ),
    );
  }

  getMemoList() async {
    var res = await http.get(Uri.http('10.0.2.2:8080', '/memos', {'orderType': _orderType}));
    setState(() {
      var parsedBody = jsonDecode(res.body);
      _list.clear();
      for (var memo in parsedBody) {
        _list.add(Memo.fromJson(memo));
      }
      print(parsedBody);
    });
  }
}