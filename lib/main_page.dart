import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'addMemoForm.dart';
import 'correctMemoForm.dart';
import 'to_do_list_page.dart';
import 'memo.dart';

class MainPage extends StatefulWidget {
  MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final List<Memo> _list = [];
  String? _orderType = "dTimeDsc";
  int _widgetIndex = 0;
  int _memoIndex = 0;
  final PageController _pageController = PageController(
    initialPage: 0,
  );

  setWidgetIndex(int value) {
    setState(() {
      _widgetIndex = value;
    });
    _pageController.animateToPage(value,
        duration: Duration(milliseconds: 400), curve: Curves.ease);
  }

  setIndex(int value, int memoIndex) {
    setState(() {
      _widgetIndex = value;
      _memoIndex = memoIndex;
    });
    _pageController.animateToPage(value,
        duration: Duration(milliseconds: 400), curve: Curves.ease);
  }

  @override
  void initState() {
    super.initState();
    getMemoList();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> widgets = [
      ToDoListPage(
          list: _list,
          getMemoList: getMemoList,
          setWidgetIndex: (widgetIndex) => setWidgetIndex(widgetIndex),
          setIndex: (widgetIndex, memoIndex) =>
              setIndex(widgetIndex, memoIndex)),
      AddMemoForm(
          list: _list,
          getMemoList: getMemoList,
          setWidgetIndex: (index) => setWidgetIndex(index)),
      CorrectMemoForm(
          list: _list,
          getMemoList: getMemoList,
          setWidgetIndex: (index) => setWidgetIndex(index),
          memoIndex: _memoIndex)
    ];

    return Scaffold(
      resizeToAvoidBottomInset: false,
      floatingActionButton: _widgetIndex == 0
          ? FloatingActionButton(
              child: Icon(Icons.add),
              onPressed: () {
                setWidgetIndex(1);
              })
          : null,
      appBar: AppBar(
          leading: _widgetIndex != 0
              ? IconButton(
                  onPressed: () {
                    setWidgetIndex(0);
                  },
                  icon: Icon(Icons.arrow_back_ios_rounded),
                )
              : IconButton(
                  onPressed: () {
                    showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                              content: Text('로그아웃 하시겠습니까?'),
                              actions: [
                                TextButton(
                                    onPressed: () async{
                                      Navigator.pop(context);
                                      Navigator.pushReplacementNamed(context, '/login');
                                      var store = await SharedPreferences.getInstance();
                                      String? jSessionId = store.getString('JSESSIONID');
                                      var url = Uri.http('ec2-43-203-230-110.ap-northeast-2.compute.amazonaws.com:8080',
                                          '/logout');
                                      await http.post(url,
                                          headers: {'Cookie': 'JSESSIONID=$jSessionId'});
                                      store.remove('JSESSIONID');
                                    },
                                    child: Text(
                                      "예",
                                      textAlign: TextAlign.right,
                                    )),
                                TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: Text(
                                      "아니오",
                                      textAlign: TextAlign.right,
                                    ))
                              ]);
                        });
                  },
                  icon: Icon(Icons.logout),
                ),
          title: Text('To-do list',
              style: TextStyle(
                  fontWeight: FontWeight.bold, fontStyle: FontStyle.italic)),
          actions: _widgetIndex == 0
              ? [
                  DropdownButtonHideUnderline(
                      child: DropdownButton(
                    icon: Icon(Icons.sort),
                    iconSize: 35,
                    items: const [
                      DropdownMenuItem(
                          value: 'createdDsc',
                          child: SizedBox(child: Text('오래된 순'))),
                      DropdownMenuItem(
                          value: 'createdAsc',
                          child: SizedBox(child: Text('최신순'))),
                      DropdownMenuItem(
                          value: 'dTimeDsc',
                          child: SizedBox(child: Text('가까운 목표 순'))),
                      DropdownMenuItem(
                          value: 'dTimeAsc',
                          child: SizedBox(child: Text('먼 목표 순'))),
                    ],
                    onChanged: (newValue) {
                      _orderType = newValue!;
                      if(_orderType == 'createdDsc') {
                        setState(() {
                          _list.sort((a,b) => a.created.compareTo(b.created));
                        });
                      } else if(_orderType == 'createdAsc') {
                        setState(() {
                          _list.sort((a,b) => b.created.compareTo(a.created));
                        });
                      }else if(_orderType == 'dTimeDsc') {
                        setState(() {
                          _list.sort((a,b) => a.dTime.compareTo(b.dTime));
                        });
                      }else if(_orderType == 'dTimeAsc') {
                        setState(() {
                          _list.sort((a,b) => b.dTime.compareTo(a.dTime));
                        });
                      }
                    },
                  ))
                ]
              : null,
          backgroundColor: Color(0xBCDDF1FF)),
      body: PageView(
        controller: _pageController,
        scrollDirection: Axis.vertical,
        physics: NeverScrollableScrollPhysics(),
        children: widgets,
      ),
    );
  }

  getMemoList() async {
    var store = await SharedPreferences.getInstance();
    String? jSessionId = store.getString('JSESSIONID');
    var response = await http.get(
        Uri.http('ec2-43-203-230-110.ap-northeast-2.compute.amazonaws.com:8080', '/memos'),
        headers: {'Cookie': 'JSESSIONID=$jSessionId'});
    if (response.statusCode == HttpStatus.ok) {
        var parsedBody = jsonDecode(response.body);
        _list.clear();
        for (var memo in parsedBody) {
          _list.add(Memo.fromJson(memo));
        }
        print(parsedBody);
    } else if (response.statusCode == HttpStatus.unauthorized) {
      await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(content: Text('로그인이 만료 되었습니다.'), actions: [
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

    if(_orderType == 'createdDsc') {
      setState(() {
        _list.sort((a,b) => a.created.compareTo(b.created));
      });
    } else if(_orderType == 'createdAsc') {
      setState(() {
        _list.sort((a,b) => b.created.compareTo(a.created));
      });
    }else if(_orderType == 'dTimeDsc') {
      setState(() {
        _list.sort((a,b) => a.dTime.compareTo(b.dTime));
      });
    }else if(_orderType == 'dTimeAsc') {
      setState(() {
        _list.sort((a,b) => b.dTime.compareTo(a.dTime));
      });
    }

  }
}
