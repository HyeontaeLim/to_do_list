import 'dart:html';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
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
  var selectedDay = DateTime.now();

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
          showDialog(context: context, builder: (context) {
            return Dialog(child: Form(
                child: Column(children: [
                  ListTile(leading: Text('할 일', style: TextStyle(
                      fontSize: 20),), title: TextFormField(controller: inputData)),
                  Row(mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(onPressed: () async {
                        var url = Uri.parse("http://localhost:8080/memos");
                          await http.post(url, headers: <String, String>{
                          'Content-Type': 'application/json; charset=UTF-8',
                        }, body: jsonEncode({
                          'memo': inputData.text,
                          'dTime': DateTime.now().toIso8601String()}));
                          getMemoList();
                          inputData.clear();
                          Navigator.pop(context);

                      }, child: Text('추가')),
                      TextButton(onPressed: () async{
                        Navigator.pop(context);
                      }, child: Text('취소')),
                    ],
                  ),
                  TableCalendar(focusedDay: DateTime.now(), firstDay: DateTime(2024, 1, 1), lastDay: DateTime(2026,12,31),
                    onDaySelected: (DateTime selectedDay, DateTime focusedDay) {setState(() {
                      this.selectedDay = selectedDay;
                      print(this.selectedDay);
                    });},
                  )

                ],)
            )
            );
          });
        }),
        appBar: AppBar(title: Text('To-do list', style: TextStyle(
            fontWeight: FontWeight.bold, fontStyle: FontStyle.italic)),
            backgroundColor: Color(0xBCDDF1FF)),
        body: ListView.builder(itemCount: list.length, itemBuilder: (c, i) {
          return ListTile(
            leading: Icon(Icons.arrow_forward_ios), title: Text(list[i]['memo']),);
        }),
        bottomNavigationBar: BottomAppBar(
          child: Text('아직 없음'), color: Colors.red,)
    );
  }

   getMemoList () async {
     var res = await http.get(Uri.parse("http://localhost:8080/memos"));
     setState(() {
     var body = jsonDecode(res.body);
     list = body;
     print(body);
   });
  }
}



