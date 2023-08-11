import 'dart:convert';
import 'dart:html';

import 'package:crypto/crypto.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:oktoast/oktoast.dart';
import 'Pages/MainPage.dart';
import 'Utility.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return OKToast(child: MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(

        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Trello'),
    ));
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final loginFieldController = TextEditingController();
  final passwordFieldController = TextEditingController();
  Future<void> login() async{
    final response = await http.post(Uri.http('127.0.0.1:5000','/user/login'),headers: <String,String>{
      "Access-Control-Allow-Origin": "*",
      'Content-Type': 'application/json;charset=UTF-8',
    },body: jsonEncode(<String,String>{
      'name': loginFieldController.text,
      'password': md5.convert(utf8.encode(passwordFieldController.text)).toString()
    }));
    if(response.statusCode==200){
      Utility.user.id=int.parse(response.body);
      Utility.user.Username=loginFieldController.text;
      Utility.user.Password=md5.convert(utf8.encode(passwordFieldController.text)).toString();
      Navigator.push(context, MaterialPageRoute(builder: (context)=>MainPage()));
    }else{
      print("wrong something");
      showToast("Неверное имя пользователя или пароль!",position: ToastPosition.bottom,);
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text("Вход"),),
        body: Center(
            child: Align(
                alignment: Alignment.center,
                child: Container(
                  width: 250,
                  margin: const EdgeInsets.only(top: 150),
                  child: Column(
                    children: [
                      Container(
                          margin: const EdgeInsets.only(top: 25),
                          child: CupertinoTextField(
                            placeholder: "Имя пользователя",
                            controller: loginFieldController,
                            clearButtonMode: OverlayVisibilityMode.always,
                          )
                      ),
                      Container(
                          margin: const EdgeInsets.only(top: 15),
                          child: CupertinoTextField(
                            placeholder: "Пароль",
                            obscureText: true,
                            controller: passwordFieldController,
                            clearButtonMode: OverlayVisibilityMode.always,
                          )
                      ),
                      Container(
                          margin: const EdgeInsets.only(top: 15),
                          child: CupertinoButton.filled(
                              child: Text("Войти"),
                              onPressed: login,
                              borderRadius: BorderRadius.circular(50),
                          )
                      ),
                    ],
                  ),
                )
            )
        )
    );
  }
}
