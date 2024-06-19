import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:to_do_list_project/ValidationResult.dart';
import 'package:to_do_list_project/date_time-selector_btn.dart';

import 'memo.dart';

class MemoForm extends StatefulWidget {
  final List<Memo> list;
  final void Function() getMemoList;
  final void Function(int) setWidgetIndex;
  final Future<Response> Function(String?, String, DateTime) httpRequest;
  final DateTime initSelectedDay;
  final TimeOfDay initSelectedTime;
  final TextEditingController initInputData;
  final String confirmText;

  const MemoForm(
      {required this.list,
      required this.getMemoList,
      required this.setWidgetIndex,
      required this.httpRequest,
      required this.initSelectedDay,
      required this.initSelectedTime,
      required this.initInputData,
      required this.confirmText,
      super.key});

  @override
  State<MemoForm> createState() => _MemoFormState();
}

class _MemoFormState extends State<MemoForm> {
  TextEditingController _inputData = TextEditingController();
  DateTime _selectedDay = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  final DateTime _today = DateTime.now();
  List<FieldErrorDetail> _errors = [];
  String? _memoErr;

  @override
  void initState() {
    _selectedDay = widget.initSelectedDay;
    _selectedTime = widget.initSelectedTime;
    _inputData = widget.initInputData;
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
        DateTimeSelectorBtn(
            dialog: showDateDialog,
            text: DateFormat("yyyy년 MM월 dd일").format(_selectedDay)),
        DateTimeSelectorBtn(
            dialog: showTimeDialog,
            text: DateFormat("HH시 mm분").format(_selectedDay)),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              onPressed: () {
                widget.setWidgetIndex(0);
              },
              child: Text('취소'),
            ),
            TextButton(
              onPressed: () async {
                var store = await SharedPreferences.getInstance();
                String? jSessionId = store.getString('JSESSIONID');
                var response = await widget.httpRequest(
                    jSessionId, _inputData.text, _selectedDay);
                if (response.statusCode == 200) {
                  setState(() {
                    _errors.clear();
                    _memoErr = null;
                    _inputData.clear();
                  });
                  widget.getMemoList();
                  widget.setWidgetIndex(0);
                } else if (response.statusCode == 400) {
                  _errors = ValidationResult.fromJson(jsonDecode(response.body))
                      .fieldErrors;
                  setState(() {
                    _memoErr = FieldErrorDetail.errValidate(_errors, "memo");
                  });
                } else if (response.statusCode == 401) {
                  await showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                            content: Text('로그인이 만료 되었습니다.'),
                            actions: [
                              TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: Text(
                                    "확인",
                                    textAlign: TextAlign.right,
                                  ))
                            ]);
                      }).then((value) {
                    Navigator.pushReplacementNamed(context, '/login');
                    store.remove('JSESSIONID');
                  });
                }
              },
              child: Text(widget.confirmText),
            ),
          ],
        )
      ],
    );
  }

  void showDateDialog() async {
    DateTime? selectedDate = await showDialog(
        context: context,
        builder: (BuildContext context) {
          DateTime selectedDate = _selectedDay;
          return StatefulBuilder(
            builder: (context, setState) {
                  return Center(
                    child: SingleChildScrollView(
                      child: Dialog(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: SizedBox(
                          height: 490,
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(12),
                                child: TableCalendar(
                                    focusedDay: selectedDate,
                                    firstDay: _today.subtract(Duration(days: 365)),
                                    lastDay: _today.add(Duration(days: 365 * 5)),
                                    selectedDayPredicate: (day) {
                                      return isSameDay(selectedDate, day);
                                    },
                                    onDaySelected:
                                        (DateTime selectedDay, DateTime focusedDay) {
                                      setState(() {
                                        selectedDate = DateTime(
                                            selectedDay.year,
                                            selectedDay.month,
                                            selectedDay.day,
                                            _selectedDay.hour,
                                            _selectedDay.minute);
                                      });
                                    }),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(right: 16),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: Text('취소')),
                                    TextButton(
                                        onPressed: () =>
                                            Navigator.of(context).pop(selectedDate),
                                        child: Text('확인')),
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }
              );
            },
          );
    if (selectedDate != null) {
      setState(() {
        _selectedDay = selectedDate;
      });
    }
  }

  void showTimeDialog() async {
    TimeOfDay? pickedTime = await showDialog(
        context: context,
        builder: (BuildContext context) {
          return TimePickerDialog(
            initialTime: _selectedTime,
            cancelText: '취소',
            confirmText: '확인',
            hourLabelText: '시간',
            minuteLabelText: '분',
            helpText: '시간',
          );
        });
    setState(() {
      if (pickedTime != null) {
        _selectedTime = pickedTime;
      }
      _selectedDay = DateTime(_selectedDay.year, _selectedDay.month,
          _selectedDay.day, _selectedTime.hour, _selectedTime.minute);
    });
  }
}
