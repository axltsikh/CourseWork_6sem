import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:course_application/Pages/AddSubtaskExecutorDialog.dart';
import 'package:course_application/CustomModels/CustomProjectMember.dart';
import 'package:course_application/Models/SubTask.dart';
import 'package:course_application/manyUsageTemplate/CupertinoButtonTemplate.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import '../CustomModels/CustomProject.dart';
import '../Utility/Utility.dart';

class AddSubTaskDialog extends StatefulWidget{
  AddSubTaskDialog(this.project,this.projectMembers,this.parentID){}
  CustomProject project;
  List<CustomProjectMember> projectMembers;
  int parentID;
  @override
  State<StatefulWidget> createState() => _AddSubTaskDialog(project,projectMembers,parentID);
}

class _AddSubTaskDialog extends State<AddSubTaskDialog> {
  _AddSubTaskDialog(CustomProject project,this.projectMembers,int parentID){
    subtask.parent=parentID;
    subtask.ProjectID=project.id;
  }
  CustomProjectMember subTaskExecutors = CustomProjectMember(0,"Исполнитель",0,0);
  List<CustomProjectMember> projectMembers;
  TextEditingController controller = TextEditingController();
  SubTask subtask = SubTask.empty();
  Future<void> addChildSubTask()async{
    if(controller.text.length < 3){
      Fluttertoast.showToast(msg: "Минимальная длина названия подзадачи - 3 символа!");
      return;
    }else if(subTaskExecutors.username==""){
      Fluttertoast.showToast(msg: "Выберите исполнителя!");
      return;
    }

    final connectivityResult = await (Connectivity().checkConnectivity());

    if(connectivityResult == ConnectivityResult.none){
      var a = await Utility.databaseHandler.getParenSubTaskCondition(subtask.parent!);
      if(a.created==1){
        Utility.databaseHandler.addChildSubTask(subtask,subTaskExecutors,1);
      }else{
        Utility.databaseHandler.addChildSubTask(subtask,subTaskExecutors,0);
      }
      Navigator.pop(context,true);
    }else{
      final String url = "http://${Utility.url}/project/addChildSubTask";
      final response = await http.post(
          Uri.parse(url), headers: <String, String>{
        'Content-Type': 'application/json;charset=UTF-8',
      }, body: jsonEncode(subtask));
      if (response.statusCode == 200) {
        addSubTaskExecutor(int.parse(response.body));
      } else {
        Fluttertoast.showToast(msg: "Произошла ошибка");
      }
    }

  }
  Future<void> addSubTaskExecutor(int subtaskID)async{
    String url = "http://${Utility.url}/project/addSubTaskExecutor?subtaskID=" + subtaskID.toString();
    final response = await http.post(
        Uri.parse(url), headers: <String, String>{
      'Content-Type': 'application/json;charset=UTF-8',
    }, body: jsonEncode(subTaskExecutors));
    if(response.statusCode==200){
      Navigator.pop(context,true);
    }else{
      Fluttertoast.showToast(msg: "Произошла ошибка");
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
                  child: Text(subTaskExecutors.username),
                ),
              ),
            ),
            SizedBox(height: 10,),
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
                  subTaskExecutors = a;
                });
              }
            }),
            Container(height: 15,),
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
