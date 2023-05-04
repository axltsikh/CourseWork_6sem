import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:course_application/CustomModels/GetUserOrganisation.dart';
import 'package:course_application/manyUsageTemplate/CupertinoButtonTemplate.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'CustomModels/OrganisationMember.dart';
import 'Utility.dart';

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
  List<OrganisationMember> organisationMembers = [];
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
      final String url = "http://10.0.2.2:5000/organisation/getMembers";
      final response = await http.post(Uri.parse(url),headers: <String,String>{
        'Content-Type': 'application/json;charset=UTF-8',
      },body: jsonEncode(<String,String>{
        'userID': Utility.user.id.toString(),
      }));
      if(response.statusCode==200){
        organisationMembers.clear();
        List<dynamic> bodyBuffer = jsonDecode(response.body);
        bodyBuffer.forEach((bodyBufferElement) {
          if(!organisationMembers.any((element) => element.id == OrganisationMember.fromJson(bodyBufferElement).id)){
            organisationMembers.add(OrganisationMember.fromJson(bodyBufferElement));
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
  Future<void> deleteOrganisationMember(OrganisationMember member) async{
    final String url = "http://10.0.2.2:5000/organisation/removeMember?id=" + member.id.toString();
    final response = await http.delete(Uri.parse(url));
    if(response.statusCode==200){
      setState(() {
        organisationMembers.remove(member);
      });
    }else{
      print("Error: " + response.body);
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Org"),
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
            CupertinoButtonTemplate("Сохранить изменения", () { }),
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