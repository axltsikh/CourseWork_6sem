import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class RegisterPage extends StatefulWidget{
  @override
  State<StatefulWidget> createState() => _RegisterPage();
}
class _RegisterPage extends State<RegisterPage>{
  final loginFieldController = TextEditingController();
  final passwordFieldController = TextEditingController();
  final repeatPasswordFieldController = TextEditingController();
  String errorText = "";
  void registerClick() async {
    await createUser();
  }
  Future<void> createUser() async{
    const String url = "http://10.0.2.2:5000/user/create";
    final response = await http.post(Uri.parse(url),headers: <String,String>{
      'Content-Type': 'application/json;charset=UTF-8',
    },body: jsonEncode(<String,String>{
      'name': loginFieldController.text,
      'password': repeatPasswordFieldController.text
    }));
    if(response.statusCode==200){

    }else{

    }

  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Регистрация"),
      ),
      body: Center(
          child: Container(
            width: 250,
            margin: const EdgeInsets.only(top: 150),
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 25),
                  child: TextField(
                    controller: loginFieldController,
                    decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Имя пользователя'
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 15),
                  child: TextField(
                    controller: passwordFieldController,
                    decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Пароль'
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 15),
                  child: TextField(
                    controller: repeatPasswordFieldController,
                    decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Подтвердите пароль'
                    ),
                  ),
                ),
                Container(
                    margin: const EdgeInsets.only(top: 15),
                    child: OutlinedButton(
                      onPressed: registerClick,
                      child: const Text("Создать аккаунт"),
                    )
                ),

              ],
            ),
          )
      ),
    );
  }

}
