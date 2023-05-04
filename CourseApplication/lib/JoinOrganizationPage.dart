import 'dart:convert';

import 'package:course_application/CreateOrganizationPage.dart';
import 'package:course_application/manyUsageTemplate/CupertinoButtonTemplate.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'Models/Organization.dart';
import 'Utility.dart';

class JoinOrganizationPage extends StatefulWidget{
  @override
  State<StatefulWidget> createState() => _JoinOrganizationPage();
}

class _JoinOrganizationPage extends State<JoinOrganizationPage> {
  _JoinOrganizationPage(){
    getOrganisationsList();
  }
  List<Organization> organizations = [
  ];
  Future<void> getOrganisationsList() async{
    final String url = "http://10.0.2.2:5000/organisation/getAllOrganisations";
    final response = await http.get(Uri.parse(url));
    if(response.statusCode==200){
      organizations.clear();
      List<dynamic> bodyBuffer = jsonDecode(response.body);
      setState(() {
        bodyBuffer.forEach((element) {
          organizations.add(Organization.fromJson(element));
        });
      });
    }
  }
  Future<void> joinOrganization(int organisationID) async{
    final String url = "http://10.0.2.2:5000/organisation/joinOrganisation";
    final response = await http.post(Uri.parse(url),headers: <String,String>{
      'Content-Type': 'application/json;charset=UTF-8',
    },body: jsonEncode(<String,String>{
      'userID': Utility.user.id.toString(),
      'organisationID':organisationID.toString()
    }));
    if(response.statusCode==200){
      Navigator.pop(context);
      print("Успешно выполнено");
    }else{
      print("Произошла ошибка");
    }
  }
  TextEditingController organizationPasswordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.startDocked,
      floatingActionButton: Container(
        margin: EdgeInsets.only(bottom: 75),
        child: FloatingActionButton(
            onPressed: (){
              Navigator.of(context).push(
                  CupertinoPageRoute(builder: (context) => (CreateOrganizationPage()))
              );
            },
            backgroundColor: Colors.blue,
            child: Container(
              child: const Icon(Icons.add),
            )
        ),
      ),
      appBar: AppBar(
        title: Text("Join org"),
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(15),
          child: Column(
            children: [
              const CupertinoSearchTextField(
                placeholder: "Поиск",
              ),
              ConstrainedBox(
                constraints: const BoxConstraints(
                    minHeight: 250,
                    maxHeight: 500
                ),
                child: ListView.builder(
                    itemCount: organizations.length,
                    itemBuilder: (BuildContext context,int index){
                      return ConstrainedBox(
                        constraints: const BoxConstraints(
                          minHeight: 50
                        ),
                        child: Card(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(50)
                          ),
                          child: InkWell(
                            onTap: (){
                              showDialog(
                                  context: context,
                                  builder: (BuildContext context){
                                    return AlertDialog(
                                      shape: const RoundedRectangleBorder(
                                          borderRadius: BorderRadius.all(Radius.circular(30))),
                                      contentPadding: const EdgeInsets.all(15),
                                      content: SizedBox(
                                        width: 150,
                                        height: 150,
                                        child: Column(
                                          children: [
                                            const Text("Введите пароль",style: TextStyle(fontSize: 20),),
                                            const Divider(
                                              thickness: 1,
                                              color: Colors.blue,
                                            ),
                                            Container(height: 15,),
                                            CupertinoTextField(
                                              placeholder: "Введите пароль",
                                              controller: organizationPasswordController,
                                              clearButtonMode: OverlayVisibilityMode.always,
                                              obscureText: true,
                                            ),
                                            Container(height: 15,),
                                            CupertinoButtonTemplate("Вступить", () {
                                              if(organizations[index].password==organizationPasswordController.text){
                                                joinOrganization(organizations[index].id);
                                              }else{
                                                setState(() {
                                                  organizationPasswordController.text="";
                                                });
                                                Fluttertoast.showToast(msg: "Неверный пароль");
                                              }
                                            })
                                          ],
                                        ),
                                      )
                                    );
                                  }
                              );
                            },
                            child: Align(
                              alignment: Alignment.center,
                              child: Text(organizations[index].name),
                            )
                          ),
                        ),
                      );
                    }
                ),
              )
            ],
          ),
        )
      ),
    );
  }

}