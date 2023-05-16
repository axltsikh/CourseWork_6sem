import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:course_application/CustomModels/GetUserOrganisation.dart';
import 'package:course_application/manyUsageTemplate/CupertinoButtonTemplate.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import '../CustomModels/CustomOrganisationMember.dart';
import '../Utility/Utility.dart';

class OrganisationManagementPage extends StatefulWidget{
  OrganisationManagementPage(this.organisation){}
  GetUserOrganisation organisation;
  @override
  State<StatefulWidget> createState() => _OrganisationManagementPage(organisation);
}
class _OrganisationManagementPage extends State<OrganisationManagementPage> {
  _OrganisationManagementPage(this.organisation){
    getOrganisationMembers();

  }
  TextEditingController controller = TextEditingController();
  GetUserOrganisation organisation;
  List<CustomOrganisationMember> organisationMembers = [];
  Future<void> getOrganisationMembers() async{
    final connectivityResult = await (Connectivity().checkConnectivity());
    if(connectivityResult == ConnectivityResult.none){
      var organisationMembersBuffer = await Utility.databaseHandler.getOrganisationMember(Utility.user.id);
      print("orgmemlen: " + organisationMembersBuffer.length.toString());
      setState(() {
        organisationMembers = organisationMembersBuffer;
        controller.text = organisation.name;
      });
    }else {
      final String url = "http://${Utility.url}/organisation/getMembers";
      final response = await http.post(Uri.parse(url),headers: <String,String>{
        'Content-Type': 'application/json;charset=UTF-8',
      },body: jsonEncode(<String,String>{
        'userID': Utility.user.id.toString(),
      }));
      if(response.statusCode==200){
        organisationMembers.clear();
        List<dynamic> bodyBuffer = jsonDecode(response.body);
        bodyBuffer.forEach((bodyBufferElement) {
          if(!organisationMembers.any((element) => element.id == CustomOrganisationMember.fromJson(bodyBufferElement).id)){
            organisationMembers.add(CustomOrganisationMember.fromJson(bodyBufferElement));
          }
        });
      }else{
        print("Произошла ошибка");
      }
      setState(() {
        controller.text = organisation.name;
      });
    }
  }
  Future<void> deleteOrganisationMember(CustomOrganisationMember member) async{
    final connectivityResult = await (Connectivity().checkConnectivity());
    if(connectivityResult == ConnectivityResult.none){
      Fluttertoast.showToast(msg: "Проверьте подключение к сети!");
      return;
    }
    final String url = "http://${Utility.url}/organisation/removeMember?id=" + member.id.toString();
    final response = await http.delete(Uri.parse(url));
    if(response.statusCode==200){
      setState(() {
        organisationMembers.remove(member);
      });
    }else{
      print("Error: " + response.body);
    }
  }
  Future<void> changeOrgName()async{
    final connectivityResult = await (Connectivity().checkConnectivity());
    if(connectivityResult == ConnectivityResult.none){
      Fluttertoast.showToast(msg: "Проверьте подключение к сети!");
      return;
    }
    final String url = "http://${Utility.url}/organisation/updateName";
    final response = await http.post(Uri.parse(url),headers: <String,String>{
      'Content-Type': 'application/json;charset=UTF-8',
    },body: jsonEncode(<String,String>{
      'userID': organisation.id.toString(),
      'title': controller.text,
    }));
    if(response.statusCode==200){
      setState(() {
        organisation.name=controller.text;
      });
      Fluttertoast.showToast(msg: "Название успешно изменено");
    }else{
      Fluttertoast.showToast(msg: "Произошла ошибка!");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(organisation.name),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(height: 25,),
            ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: 50
              ),
              child: Card(
                  elevation: 10,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50)
                  ),
                  child: Align(
                    alignment: Alignment.center,
                    child: CupertinoTextField.borderless(
                      textAlign: TextAlign.center,
                      controller: controller,
                    ),
                  )
              ),
            ),
            Container(height: 25,),
            CupertinoButtonTemplate("Сохранить изменения", () {changeOrgName();}),
            Container(height: 25,),
            Padding(
              padding: EdgeInsets.only(left: 15,right: 15),
              child: Divider(thickness: 1,color: Colors.blue,),
            ),
            Container(height: 15,),
            Text("Управление участниками"),
            Container(height: 25,),
            ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: 500,
                  minHeight: 150
                ),
              child: ListView.builder(
                  itemCount: organisationMembers.length,
                  itemBuilder: (BuildContext context,int index){
                    return Container(
                      child: Card(
                          elevation: 10,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(50)
                          ),
                          child: Align(
                            alignment: Alignment.center,
                            child: Row(

                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Container(width: 10,),
                                Text(organisationMembers[index].username),
                                Container(width: 250,),
                                IconButton(onPressed: (){
                                  deleteOrganisationMember(organisationMembers[index]);
                                }, icon: Icon(Icons.highlight_remove_outlined))
                              ],
                            ),
                          )
                      ),
                    );
                  }
              ),
            )
          ],
        ),
      ),
    );
  }

}