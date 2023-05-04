import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:http/http.dart' as http;
import 'package:course_application/CustomModels/OrganisationMember.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'CustomModels/ProjectMember.dart';
import 'Utility.dart';


class AddProjectMemberDialog extends StatefulWidget{
  AddProjectMemberDialog(this.projectMembers){}
  List<ProjectMember> projectMembers;
  @override
  State<StatefulWidget> createState() => _AddProjectMemberDialog(projectMembers);
}

class _AddProjectMemberDialog extends State<AddProjectMemberDialog> {
  _AddProjectMemberDialog(this.projectMembers){
    getOrganisationMembers();
    print(Utility.user.id);
    print(projectMembers.length);
  }
  Future<void> getOrganisationMembers() async{
    final connectivityResult = await (Connectivity().checkConnectivity());
    if(connectivityResult == ConnectivityResult.none){
      var organisationMembersBuffer = await Utility.databaseHandler.getOrganisationMember(Utility.user.id);
      organisationMembers = organisationMembersBuffer;
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
          if(!projectMembers.any((element) => element.organisationID == OrganisationMember.fromJson(bodyBufferElement).id)){
            setState(() {
              organisationMembers.add(OrganisationMember.fromJson(bodyBufferElement));
            });
          }
        });
      }else{
        print("Произошла ошибка");
      }
    }
  }
  List<OrganisationMember> organisationMembers=[];
  List<ProjectMember> projectMembers;
  @override
  Widget build(BuildContext context) {
    return Container(
        width: 250,
        height: 350,
        child: Padding(
          padding: EdgeInsets.all(15),
          child: Column(
            children: [
              Text("Добавление участника"),
              Divider(thickness: 1,color: Colors.blue),
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: 285
                ),
                child:  ListView.builder(
                    shrinkWrap: true,
                    itemCount: organisationMembers.length,
                    itemBuilder: (BuildContext context,int index){
                      return ConstrainedBox(
                        constraints: BoxConstraints(
                            minHeight: 50
                        ),
                        child: Card(
                          elevation: 10,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)
                          ),
                          child: InkWell(
                            onTap: (){
                              ProjectMember buffer = ProjectMember(0, organisationMembers[index].username, organisationMembers[index].id);
                              Navigator.pop(context,buffer);
                            },
                              child: Align(
                              alignment: Alignment.center,
                              child: Text(organisationMembers[index].username),
                            ),
                          )
                        ),
                      );
                    }
                ),
              ),
            ],
          ),
        )
    );
  }

}