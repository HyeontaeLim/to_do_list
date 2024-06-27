import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'memo.dart';

class ToDoListPage extends StatefulWidget {

  final List<Memo> list;
  final Function getMemoList;
  final Function(int) setWidgetIndex;
  final Function(int, int) setIndex;


  const ToDoListPage({
    required this.list,
    required this.getMemoList,
    required this.setWidgetIndex,
    required this.setIndex,
    super.key});

  @override
  State<ToDoListPage> createState() => _ToDoListPageState();
}

class _ToDoListPageState extends State<ToDoListPage> {

  @override
  Widget build(BuildContext context) {
      return widget.list.isEmpty ? Center(child: Text("등록된 할 일이 없습니다.")) : ListView.builder(itemCount: widget.list.length, itemBuilder: (c, i) {
        return Dismissible(
            key: Key("${widget.list[i].memoId}"),
            direction: DismissDirection.endToStart, // 오른쪽에서 왼쪽으로 스와이프
            onDismissed: (direction)
            async{
              var store = await SharedPreferences.getInstance();
              String? jSessionId = store.getString('JSESSIONID');
              var url = Uri.http('ec2-3-107-48-252.ap-southeast-2.compute.amazonaws.com:8080', '/memos/${widget.list[i].memoId}');
              var response = await http.delete(url, headers: {
                'Cookie': 'JSESSIONID=$jSessionId'
              });
              if(response.statusCode == 200) {
                widget.getMemoList();
              } else if (response.statusCode == 401) {
                await showDialog(context: context, builder: (BuildContext context) {
                  return AlertDialog(content: Text('로그인이 만료 되었습니다.'),
                      actions: [TextButton(onPressed: () {Navigator.pop(context);}, child: Text("확인", textAlign: TextAlign.right,))]
                  );
                }).then((value){Navigator.pop(context);});
              } else if(response.statusCode ==401) {
                await showDialog(context: context, builder: (BuildContext context) {
                  return AlertDialog(content: Text('로그인이 만료 되었습니다.'),
                      actions: [TextButton(onPressed: () {Navigator.pop(context);}, child: Text("확인", textAlign: TextAlign.right,))]
                  );
                }).then((value){Navigator.pushReplacementNamed(context,'/login');
                store.remove('JSESSIONID');});
              }
            },
            child: GestureDetector(
              onDoubleTap: () async{
                var store = await SharedPreferences.getInstance();
                String? jSessionId = store.getString('JSESSIONID');
                var url = Uri.http('ec2-3-107-48-252.ap-southeast-2.compute.amazonaws.com:8080',
                    '/memos/${widget.list[i].memoId}');
                var response = await http.put(
                  url,
                  headers: <String, String>{
                    'Content-Type': 'application/json; charset=UTF-8',
                    'Cookie': 'JSESSIONID=$jSessionId',
                  },
                  body: jsonEncode(AddUpdateMemo(
                      memo: widget.list[i].memo,
                      dTime: widget.list[i].dTime,
                      isCompleted: !widget.list[i].isCompleted)
                      .toJson()),
                );
                if (response.statusCode == 200) {
                  widget.getMemoList();
                }
                else if (response.statusCode == 401) {
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
              child: Container(
                margin: EdgeInsets.all(5),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.black),
                    boxShadow: [BoxShadow(
                        color: Colors.grey.withOpacity(0.3),
                        spreadRadius: 2,
                        blurRadius: 5
                        ,offset: Offset(3,3))]),
                child: Column(
                    children: [ListTile(title: Text(widget.list[i].memo, style: widget.list[i].isCompleted ? TextStyle(decoration: TextDecoration.lineThrough):null,)),
                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [Padding(
                          padding: const EdgeInsets.fromLTRB(20,0,0,0),
                          child: Text(style: TextStyle(fontSize: 13,color: Colors.grey),
                              "목표일: ${DateFormat('yyyy년 MM월 dd일 HH시 mm분').format(widget.list[i].dTime)}"),
                        ),
                          Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                            TextButton(onPressed: () {widget.setIndex(2, i);}
                            , child: Text('수정')),
                          ],),
                        ],
                      )
                      ,]
                ),
              ),
            ));
      });
  }
}
