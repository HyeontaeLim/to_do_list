import 'dart:html';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'dart:convert';

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
  String? _orderType = "dTimeDsc";

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getMemoList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        floatingActionButton: FloatingActionButton(
            child: Icon(Icons.add), onPressed: () {
          inputHour = TextEditingController(text: DateTime.now().hour.toString().padLeft(2,'0'));
          inputMinute = TextEditingController(text: DateTime.now().minute.toString()..padLeft(2,'0'));
          showDialog(context: context, builder: (context) {
            return buildingAddDialog(context);
          });
        }),
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
        body: ListView.builder(itemCount: list.length, itemBuilder: (c, i) {
          return Dismissible(
              key: Key("${list[i]['id']}"),
              direction: DismissDirection.endToStart, // 오른쪽에서 왼쪽으로 스와이프
              onDismissed: (direction)
                async{
                  var url = Uri.parse("http://localhost:8080/memos/${list[i]['id']}");
                  await http.delete(url);
                  getMemoList();
              },
              child: Container(decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.black, width: 1))),
            child: Column(
                children: [ListTile(title: Text(list[i]['memo'])),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [Padding(
                      padding: const EdgeInsets.fromLTRB(20,0,0,0),
                      child: Text(style: TextStyle(fontSize: 13,color: Colors.grey),
                          "목표일: ${DateTime.parse(list[i]["dTime"]).year}년 "
                              "${DateTime.parse(list[i]["dTime"]).month}월 "
                              "${DateTime.parse(list[i]["dTime"]).day}일 "
                              "${DateTime.parse(list[i]["dTime"]).hour}시 "
                              "${DateTime.parse(list[i]["dTime"]).minute}분"),
                    ),
                      Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                        TextButton(onPressed: () {
                          inputHour = TextEditingController(text: DateTime.parse(list[i]["dTime"]).hour.toString().padLeft(2,'0'));
                          inputMinute = TextEditingController(text: DateTime.parse(list[i]["dTime"]).minute.toString()..padLeft(2,'0'));
                          showDialog(context: context, builder: (context) {
                            inputData = TextEditingController(text: "${list[i]['memo']}");
                            return buildingCorrectDialog(i, context);
                          });
                        }
                            , child: Text('수정')),
                      ],),
                    ],
                  )
                  ,]
            ),
          ));

        }),
        bottomNavigationBar: BottomAppBar(
          child: Text('아직 없음'), color: Colors.red,)
    );
  }

  Dialog buildingAddDialog(BuildContext context) {
    return Dialog(
      child: StatefulBuilder(
        builder: (context, setState) {
          return Form(
            child: Column(
              children: [
                ListTile(
                  leading: Text('할 일', style: TextStyle(fontSize: 20)),
                  title: TextFormField(controller: inputData),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () async {
                        var url = Uri.parse("http://localhost:8080/memos");
                        await http.post(
                          url,
                          headers: <String, String>{
                            'Content-Type': 'application/json; charset=UTF-8',
                          },
                          body: jsonEncode({
                            'memo': inputData.text,
                            'dTime': DateTime(selectedDay.year, selectedDay.month, selectedDay.day, int.parse(inputHour.text), int.parse(inputMinute.text)).toIso8601String()
                          }),
                        );
                        setState(() {
                          selectedDay = DateTime.now();
                          getMemoList();
                          inputData.clear();
                        });
                        Navigator.pop(context);
                      },
                      child: Text('추가'),
                    ),
                    TextButton(
                      onPressed: () {
                        selectedDay = DateTime.now();
                        Navigator.pop(context);
                      },
                      child: Text('취소'),
                    ),
                  ],
                ),
                TableCalendar(
                  focusedDay: selectedDay,
                  firstDay: DateTime(2024, 1, 1),
                  lastDay: DateTime(2026, 12, 31),
                  selectedDayPredicate: (day) {
                    return isSameDay(selectedDay, day);
                  },
                  onDaySelected: (DateTime selectedDay, DateTime focusedDay) {
                    setState(() {
                      this.selectedDay = selectedDay;
                    });
                    print(this.selectedDay);
                  },
                ),
                Row(mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(width:30, child: TextFormField(controller: inputHour, maxLength: 2)),
                    Text('시'),
                    SizedBox(width:30, child: TextFormField(controller: inputMinute, maxLength: 2)),
                    Text('분'),
                  ],
                ),
          ]));
        },
      ),
    );
  }

  Dialog buildingCorrectDialog(int i, BuildContext context) {
    return Dialog(
      child: StatefulBuilder(
        builder: (context, setState) {
          return Form(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ListTile(
                  leading: Text('할 일', style: TextStyle(fontSize: 20)),
                  title: TextFormField(controller: inputData),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () async {
                        var url = Uri.parse("http://localhost:8080/memos/${list[i]["id"]}");
                        await http.put(
                          url,
                          headers: <String, String>{
                            'Content-Type': 'application/json; charset=UTF-8',
                          },
                          body: jsonEncode({
                            'memo': inputData.text,
                            'dTime': DateTime(selectedDay.year, selectedDay.month, selectedDay.day, int.parse(inputHour.text), int.parse(inputMinute.text)).toIso8601String()
                          }),
                        );
                        setState(() {
                          selectedDay = DateTime.now();
                          getMemoList();
                          inputData.clear();
                        });
                        Navigator.pop(context);
                      },
                      child: Text('수정'),
                    ),
                    TextButton(
                      onPressed: () {
                        selectedDay = DateTime.now();
                        Navigator.pop(context);
                      },
                      child: Text('취소'),
                    ),
                  ],
                ),
                TableCalendar(
                  focusedDay: selectedDay,
                  firstDay: DateTime(2024, 1, 1),
                  lastDay: DateTime(2026, 12, 31),
                  selectedDayPredicate: (day) {
                    return isSameDay(selectedDay, day);
                  },
                  onDaySelected: (DateTime selectedDay, DateTime focusedDay) {
                    setState(() {
                      this.selectedDay = selectedDay;
                    });
                    print(this.selectedDay);
                  },
                ),
                Row(mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(width:30, child: TextFormField(controller: inputHour, maxLength: 2)),
                    Text('시'),
                    SizedBox(width:30, child: TextFormField(controller: inputMinute, maxLength: 2)),
                    Text('분'),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

   getMemoList () async {
     var res = await http.get(Uri.http('localhost:8080', '/memos', {'orderType': _orderType}));
     setState(() {
     var body = jsonDecode(res.body);
      list = body;
     print(body);
   });
  }
}



