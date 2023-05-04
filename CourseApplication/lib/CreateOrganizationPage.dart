import 'dart:convert';
import 'package:course_application/Utility.dart';
import 'package:course_application/manyUsageTemplate/CupertinoButtonTemplate.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;


class CreateOrganizationPage extends StatefulWidget{
  @override
  State<StatefulWidget> createState() => _CreateOrganizationPage();
}

class _CreateOrganizationPage extends State<CreateOrganizationPage> {

  TextEditingController organizationNameController = TextEditingController();
  TextEditingController organizationPasswordController = TextEditingController();
  TextEditingController organizationRepeatPasswordController = TextEditingController();
  Future<void> createOrganisation() async{
    if(organizationPasswordController.text != organizationRepeatPasswordController.text){
      return;
    }
    const String url = "http://10.0.2.2:5000/organisation/create";
    await http.post(Uri.parse(url),headers: <String,String>{
      'Content-Type': 'application/json;charset=UTF-8',
    },body: jsonEncode(<String,String>{
      'organisationName': organizationNameController.text,
      'organisationPassword': organizationRepeatPasswordController.text,
      'creatorID': Utility.user.id.toString()
    })).then((value) => {
      if(value.statusCode==200){
        print("Организация создана")
      }else{
        print("Произошла ошибка")
      }

    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Create org"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(15),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Container(height: 50,),
              CupertinoTextField(
                placeholder: "Введите название организации",
                controller: organizationNameController,
                clearButtonMode: OverlayVisibilityMode.always,
              ),
              Container(height: 25,),
              CupertinoTextField(
                placeholder: "Введите пароль организации",
                clearButtonMode: OverlayVisibilityMode.always,
                controller: organizationPasswordController,
                obscureText: true,
              ),
              Container(height: 25),
              CupertinoTextField(
                placeholder: "Подтвердите пароль организации",
                controller: organizationRepeatPasswordController,
                clearButtonMode: OverlayVisibilityMode.always,
                obscureText: true,
              ),
              Container(height: 25,),
              CupertinoButtonTemplate("Создать\nорганизацию", createOrganisation)
            ],
          ),
        )
      ),
    );
  }

}