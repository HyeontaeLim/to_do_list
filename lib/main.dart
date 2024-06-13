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
  runApp(MaterialApp(home: MyApp()));
}

class MyApp extends StatefulWidget {
  MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int _pageIndex = 0;
  final PageController _pageController = PageController(initialPage: 0);

  setPageIndex(int value) {
    setState(() {
      _pageIndex = value;
    });
    _pageController.animateToPage(value, duration: Duration(milliseconds: 400), curve: Curves.ease);
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> widgets = [
      LoginPage(setPageIndex: (_pageIndex) => setPageIndex(_pageIndex)),
      MainPage(),
      RegisterPage(setPageIndex: (_pageIndex) => setPageIndex(_pageIndex))
    ];

    return PageView(
      controller: _pageController,
      scrollDirection: Axis.vertical,
      physics: NeverScrollableScrollPhysics(),
      children: widgets,);
  }
}
