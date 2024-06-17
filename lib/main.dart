import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:to_do_list_project/addMemoForm.dart';
import 'package:to_do_list_project/correctMemoForm.dart';
import 'package:to_do_list_project/loginPage.dart';
import 'package:to_do_list_project/main_page.dart';
import 'package:to_do_list_project/register_page.dart';
import 'package:to_do_list_project/to_do_list_page.dart';
import 'dart:convert';

import 'memo.dart';

void main() {
  runApp(GestureDetector(
    onTap: () {
      FocusManager.instance.primaryFocus?.unfocus();
    },
    child: MaterialApp(
      initialRoute: "/login",
      routes: {
        "/login": (c) => LoginPage(),
        "/main": (c) => MainPage(),
        "/register": (c) => RegisterPage()
      },
    ),
  )); //home: MyApp()));
}
