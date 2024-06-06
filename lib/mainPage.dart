import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

import 'memo.dart';

class mainPage extends StatefulWidget {

  final List<Memo> list;
  final Function getMemoList;
  final Function(int) setWidgetIndex;
  final Function(int, int) setIndex;


  const mainPage({
    required this.list,
    required this.getMemoList,
    required this.setWidgetIndex,
    required this.setIndex,
    super.key});

  @override
  State<mainPage> createState() => _mainPageState();
}

class _mainPageState extends State<mainPage> {

  @override
  Widget build(BuildContext context) {
      return ListView.builder(itemCount: widget.list.length, itemBuilder: (c, i) {
        return Dismissible(
            key: Key("${widget.list[i].id}"),
            direction: DismissDirection.endToStart, // 오른쪽에서 왼쪽으로 스와이프
            onDismissed: (direction)
            async{
              var url = Uri.http('10.0.2.2:8080', '/memos/${widget.list[i].id}');
              await http.delete(url);
              widget.getMemoList();
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
                  children: [ListTile(title: Text(widget.list[i].memo)),
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
            ));
      
      });
  }
}
