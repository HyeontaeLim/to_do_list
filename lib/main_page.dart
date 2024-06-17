import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'addMemoForm.dart';
import 'correctMemoForm.dart';
import 'to_do_list_page.dart';
import 'memo.dart';

class MainPage extends StatefulWidget {

  MainPage({
  super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final List<Memo> _list = [];
  String? _orderType = "dTimeDsc";
  int _widgetIndex = 0;
  int _memoIndex = 0;
  final PageController _pageController = PageController(initialPage: 0, );

  setWidgetIndex(int value) {
    setState(() {
      _widgetIndex = value;
    });
    _pageController.animateToPage(value, duration: Duration(milliseconds: 400), curve: Curves.ease);
  }

  setIndex(int value, int memoIndex) {
    setState(() {
      _widgetIndex = value;
      _memoIndex = memoIndex;
    });
    _pageController.animateToPage(value, duration: Duration(milliseconds: 400), curve: Curves.ease);
  }

  @override
  void initState() {
    super.initState();
    getMemoList();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> widgets = [
      ToDoListPage(list: _list, getMemoList: getMemoList,setWidgetIndex: (widgetIndex) => setWidgetIndex(widgetIndex), setIndex: (widgetIndex, memoIndex) => setIndex(widgetIndex, memoIndex)),
      AddMemoForm(list: _list, getMemoList: getMemoList, setWidgetIndex: (index) => setWidgetIndex(index)),
      CorrectMemoForm(list: _list, getMemoList: getMemoList, setWidgetIndex: (index) => setWidgetIndex(index), memoIndex: _memoIndex)
    ];

    return Scaffold(
      floatingActionButton: _widgetIndex==0 ? FloatingActionButton(child: Icon(Icons.add), onPressed: (){setWidgetIndex(1);}):null,
      appBar: AppBar(leading: _widgetIndex!=0 ? IconButton(onPressed: (){setWidgetIndex(0);},icon: Icon(Icons.arrow_back_ios_rounded),) :null, title: Text('To-do list', style: TextStyle(
          fontWeight: FontWeight.bold, fontStyle: FontStyle.italic)),
          actions: _widgetIndex==0 ? [DropdownButtonHideUnderline(child: DropdownButton(value: _orderType, icon: Icon(Icons.sort), iconSize: 35, items: const[
            DropdownMenuItem(
                value: 'createdDsc',
                child: Text('오래된 순')
            ),
            DropdownMenuItem(
                value: 'createdAsc',
                child: Text('최신순')
            ),
            DropdownMenuItem(
                value: 'dTimeDsc',
                child: Text('가까운 목표 순')
            ),
            DropdownMenuItem(
                value: 'dTimeAsc',
                child: Text('먼 목표 순')
            ),
          ], onChanged: (newValue) {
            _orderType = newValue!;
            getMemoList();
          },)) ] : null,
          backgroundColor: Color(0xBCDDF1FF)),
      body: PageView(
        controller: _pageController,
        scrollDirection: Axis.vertical,
        physics: NeverScrollableScrollPhysics(),
        children: widgets, ),
    );
  }

  getMemoList() async {
    var store = await SharedPreferences.getInstance();
    String? jSessionId = store.getString('JSESSIONID');
    var response = await http.get(Uri.http('10.0.2.2:8080', '/memos', {'orderType': _orderType}),
    headers: {
      'Cookie': 'JSESSIONID=$jSessionId'
    });
    if(response.statusCode == 200) {
      setState(() {
        var parsedBody = jsonDecode(response.body);
        _list.clear();
        for (var memo in parsedBody) {
          _list.add(Memo.fromJson(memo));
        }
        print(parsedBody);
      });
    } else if (response.statusCode == 401) {
      await showDialog(context: context, builder: (BuildContext context) {
        return AlertDialog(content: Text('로그인이 만료 되었습니다.'),
            actions: [TextButton(onPressed: () {Navigator.pop(context);}, child: Text("확인", textAlign: TextAlign.right,))]
        );
      }).then((value){Navigator.pop(context);});
    }
  }
}