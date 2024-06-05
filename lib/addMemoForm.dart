import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

import 'memo.dart';

class addMemoForm extends StatefulWidget {
  final List<Memo> list;
  final Function getMemoList;
  final Function(int) setWidgetIndex;

  const addMemoForm({
    required this.list,
    required this.getMemoList,
    required this.setWidgetIndex,
    super.key});

  @override
  State<addMemoForm> createState() => _addMemoFormState();
}

class _addMemoFormState extends State<addMemoForm> {

  TextEditingController inputData = TextEditingController();
  TextEditingController inputHour = TextEditingController(text: DateTime.now().hour.toString().padLeft(2,'0'));
  TextEditingController inputMinute = TextEditingController(text: DateTime.now().minute.toString().padLeft(2,'0'));
  DateTime selectedDay = DateTime.now();
  DateTime today = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        ListTile(
          leading: Text('할 일', style: TextStyle(fontSize: 20)),
          title: TextField(controller: inputData),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              onPressed: () async {
                var url = Uri.http('10.0.2.2:8080','/memos');
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
                widget.getMemoList();
                widget.setWidgetIndex(0);
              },
              child: Text('추가'),
            ),
            TextButton(
              onPressed: (){widget.setWidgetIndex(0);},
              child: Text('취소'),
            ),
          ],
        ),
        TableCalendar(
          focusedDay: selectedDay,
          firstDay: today.subtract(Duration(days: 365)),
          lastDay: today.add(Duration(days: 365*5)),
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
            SizedBox(width:30, child: TextField(controller: inputHour, maxLength: 2)),
            Text('시'),
            SizedBox(width:30, child: TextField(controller: inputMinute, maxLength: 2)),
            Text('분'),
          ],
        ),
      ],
    );
  }
}


