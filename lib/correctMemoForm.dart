import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

import 'memo.dart';

class correctMemoForm extends StatefulWidget {
  final TextEditingController inputData;
  final TextEditingController inputHour;
  final TextEditingController inputMinute;
  final DateTime selectedDay;
  final List<Memo> list;
  final VoidCallback getMemoList;

  const correctMemoForm({
    required this.inputData,
    required this.inputHour,
    required this.inputMinute,
    required this.selectedDay,
    required this.list,
    required this.getMemoList,
    super.key});

  @override
  State<correctMemoForm> createState() => _correctMemoFormState();
}

class _correctMemoFormState extends State<correctMemoForm> {
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
                var url = Uri.http('10.0.2.2:8080', '/memos/${list[i].id}');
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
                  selectedDay = today;
                  getMemoList();
                  inputData.clear();
                });
              },
              child: Text('수정'),
            ),
            TextButton(
              onPressed: () {
                selectedDay = today;
                Navigator.pop(context);
              },
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
