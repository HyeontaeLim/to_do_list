import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

import 'memo.dart';

class correctMemoForm extends StatefulWidget {
  final List<Memo> list;
  final Function getMemoList;
  final Function(int) setWidgetIndex;
  final int memoIndex;


  const correctMemoForm({
    required this.list,
    required this.getMemoList,
    required this.setWidgetIndex,
    required this.memoIndex,
    super.key});



  @override
  State<correctMemoForm> createState() => _correctMemoFormState();
}

class _correctMemoFormState extends State<correctMemoForm> {
  TextEditingController inputData = TextEditingController();
  TextEditingController inputHour = TextEditingController();
  TextEditingController inputMinute = TextEditingController();
  DateTime _selectedDay = DateTime.now();
  final DateTime _today = DateTime.now();

  @override
  void initState() {
    // TODO: implement initState
    setState(() {
      _selectedDay = widget.list[widget.memoIndex].dTime;
    });
  }

  @override
  Widget build(BuildContext context) {
    inputData = TextEditingController(text: widget.list[widget.memoIndex].memo);
    inputHour = TextEditingController(text: widget.list[widget.memoIndex].dTime.hour.toString().padLeft(2,'0'));
    inputMinute = TextEditingController(text: widget.list[widget.memoIndex].dTime.minute.toString().padLeft(2,'0'));

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
                var url = Uri.http('10.0.2.2:8080', '/memos/${widget.list[widget.memoIndex].id}');
                await http.put(
                  url,
                  headers: <String, String>{
                    'Content-Type': 'application/json; charset=UTF-8',
                  },
                  body: jsonEncode({
                    'memo': inputData.text,
                    'dTime': DateTime(_selectedDay.year, _selectedDay.month, _selectedDay.day, int.parse(inputHour.text), int.parse(inputMinute.text)).toIso8601String()
                  }),
                );
                widget.getMemoList();
                widget.setWidgetIndex(0);
              },
              child: Text('수정'),
            ),
            TextButton(
              onPressed: () {widget.setWidgetIndex(0);},
              child: Text('취소'),
            ),
          ],
        ),
        Container(margin: EdgeInsets.fromLTRB(0, 10, 0, 10),
          child: ElevatedButton(
              style: ElevatedButton.styleFrom(side: BorderSide(color: Colors.black), backgroundColor: Colors.white, fixedSize: Size(300, 100), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
              onPressed: () {
                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      DateTime selectedDate = _selectedDay;
                      return StatefulBuilder(
                        builder: (context, setState){return Dialog(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(12),
                                child: TableCalendar(
                                  focusedDay: selectedDate,
                                  firstDay: _today.subtract(Duration(days: 365)),
                                  lastDay: _today.add(Duration(days: 365*5)),
                                  selectedDayPredicate: (day) {
                                    return isSameDay(selectedDate, day);
                                  },
                                  onDaySelected: (DateTime selectedDay, DateTime focusedDay) {
                                    setState(() {
                                      selectedDate = DateTime(selectedDay.year, selectedDay.month, selectedDay.day, _selectedDay.hour, _selectedDay.minute);
                                    });
                                  },),
                              ),
                              OutlinedButton(onPressed: () {
                                Navigator.of(context).pop(selectedDate);}, child: Text('확인'))
                            ],
                          ),
                        );},
                      );
                    }).then((selectedDate) {
                  setState(() {
                    _selectedDay = selectedDate;
                  });
                  print(_selectedDay);
                });
              }, child: Text(style:TextStyle(fontSize: 30, color: Colors.black, ), DateFormat('yyyy년 MM월 dd일').format(_selectedDay))),
        ),
        Container(margin: EdgeInsets.fromLTRB(0, 10, 0, 10),
          child: ElevatedButton(
              style: ElevatedButton.styleFrom(side: BorderSide(color: Colors.black), backgroundColor: Colors.white, fixedSize: Size(300, 100), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
              onPressed: () {
                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return Dialog(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Column(
                            children: [
                              Row(mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(width:30, child: TextField(controller: inputHour, maxLength: 2)),
                                  Text('시'),
                                  SizedBox(width:30, child: TextField(controller: inputMinute, maxLength: 2)),
                                  Text('분'),],),
                              OutlinedButton(onPressed: () {
                                setState(() {
                                  _selectedDay = DateTime(_selectedDay.year, _selectedDay.month, _selectedDay.day, int.parse(inputHour.text), int.parse(inputMinute.text));
                                });
                                Navigator.pop(context);
                              }, child: Text('확인'))
                            ],
                          )
                      );});},
              child: Text(style:TextStyle(fontSize: 30, color: Colors.black, ), DateFormat('HH시 mm분').format(_selectedDay))),
        ),
      ],
    );
  }
}
