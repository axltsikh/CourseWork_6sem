import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:course_application/DatabaseHandler.dart';

import 'package:course_application/MainPage.dart';
import 'package:course_application/Utility.dart';
import 'package:course_application/manyUsageTemplate/CupertinoButtonTemplate.dart';
import 'package:course_application/registerPage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;

import 'Models/User.dart';

void main() async{
  print(Utility.asd);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
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
  void loginClick() async{
    await login();
  }
  Future<void> login() async{
    final connectivityResult = await (Connectivity().checkConnectivity());
    if(connectivityResult == ConnectivityResult.none){
      print("Local db question");
      List<User> users = await Utility.databaseHandler.getUser(loginFieldController.text);
      if(users.length!=0){
        if(users[0].Password == passwordFieldController.text){
          Utility.user.id=users[0].id;
          Utility.user.Username=loginFieldController.text;
          Utility.user.Password=passwordFieldController.text;
          Navigator.push(context, MaterialPageRoute(builder: (context)=>MainPage()));
        }else{
          Fluttertoast.showToast(msg: "Неверное имя пользователя или пароль!",toastLength: Toast.LENGTH_SHORT,);
        }
      }
    }else{
      final String url = "http://10.0.2.2:5000/user/login";
      final response = await http.post(Uri.parse(url),headers: <String,String>{
        'Content-Type': 'application/json;charset=UTF-8',
      },body: jsonEncode(<String,String>{
        'name': loginFieldController.text,
        'password': passwordFieldController.text
      }));
      if(response.statusCode==200){
        Utility.user.id=int.parse(response.body);
        Utility.user.Username=loginFieldController.text;
        Utility.user.Password=passwordFieldController.text;
        Navigator.push(context, MaterialPageRoute(builder: (context)=>MainPage()));
        await Utility.databaseHandler.GetAllData();
      }else{
        Fluttertoast.showToast(msg: "Неверное имя пользователя или пароль!",toastLength: Toast.LENGTH_SHORT,);
      }
    }
  }
  void registerClick(){
    Navigator.push(context, MaterialPageRoute(builder: (context)=>RegisterPage()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
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
                  child: CupertinoButtonTemplate(
                    "Войти",
                    loginClick
                  )
                ),
                Container(
                    margin: const EdgeInsets.only(top: 15),
                    child: CupertinoButtonTemplate(
                      "Создать аккаунт",
                      registerClick
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
