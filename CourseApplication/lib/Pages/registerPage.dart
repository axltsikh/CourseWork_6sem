import 'dart:convert';

import 'package:course_application/manyUsageTemplate/CupertinoButtonTemplate.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;

import '../Utility/Utility.dart';

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
    if(loginFieldController.text.length<3){
      Fluttertoast.showToast(msg: "Минимальная длина логина - 3 символа");
      return;
    }else if(passwordFieldController.text.length<8){
      Fluttertoast.showToast(msg: "Минмальная длина пароля - 8 символов");
      return;
    }else if(repeatPasswordFieldController.text!=passwordFieldController.text){
      Fluttertoast.showToast(msg: "Пароли не совпадают!");
      return;
    }
    await createUser();
  }
  Future<void> createUser() async{
    final response = await http.post(Uri.parse("http://${Utility.url}/user/create"),headers: <String,String>{
      'Content-Type': 'application/json;charset=UTF-8',
    },body: jsonEncode(<String,String>{
      'name': loginFieldController.text,
      'password': md5.convert(utf8.encode(repeatPasswordFieldController.text)).toString()
    }));
    if(response.statusCode==200){
      Fluttertoast.showToast(msg: "Аккаунт успешно создан");
      Navigator.pop(context);
    }else{
      Fluttertoast.showToast(msg: "Имя пользователя занято!");
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
                    controller: passwordFieldController,
                    clearButtonMode: OverlayVisibilityMode.always,
                    obscureText: true,
                  )
                ),
                Container(
                  margin: const EdgeInsets.only(top: 15),
                  child: CupertinoTextField(
                    placeholder: "Повторите пароль",
                    controller: repeatPasswordFieldController,
                    clearButtonMode: OverlayVisibilityMode.always,
                    obscureText: true,
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
      ),
    );
  }

}
