import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'memo.dart';

class Provider extends ChangeNotifier{
  List<Memo> list = [];

}
