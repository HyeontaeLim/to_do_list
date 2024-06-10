import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';


class LoginPage extends StatefulWidget {
  final Function(int) setPageIndex;

  const LoginPage({
    required this.setPageIndex,
    super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController idInput = TextEditingController();
  TextEditingController passwordInput = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column( mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(margin: EdgeInsets.fromLTRB(30, 10, 30, 10),
            child: TextField(
              controller: idInput,
              decoration: InputDecoration(
                  hintText: "아이디",
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10))),
            ),
          ),
          Container(
            margin: EdgeInsets.fromLTRB(30, 10, 30, 10),
            child: TextField(
              controller: passwordInput,
              decoration: InputDecoration(
                  hintText: "비밀번호",
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10))),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              OutlinedButton(onPressed: (){widget.setPageIndex(1);}, child: Text("로그인")),
              OutlinedButton(onPressed: (){widget.setPageIndex(2);}, child: Text("회원가입"))
            ],
          )
        ],
      ),
    );
  }
}
