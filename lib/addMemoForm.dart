import 'dart:convert';
import 'dart:ui';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:to_do_list_project/ValidationResult.dart';

import 'memo.dart';

class AddMemoForm extends StatefulWidget {
  final List<Memo> list;
  final Function getMemoList;
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
  TextEditingController _inputData = TextEditingController();
  TextEditingController _inputHour = TextEditingController(
      text: DateTime.now().hour.toString().padLeft(2, '0'));
  TextEditingController _inputMinute = TextEditingController(
      text: DateTime.now().minute.toString().padLeft(2, '0'));
  DateTime _selectedDay = DateTime.now();
  DateTime _today = DateTime.now();
  List<FieldErrorDetail> _errors = [];
  String? _memoErr;

  @override
  Widget build(BuildContext context) {

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
            margin: EdgeInsets.all(10),
            child: TextField(
              controller: _inputData,
              decoration: InputDecoration(
                hintText: "할 일을 입력 해 주세요",
                errorText: _memoErr,
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            )),
        Container(
          margin: EdgeInsets.fromLTRB(10, 10, 10, 10),
          width: double.infinity,
          height: 100,
          child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                  side: BorderSide(color: Colors.black),
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10))),
              onPressed: () {
                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      DateTime selectedDate = _selectedDay;
                      return StatefulBuilder(
                        builder: (context, setState) {
                          return Dialog(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: TableCalendar(
                                    focusedDay: selectedDate,
                                    firstDay:
                                        _today.subtract(Duration(days: 365)),
                                    lastDay: _today.add(Duration(days: 365 * 5)),
                                    selectedDayPredicate: (day) {
                                      return isSameDay(selectedDate, day);
                                    },
                                    onDaySelected: (DateTime selectedDay,
                                        DateTime focusedDay) {
                                      setState(() {
                                        selectedDate = DateTime(
                                            selectedDay.year,
                                            selectedDay.month,
                                            selectedDay.day,
                                            _selectedDay.hour,
                                            _selectedDay.minute);
                                      });
                                    },
                                  ),
                                ),
                                OutlinedButton(
                                    onPressed: () {
                                      Navigator.of(context).pop(selectedDate);
                                    },
                                    child: Text('확인'))
                              ],
                            ),
                          );
                        },
                      );
                    }).then((selectedDate) {
                  setState(() {
                    _selectedDay = selectedDate;
                  });
                  print(_selectedDay);
                });
              },
              child: Text(
                  style: TextStyle(
                    fontSize: 30,
                    color: Colors.black,
                  ),
                  DateFormat('yyyy년 MM월 dd일').format(_selectedDay))),
        ),
        Container(
          margin: EdgeInsets.fromLTRB(10, 10, 10, 10),
          width: double.infinity,
          height: 100,
          child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                  side: BorderSide(color: Colors.black),
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10))),
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
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                      width: 30,
                                      child: TextField(
                                          controller: _inputHour, maxLength: 2)),
                                  Text('시'),
                                  SizedBox(
                                      width: 30,
                                      child: TextField(
                                          controller: _inputMinute,
                                          maxLength: 2)),
                                  Text('분'),
                                ],
                              ),
                              OutlinedButton(
                                  onPressed: () {
                                    setState(() {
                                      _selectedDay = DateTime(
                                          _selectedDay.year,
                                          _selectedDay.month,
                                          _selectedDay.day,
                                          int.parse(_inputHour.text),
                                          int.parse(_inputMinute.text));
                                    });
                                    Navigator.pop(context);
                                  },
                                  child: Text('확인'))
                            ],
                          ));
                    });
              },
              child: Text(
                  style: TextStyle(
                    fontSize: 30,
                    color: Colors.black,
                  ),
                  DateFormat('HH시 mm분').format(_selectedDay))),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              onPressed: () async {
                var url = Uri.http('localhost:8080', '/memos');
                var response = await http.post(
                  url,
                  headers: <String, String>{
                    'Content-Type': 'application/json; charset=UTF-8',
                  },
                  body: jsonEncode(AddUpdateMemo(memo: _inputData.text, dTime: _selectedDay).toJson()),
                );
                if (response.statusCode == 200) {
                  setState(() {
                    _errors.clear();
                    _memoErr = null;
                  });
                  widget.getMemoList();
                  widget.setWidgetIndex(0);
                } else if (response.statusCode == 400) {
                  var validationResult =
                      ValidationResult.fromJson(jsonDecode(response.body));
                    _errors = validationResult.errors;
                    setState(() {
                      memoErrValidate(_errors);
                    });
                }
              },
              child: Text('추가'),
            ),
            TextButton(
              onPressed: () {
                widget.setWidgetIndex(0);
              },
              child: Text('취소'),
            ),
          ],
        )
      ],
    );
  }

  void memoErrValidate(List<FieldErrorDetail> errors) {
    if (errors.any((error) => error.field == "memo")) {
      _memoErr = errors.firstWhere((error) => error.field == "memo").message;
    } else {
      _memoErr = null;
    }
  }
}
