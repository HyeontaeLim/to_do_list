import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:to_do_list_project/ValidationResult.dart';
import 'package:to_do_list_project/member.dart';

class RegisterPage extends StatefulWidget {
  final Function(int) setPageIndex;

  const RegisterPage({required this.setPageIndex, super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  TextEditingController _name = TextEditingController();
  TextEditingController _username = TextEditingController();
  TextEditingController _password = TextEditingController();
  TextEditingController _passwordCheck = TextEditingController();
  TextEditingController _email = TextEditingController();
  List<FieldErrorDetail> _errors = [];
  Gender? _gender;
  String? _nameErr;
  String? _usernameErr;
  String? _passwordErr;
  String? _passwordCheckErr;
  String? _emailErr;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 40),
            child: Text(
              '회원가입',
              style: TextStyle(
                fontSize: 40,
              ),
            ),
          ),
          RegisterInputBox(
            controller: _name,
            labelText: '이름',
            hintText: '이름을 입력해주세요.',
          ),
          RegisterInputBox(
            controller: _username,
            labelText: '아이디',
            hintText: '사용할 아이디를 입력해주세요,',
          ),
          RegisterInputBox(
            controller: _password,
            labelText: '비밀번호',
            hintText: '사용 할 비밀번호를 입력해주세요.',
          ),
          RegisterInputBox(
            controller: _passwordCheck,
            labelText: '비밀번호 확인',
            hintText: '비밀번호 확인',
          ),
          RegisterInputBox(
            controller: _email,
            labelText: '이메일',
            hintText: '이메일을 입력해주세요.',
          ),
          Container(margin: EdgeInsets.fromLTRB(30, 0, 30, 10),
            decoration: BoxDecoration(border: Border.all(color: Colors.black54, width: 1), borderRadius: BorderRadius.circular(10)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
               Container(
                 padding: const EdgeInsets.fromLTRB(8, 0, 30, 0),
                 child: Text('성별', style: TextStyle(fontSize: 16)),
               ),
                Expanded(
                  child: ListTile(
                    title: const Text('MALE'),
                    leading: Radio<Gender>(value: Gender.MALE,
                      groupValue: _gender,
                      onChanged: (Gender? value) {
                        setState(() {
                          _gender = value;
                        });
                      },
                    ),
                  ),
                ),
                Expanded(
                  child: ListTile(
                    title: const Text('FEMALE'),
                    leading: Radio<Gender>(value: Gender.FEMALE,
                      groupValue: _gender,
                      onChanged: (Gender? value) {
                        setState(() {
                          _gender = value;
                        });
                      },
                  
                    ),
                  ),
                )
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              OutlinedButton(
                  onPressed: () async {
                    var uri = Uri.http('localhost:8080', '/members');
                    var response = await http.post(uri,
                        headers: <String, String>{
                          'Content-Type': 'application/json; charset=UTF-8',
                        },
                        body: jsonEncode(AddUpdateMember(
                            username: _username.text,
                            password: _password.text,
                            name: _name.text,
                            gender: _gender,
                            email: _email.text)
                            .toJson()));
                    if (response.statusCode == 200) {
                      setState(() {
                        _errors.clear();
                        _nameErr = null;
                        _usernameErr = null;
                        _passwordErr = null;
                        _passwordCheckErr = null;
                        _emailErr = null;
                      });
                      widget.setPageIndex(0);
                    }
                  },
                  child: Text("회원가입")),
              OutlinedButton(
                  onPressed: () {
                    widget.setPageIndex(0);
                  },
                  child: Text("뒤로가기"))
            ],
          )
        ],
      ),
    );
  }
}

class RegisterInputBox extends StatelessWidget {
  const RegisterInputBox({super.key,
    required TextEditingController controller,
    required String labelText,
    required String hintText})
      : _controller = controller,
        _labelText = labelText,
        _hintText = hintText;

  final TextEditingController _controller;
  final String _labelText;
  final String _hintText;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.fromLTRB(30, 0, 30, 10),
      child: TextField(
        controller: _controller,
        decoration: InputDecoration(
            labelText: _labelText,
            hintText: _hintText,
            border:
            OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
      ),
    );
  }
}
