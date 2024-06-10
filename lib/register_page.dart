import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class RegisterPage extends StatefulWidget {
  final Function(int) setPageIndex;

  const RegisterPage(
      {required this.setPageIndex,
        super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  TextEditingController _name = TextEditingController();
  TextEditingController _id = TextEditingController();
  TextEditingController _password = TextEditingController();
  TextEditingController _passwordCheck = TextEditingController();
  TextEditingController _email = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 40),
            child: Text('회원가입', style: TextStyle(fontSize: 40,),),
          ),
          Container(
            margin: EdgeInsets.fromLTRB(30, 0, 30, 10),
            child: TextField(
              controller: _name,
              decoration: InputDecoration(
                  labelText: '이름',
                  hintText: "이름를 입력해주세요.",
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10))),
            ),
          ),
          Container(
            margin: EdgeInsets.fromLTRB(30, 0, 30, 10),
            child: TextField(
              controller: _id,
              decoration: InputDecoration(
                  labelText: '아이디',
                  hintText: "사용 할 아이디를 입력해주세요.",
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10))),
            ),
          ),
          Container(
            margin: EdgeInsets.fromLTRB(30, 0, 30, 10),
            child: TextField(
              controller: _password,
              decoration: InputDecoration(
                  labelText: '비밀번호',
                  hintText: "사용 할 비밀번호를 입력해주세요",
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10))),
            ),
          ),
          Container(
            margin: EdgeInsets.fromLTRB(30, 0, 30, 10),
            child: TextField(
              decoration: InputDecoration(
                  labelText: '비밀번호 확인',
                  hintText: "비밀번호 확인",
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10))),
            ),
          ),
          Container(
            margin: EdgeInsets.fromLTRB(30, 0, 30, 10),
            child: TextField(
              controller: _email,
              decoration: InputDecoration(
                  labelText: '이메일.',
                  hintText: "이메알을 입력해주세요",
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10))),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              OutlinedButton(onPressed: (){widget.setPageIndex(0);}, child: Text("회원가입")),
              OutlinedButton(onPressed: (){widget.setPageIndex(0);}, child: Text("뒤로가기"))
            ],
          )
        ],
      ),
    );
  }
}
