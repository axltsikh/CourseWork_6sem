import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:course_application/CustomModels/GetUserOrganisation.dart';
import 'package:course_application/JoinOrganizationPage.dart';
import 'package:course_application/OrganisationManagementPage.dart';
import 'package:course_application/Utility.dart';
import 'package:course_application/main.dart';
import 'package:course_application/manyUsageTemplate/CupertinoButtonTemplate.dart';
import 'package:course_application/manyUsageTemplate/TextField.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;

class ProfilePage extends StatefulWidget{
  ProfilePage(){}
  @override
  State<StatefulWidget> createState() => _ProfilePageState();
}
class _ProfilePageState extends State<ProfilePage> {

  _ProfilePageState(){
    getOrganisation();
  }
  @override
  void didUpdateWidget(covariant ProfilePage oldWidget) {
    print("update");
    getOrganisation();
    super.didUpdateWidget(oldWidget);
  }
  void changePasswordClick() async{
    print(oldPasswordController.text);
    print(Utility.user.Password);
    print(newPasswordController.text);
    print(repeatNewPasswordController.text);
    if(oldPasswordController.text == Utility.user.Password && repeatNewPasswordController.text == newPasswordController.text){
      await changePassword();
    }else{
      print("wrong");
    }
  }
  Future<void> changePassword() async{
    final String url = "http://10.0.2.2:5000/user/changePassword";
    final response = await http.post(Uri.parse(url),headers: <String,String>{
      'Content-Type': 'application/json;charset=UTF-8',
    },body: jsonEncode(<String,String>{
      'id': Utility.user.id.toString(),
      'password': repeatNewPasswordController.text
    }));
    if(response.statusCode==200){
      Utility.user.Password=repeatNewPasswordController.text;
      setState(() {
        oldPasswordController.text="";
        newPasswordController.text ="";
        repeatNewPasswordController.text = "";
      });
    }else{
      print(response.statusCode);
    }
  }
  Future<void> getOrganisation() async{
    final connectivityResult = await (Connectivity().checkConnectivity());
    if(connectivityResult == ConnectivityResult.none){
      var org = await Utility.databaseHandler.getUserOrganisation();
      setState(() {
        userOrganisation = org;
      });
    }else{
      final String url = "http://10.0.2.2:5000/profile/getUserOrganisation?id=" + Utility.user.id.toString();
      final response = await http.get(Uri.parse(url));
      if(response.statusCode == 200){
        Map<String,dynamic> bodyBuffer = jsonDecode(response.body);
        setState(() {
          userOrganisation = GetUserOrganisation.fromJson(bodyBuffer);
        });
      }
      else{
        setState(() {
          userOrganisation = GetUserOrganisation(-1, "Вы не состоите в организации", "", -1, -1);
        });
      }
    }
  }
  Future<void> leaveOrganisation() async{
    if(userOrganisation.id==-1){
      print("Нет организации");
      return;
    }
    final String url = "http://10.0.2.2:5000/organisation/leave?id=" + Utility.user.id.toString();
    final response = await http.delete(Uri.parse(url));
    if(response.statusCode==200){
      setState(() {
        userOrganisation = GetUserOrganisation(-1, "Вы не состоите в организации", "", -1, -1);
      });
    }else{
      print("Error: " + response.body);
    }
  }

  GetUserOrganisation userOrganisation = GetUserOrganisation(-1, "", "", 0, 0);
  TextEditingController oldPasswordController = TextEditingController();
  TextEditingController newPasswordController = TextEditingController();
  TextEditingController repeatNewPasswordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Profile"),
        actions: [
          IconButton(onPressed: (){
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const MyHomePage(title: "Login")));
          }, icon: Icon(Icons.exit_to_app))
        ],

      ),
      body: Center(
        child: Column(
          children: [
            SizedBox(
              height: 200,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  SizedBox(
                  width: 300,
                  height: 50,
                  child: Card(
                    elevation: 10,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50)
                      ),
                      child: Align(
                        alignment: Alignment.center,
                        child: Text(Utility.user.Username),
                      )
                  ),
                ),
                  SizedBox(
                    width: 300,
                    height: 50,
                    child: Card(
                      elevation: 10,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50)
                        ),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(50),
                          onTap: (){
                            print(userOrganisation.creatorID);
                            print(Utility.user.id);
                            if(userOrganisation.creatorID==Utility.user.id){
                              Navigator.of(context).push(
                                  CupertinoPageRoute(builder: (context) => OrganisationManagementPage(userOrganisation))
                              );
                            }else{
                              print("asd");
                            }
                          },
                          child: Align(
                            alignment: Alignment.center,
                            child: Text(userOrganisation.name),
                          ),
                        )
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      CupertinoButtonTemplate("Вступить в\nорганизацию", () {
                        if(userOrganisation.id==-1){
                          Navigator.of(context).push(
                              CupertinoPageRoute(builder: (context) => JoinOrganizationPage())
                          );
                        }else{
                          Fluttertoast.showToast(msg: "Вы состоите в организации!",toastLength: Toast.LENGTH_SHORT,);
                        }
                      }),
                      CupertinoButtonTemplate("Выйти из\nорганизацию", leaveOrganisation)
                      ],
                  ),],
              ),
            ),
            Padding(
              padding: EdgeInsets.all(15),
              child: Divider(thickness: 2,color: Colors.blue,),
            ),
            Container(
              margin: EdgeInsets.only(top: 0),
              child: Column(
                children: [
                  Text("Изменить пароль"),
                  SizedBox(
                    width: 300,
                    height: 150,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        TextFieldTemplate(oldPasswordController,"Введите старый пароль"),
                        TextFieldTemplate(newPasswordController,"Введите новый пароль"),
                        TextFieldTemplate(repeatNewPasswordController,"Подтвердите новый пароль"),
                      ],
                    ),
                  ),
                  CupertinoButtonTemplate("Изменить пароль", changePasswordClick)

                ],
              ),
            )
          ],
        ),
      )
    );
  }

}