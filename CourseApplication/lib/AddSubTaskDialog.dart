import 'dart:convert';

import 'package:course_application/AddProjectMemberDialog.dart';
import 'package:course_application/AddSubtaskExecutorDialog.dart';
import 'package:course_application/CustomModels/OrganisationMember.dart';
import 'package:course_application/CustomModels/ProjectMember.dart';
import 'package:course_application/Models/Project.dart';
import 'package:course_application/Models/SubTask.dart';
import 'package:course_application/Models/SubTaskExecutor.dart';
import 'package:course_application/manyUsageTemplate/CupertinoButtonTemplate.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'CustomModels/CustomProject.dart';
import 'Models/User.dart';

class AddSubTaskDialog extends StatefulWidget{
  AddSubTaskDialog(this.project,this.projectMembers,this.parentID){}
  CustomProject project;
  List<ProjectMember> projectMembers;
  int parentID;
  @override
  State<StatefulWidget> createState() => _AddSubTaskDialog(project,projectMembers,parentID);
}

class _AddSubTaskDialog extends State<AddSubTaskDialog> {
  _AddSubTaskDialog(CustomProject project,this.projectMembers,int parentID){
    subtask.parent=parentID;
    subtask.ProjectID=project.id;
  }
  List<ProjectMember> subTaskExecutors = [];
  List<ProjectMember> projectMembers;
  TextEditingController controller = TextEditingController();
  SubTask subtask = SubTask.empty();
  Future<void> addChildSubTask()async{
    print(subtask.parent);
    const String url = "http://10.0.2.2:5000/project/addChildSubTask";
    final response = await http.post(
        Uri.parse(url), headers: <String, String>{
      'Content-Type': 'application/json;charset=UTF-8',
    }, body: jsonEncode(subtask));
    if (response.statusCode == 200) {
      print(response.body);
      addSubTaskExecutor(int.parse(response.body));
    } else {
      print("asd");
    }
  }
  Future<void> addSubTaskExecutor(int subtaskID)async{
    String url = "http://10.0.2.2:5000/project/addSubTaskExecutor?subtaskID=" + subtaskID.toString();
    final response = await http.post(
        Uri.parse(url), headers: <String, String>{
      'Content-Type': 'application/json;charset=UTF-8',
    }, body: jsonEncode(subTaskExecutors[0]));
    if(response.statusCode==200){
      Navigator.pop(context,true);
    }else{
      print("Произошла ошибка");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      height: 300,
      child: Padding(
        padding: EdgeInsets.all(15),
        child: Column(
          children: [
            Text("Добавление подзадачи"),
            Divider(thickness: 1,color: Colors.blue,),
            CupertinoTextField(
              placeholder: "Введите название",
              clearButtonMode: OverlayVisibilityMode.always,
              controller: controller,
            ),
            SizedBox(height: 15,),
            CupertinoButtonTemplate("Выбрать исполнителя", () async{
                var a = await showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(
                                Radius.circular(30))),
                        contentPadding: EdgeInsets.only(top: 10.0),
                        content: AddSubTaskExecutorDialog(projectMembers),
                      );
                    }
                );
                if (a != null) {
                  setState(() {
                    subTaskExecutors.add(a);
                  });
                }
            }),
            Container(height: 15,),
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: 120,
              ),
              child:  ListView.builder(
                  shrinkWrap: true,
                  itemCount: subTaskExecutors.length,
                  itemBuilder: (BuildContext context,int index){
                    return ConstrainedBox(
                      constraints: BoxConstraints(
                          maxHeight: 40
                      ),
                      child: Card(
                        elevation: 10,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50)
                        ),
                        child: Align(
                          alignment: Alignment.center,
                          child: Text(subTaskExecutors[index].username),
                        ),
                      ),
                    );
                  }
              ),
            ),
            SizedBox(height: 10,),
            Container(
                width: 300,
                child: CupertinoButtonTemplate(
                    "Сохранить",
                        (){
                          subtask.title=controller.text;
                          addChildSubTask();
                        }
                )
            )
          ],
        ),
      )
    );
  }
}
