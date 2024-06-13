import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

import 'ValidationResult.dart';
import 'memo.dart';

class CorrectMemoForm extends StatefulWidget {
  final List<Memo> list;
  final Function getMemoList;
  final Function(int) setWidgetIndex;
  final int memoIndex;

  const CorrectMemoForm(
      {required this.list,
      required this.getMemoList,
      required this.setWidgetIndex,
      required this.memoIndex,
      super.key});

  @override
  State<CorrectMemoForm> createState() => _CorrectMemoFormState();
}

class _CorrectMemoFormState extends State<CorrectMemoForm> {
  TextEditingController _inputData = TextEditingController();
  TextEditingController _inputHour = TextEditingController();
  TextEditingController _inputMinute = TextEditingController();
  DateTime _selectedDay = DateTime.now();
  final DateTime _today = DateTime.now();
  List<FieldErrorDetail> _errors = [];
  String? _memoErr;

  @override
  void initState() {
    // TODO: implement initState
    _selectedDay = widget.list[widget.memoIndex].dTime;
    _inputHour = TextEditingController(
        text: widget.list[widget.memoIndex].dTime.hour
            .toString()
            .padLeft(2, '0'));
    _inputMinute = TextEditingController(
        text: widget.list[widget.memoIndex].dTime.minute
            .toString()
            .padLeft(2, '0'));
    _inputData = TextEditingController(text: widget.list[widget.memoIndex].memo);
  }

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
                                    lastDay:
                                        _today.add(Duration(days: 365 * 5)),
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
                var url = Uri.http('localhost:8080',
                    '/memos/${widget.list[widget.memoIndex].memoId}');
                var response = await http.put(
                  url,
                  headers: <String, String>{
                    'Content-Type': 'application/json; charset=UTF-8',
                  },
                  body: jsonEncode(
                      AddUpdateMemo(memo: _inputData.text, dTime: DateTime(
                          _selectedDay.year,
                          _selectedDay.month,
                          _selectedDay.day,
                          int.parse(_inputHour.text),
                          int.parse(_inputMinute.text))).toJson()
                  ),
                );
                if (response.statusCode == 200) {
                  setState(() {
                    _errors.clear();
                  });
                  widget.getMemoList();
                  widget.setWidgetIndex(0);
                } else if (response.statusCode == 400) {
                  var validationResult =
                      ValidationResult.fromJson(jsonDecode(response.body));
                  _errors = validationResult.fieldErrors;
                  setState(() {
                    memoErrValidate(_errors);
                  });
                }
              },
              child: Text('수정'),
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
