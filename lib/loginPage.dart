import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:to_do_list_project/login_form.dart';

import 'ValidationResult.dart';

class LoginPage extends StatefulWidget {

  const LoginPage(
      {super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController usernameInput = TextEditingController();
  TextEditingController passwordInput = TextEditingController();
  List<FieldErrorDetail> _fieldErrors = [];
  List<ObjectErrorDetail> _globalErrors = [];
  String? _usernameErr;
  String? _passwordErr;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            margin: EdgeInsets.fromLTRB(30, 10, 30, 10),
            child: TextField(
              controller: usernameInput,
              decoration: InputDecoration(
                  errorText: _usernameErr,
                  hintText: "아이디",
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10))),
            ),
          ),
          Container(
            margin: EdgeInsets.fromLTRB(30, 10, 30, 10),
            child: TextField(
              controller: passwordInput,
              obscureText: true,
              decoration: InputDecoration(
                  errorText: _passwordErr,
                  hintText: "비밀번호",
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10))),
            ),
          ),
          if (_globalErrors.isNotEmpty && _fieldErrors.isEmpty)
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(42, 0, 0, 10),
                child: Text(
                  _globalErrors[0].message,
                  style: TextStyle(fontSize: 12, color: Color(0xffC65B56)),
                ),
              ),
            ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              OutlinedButton(
                  onPressed: () async {
                    var uri = Uri.http('10.0.2.2:8080', '/login');
                    var response = await http.post(uri,
                        headers: <String, String>{
                          'Content-Type': 'application/json; charset=UTF-8',
                        },
                        body: jsonEncode(LoginForm(
                                username: usernameInput.text,
                                password: passwordInput.text)
                            .toJson()));
                    if (response.statusCode == 200) {
                      _fieldErrors.clear();
                      setState(() {
                        _usernameErr = null;
                        _passwordErr = null;
                      });
                      String? setCookie = response.headers['set-cookie'];
                      if(setCookie != null) {
                        print(setCookie);
                        List<String> cookies = setCookie.split(';');
                        for (String cookie in cookies) {
                          if(cookie.trim().startsWith('JSESSIONID=')) {
                            final store = await SharedPreferences.getInstance();
                            await store.setString('JSESSIONID', cookie.split('=')[1]);
                            print(store.getString('JSESSIONID'));
                            break;
                          }
                        }
                      }

                     Navigator.pushNamed(context, '/main');
                    } else if (response.statusCode == 400) {
                      _fieldErrors =
                          ValidationResult.fromJson(jsonDecode(response.body))
                              .fieldErrors;
                      _globalErrors =
                          ValidationResult.fromJson(jsonDecode(response.body))
                              .globalErrors;
                      setState(() {
                        _usernameErr = FieldErrorDetail.errValidate(
                            _fieldErrors, "username");
                        _passwordErr = FieldErrorDetail.errValidate(
                            _fieldErrors, "password");
                      });
                    }
                  },
                  child: Text("로그인")),
              OutlinedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/register');
                  },
                  child: Text("회원가입"))
            ],
          )
        ],
      ),
    );
  }
}

