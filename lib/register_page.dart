import 'dart:convert';
import 'dart:ffi';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:to_do_list_project/ValidationResult.dart';
import 'package:to_do_list_project/member.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  TextEditingController _name = TextEditingController();
  TextEditingController _username = TextEditingController();
  TextEditingController _password = TextEditingController();
  TextEditingController _passwordConfirmation = TextEditingController();
  TextEditingController _email = TextEditingController();
  List<FieldErrorDetail> _errors = [];
  Gender? _gender;
  String? _nameErr;
  String? _usernameErr;
  String? _passwordErr;
  String? _passwordConfirmationErr;
  String? _genderErr;
  String? _emailErr;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height,
          ),
          child: Column(
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
                errorText: _nameErr,
                labelText: '이름',
                hintText: '이름을 입력해주세요.',
              ),
              RegisterInputBox(
                controller: _username,
                errorText: _usernameErr,
                labelText: '아이디',
                hintText: '영문, 숫자 포함 5~20자',
              ),
              RegisterInputBox(
                controller: _password,
                errorText: _passwordErr,
                obscureText: true,
                labelText: '비밀번호',
                hintText: '영문, 숫자, 특수기호 포함 8~16자',
              ),
              RegisterInputBox(
                controller: _passwordConfirmation,
                errorText: _passwordConfirmationErr,
                obscureText: true,
                labelText: '비밀번호 확인',
                hintText: '비밀번호 확인',
              ),
              RegisterInputBox(
                controller: _email,
                errorText: _emailErr,
                labelText: '이메일',
                hintText: '이메일을 입력해주세요.',
              ),
              Container(
                margin: EdgeInsets.fromLTRB(30, 0, 30, 8),
                decoration: BoxDecoration(
                    border: Border.all(
                        color: _genderErr == null
                            ? Colors.black54
                            : Color(0xffC65B56),
                        width: 1),
                    borderRadius: BorderRadius.circular(10)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(8, 0, 25, 0),
                      child: Text('성별',
                          style: TextStyle(
                              color: _genderErr == null
                                  ? Colors.black54
                                  : Color(0xffC65B56),
                              fontSize: 17)),
                    ),
                    Expanded(
                      child: ListTile(
                        title: const Text('남성'),
                        leading: Radio<Gender>(
                          value: Gender.MALE,
                          groupValue: _gender,
                          onChanged: (Gender? value) {
                            setState(() {
                              _gender = value;
                              _genderErr = null;
                            });
                          },
                        ),
                      ),
                    ),
                    Expanded(
                      child: ListTile(
                        title: const Text('여성'),
                        leading: Radio<Gender>(
                          value: Gender.FEMALE,
                          groupValue: _gender,
                          onChanged: (Gender? value) {
                            setState(() {
                              _gender = value;
                              _genderErr = null;
                            });
                          },
                        ),
                      ),
                    )
                  ],
                ),
              ),
              if (_genderErr != null)
                Align(
                    alignment: Alignment.topLeft,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(40, 0, 0, 10),
                      child: Text(
                        _genderErr!,
                        style:
                            TextStyle(fontSize: 12, color: Color(0xffC65B56)),
                      ),
                    )),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  OutlinedButton(
                      onPressed: () async {
                        var uri = Uri.http('ec2-3-107-48-252.ap-southeast-2.compute.amazonaws.com:8080', '/members');
                        var response = await http.post(uri,
                            headers: <String, String>{
                              'Content-Type': 'application/json; charset=UTF-8',
                            },
                            body: jsonEncode(AddUpdateMember(
                                    username: _username.text,
                                    password: _password.text,
                                    passwordConfirmation:
                                        _passwordConfirmation.text,
                                    name: _name.text,
                                    gender: _gender,
                                    email: _email.text)
                                .toJson()));
                        if (response.statusCode == HttpStatus.ok) {
                          setState(() {
                            _errors.clear();
                            _nameErr = null;
                            _usernameErr = null;
                            _passwordErr = null;
                            _emailErr = null;
                            _passwordConfirmationErr = null;
                          });
                          Navigator.pushNamed(context, '/login');
                        } else if (response.statusCode == HttpStatus.badRequest) {
                          var validationResult = ValidationResult.fromJson(
                              jsonDecode(response.body));
                          setState(() {
                            _errors = validationResult.fieldErrors;
                            _nameErr =
                                FieldErrorDetail.errValidate(_errors, "name");
                            _usernameErr = FieldErrorDetail.errValidate(
                                _errors, "username");
                            _passwordErr = FieldErrorDetail.errValidate(
                                _errors, "password");
                            _passwordConfirmationErr =
                                FieldErrorDetail.errValidate(
                                    _errors, "passwordConfirmation");
                            _emailErr =
                                FieldErrorDetail.errValidate(_errors, "email");
                            _genderErr =
                                FieldErrorDetail.errValidate(_errors, "gender");
                          });
                        }
                      },
                      child: Text("회원가입")),
                  OutlinedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/login');
                      },
                      child: Text("뒤로가기"))
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}

class RegisterInputBox extends StatelessWidget {
  const RegisterInputBox(
      {super.key,
      required this.controller,
      this.errorText,
      required this.labelText,
      required this.hintText,
      this.obscureText = false});

  final TextEditingController controller;
  final String? errorText;
  final String labelText;
  final String hintText;
  final bool obscureText;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.fromLTRB(30, 0, 30, 10),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        decoration: InputDecoration(
            errorMaxLines: 3,
            labelText: labelText,
            errorText: errorText,
            hintText: hintText,
            border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
      ),
    );
  }
}
