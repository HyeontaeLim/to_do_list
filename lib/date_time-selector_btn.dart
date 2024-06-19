import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateTimeSelectorBtn extends StatefulWidget {
  final VoidCallback dialog;
  final String text;

  const DateTimeSelectorBtn({
    required this.dialog,
    required this.text,
    super.key});

  @override
  State<DateTimeSelectorBtn> createState() => _DateTimeSelectorBtnState();
}

class _DateTimeSelectorBtnState extends State<DateTimeSelectorBtn> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.fromLTRB(10, 10, 10, 10),
      width: double.infinity,
      height: 100,
      child: ElevatedButton(
          style: ElevatedButton.styleFrom(
              side: BorderSide(color: Colors.black),
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10))),
          onPressed: widget.dialog,
          child: Text(
              style: TextStyle(
                fontSize: 30,
                color: Colors.black,
              ),
              widget.text)),
    );
  }
}
