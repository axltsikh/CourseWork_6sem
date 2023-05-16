import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:http/http.dart' as http;
import '../Models/CustomProject.dart';
import '../Models/CustomProjectMember.dart';
import '../Models/SubTask.dart';
import '../Models/SubTaskModel.dart';
import '../Models/User.dart';
import '../Templates/CheckBoxBuilder.dart';
import '../Utility.dart';

class SingleProjectPage extends StatefulWidget{
  SingleProjectPage(this.project, {super.key}){}
  CustomProject project;
  // List<User> users;
  List<SubTask> parentSubTasks = [];
  @override
  State<StatefulWidget> createState() => _SingleProjectState(project);
}
class _SingleProjectState extends State<SingleProjectPage>{


  _SingleProjectState(this.project){
    InitializeProject();
  }
  CustomProject project;
  List<CustomProjectMember> projectMembers = [];
  List<SubTask> parentSubTasks = [];
  List<SubTaskModel> childSubTasks = [];
  List<SubTaskModel> childSubTasksSnapshot = [];
  User projectCreator = User(0,"","");
  String ButtonText = "";

  Future<void> InitializeProject() async{
      projectMembers.clear();
      parentSubTasks.clear();
      childSubTasks.clear();
      childSubTasksSnapshot.clear();
    await globalInitialization();
  }

  Future<void> globalInitialization() async{
    String creatorUrl = "http://${Utility.url}/project/getProjectCreatorUserID?projectID=" + project.id.toString();
    final fourthReponse = await http.get(Uri.parse(creatorUrl));
    List<dynamic> creatorBuffer = jsonDecode(fourthReponse.body);
    for (var element in creatorBuffer) {
      projectCreator = User.fromJson(element);
    }
    if (projectCreator.id == Utility.user.id) {
      setState(() {
        ButtonText = "Сохранить изменения";
      });
    }
    else {
      setState(() {
        ButtonText = "Предложить изменения";
      });
    }
    String url = "http://${Utility.url}/project/getAllProjectMembers?projectID=" + project.id.toString();
    final response = await http.get(Uri.parse(url));
    List<dynamic> bodyBuffer = jsonDecode(response.body);
    bodyBuffer.forEach((bodyBufferElement) {
      setState(() {
        projectMembers.add(CustomProjectMember.fromJson(bodyBufferElement));
      });
    });
    projectMembers = projectMembers.where((element) => element.deleted == 0).toList();
    projectMembers = projectMembers.where((element) => element.username != Utility.user.Username).toList();
    print(projectMembers.length);
    String parenturl = "http://${Utility.url}/project/getProjectParentTasks?projectID=" + project.id.toString();
    final secondResponse = await http.get(Uri.parse(parenturl));
    List<dynamic> parentTasksBuffer = jsonDecode(secondResponse.body);
    parentTasksBuffer.forEach((element) {
      setState(() {
        parentSubTasks.add(SubTask.fromJson(element));
      });
    });
    String childurl = "http://${Utility.url}/project/getProjectChildTasks?projectID=" + project.id.toString();
    final thirdResponse = await http.get(Uri.parse(childurl));
    List<dynamic> childTasksBuffer = jsonDecode(thirdResponse.body);
    for (var element in childTasksBuffer) {
      setState(() {
        childSubTasks.add(SubTaskModel.fromJson(element));
        childSubTasksSnapshot.add(SubTaskModel.fromJson(element));
      });
    }
  }
  Future<void> deleteMember(int index)async{
    String url = "http://${Utility.url}/web/deleteMember?id=" + index.toString();
    final response = await http.delete(Uri.parse(url));
    if(response.statusCode==200){
      InitializeProject();
    }
  }
  Future<void> deleteChildSubTask(int index)async{
    String url = "http://${Utility.url}/web/deleteChildSubTask?id=" + index.toString();
    final response = await http.delete(Uri.parse(url));
    if(response.statusCode==200){
      InitializeProject();
    }
  }
  Future<void> deleteParentSubTask(int index)async{
    String url = "http://${Utility.url}/web/deleteParentSubTask?id=" + index.toString();
    final response = await http.delete(Uri.parse(url));
    if(response.statusCode==200){
      InitializeProject();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(project.Title ?? ""),
        ),
        body: SingleChildScrollView(
          child: Align(
            alignment: AlignmentDirectional.center,
            child: Container(
              width: 500,
              padding: const EdgeInsets.all(15),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    elevation: 10,
                    shape: RoundedRectangleBorder(
                        side: const BorderSide(
                          color: Colors.blue,
                        ),
                        borderRadius: BorderRadius.circular(50)
                    ),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                          minHeight: 50,
                          minWidth: 150
                      ),
                      child: Align(
                        alignment: Alignment.center,
                        child: Text(project.Title),
                      ),
                    ),

                  ),
                  Container(height: 5,),
                  Card(
                      elevation: 10,
                      shape: RoundedRectangleBorder(
                          side: const BorderSide(
                            color: Colors.blue,
                          ),
                          borderRadius: BorderRadius.circular(50)
                      ),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(
                            minHeight: 150
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Text(project.Description),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Text(project.StartDate.substring(0, 10),
                                    style: const TextStyle(color: Colors.black)),
                                const Text(
                                    "                                                    "),
                                Text(project.EndDate.substring(0, 10),
                                    style: const TextStyle(color: Colors.black))
                              ],
                            ),
                          ],
                        ),
                      )
                  ),
                  Container(margin: const EdgeInsets.only(top: 25),),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Flexible(
                        flex: 2,
                        child: Text("Список задача"),
                      ),
                      SizedBox(width:120,),
                      Flexible(
                        flex: 2,
                        child: Text("Список участников"),
                      )
                    ],
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Flexible(
                        flex: 2,
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(
                            minWidth: 300,
                            maxHeight: 600
                          ),
                          child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: parentSubTasks.length,
                            itemBuilder: (BuildContext context, int mainTaskIndex) {
                              return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Card(
                                        elevation: 7,
                                        shape: RoundedRectangleBorder(
                                            side: const BorderSide(
                                              color: Colors.blue,
                                            ),
                                            borderRadius: BorderRadius.circular(50)
                                        ),
                                        child: ConstrainedBox(
                                          constraints: const BoxConstraints(
                                              minHeight: 70,
                                              minWidth: 250
                                          ),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment
                                                .spaceAround,
                                            children: [
                                              Container(width: 10,),
                                              Text(parentSubTasks[mainTaskIndex].title,style: TextStyle(fontSize: 17),),
                                              Container(width: 60,),
                                              IconButton(
                                                onPressed: () async{
                                                    deleteParentSubTask(parentSubTasks[mainTaskIndex].id);
                                                },
                                                icon: Icon(Icons.highlight_remove_outlined,color: Colors.red.shade200,),
                                              )
                                            ],
                                          ),
                                        )
                                    ),
                                    ListView.builder(
                                      physics: const NeverScrollableScrollPhysics(),
                                      shrinkWrap: true,
                                      itemCount: childSubTasks.where((element) => element.parent==parentSubTasks[mainTaskIndex].id).length,
                                      itemBuilder: (BuildContext context,
                                          int subTaskIndex) {
                                        return Row(
                                          children: [
                                            Card(
                                                shape: RoundedRectangleBorder(
                                                    side: const BorderSide(
                                                      color: Colors.blue,
                                                    ),
                                                    borderRadius: BorderRadius
                                                        .circular(50)
                                                ),
                                                elevation: 7,
                                                child: Align(
                                                  alignment: Alignment.center,
                                                  child: ConstrainedBox(
                                                      constraints: const BoxConstraints(
                                                          minHeight: 55,
                                                          maxWidth: 110
                                                      ),
                                                      child: Align(
                                                        alignment: AlignmentDirectional.center,
                                                        child: Padding(
                                                          padding: const EdgeInsets.all(10),
                                                          child: Text(childSubTasks.where((element) => element.parent==parentSubTasks[mainTaskIndex].id).toList()[subTaskIndex].title),
                                                        ),
                                                      )
                                                  ),
                                                )
                                            ),
                                            Card(
                                                elevation: 7,
                                                shape: RoundedRectangleBorder(
                                                    side: const BorderSide(
                                                      color: Colors.blue,
                                                    ),
                                                    borderRadius: BorderRadius
                                                        .circular(50)
                                                ),
                                                child: ConstrainedBox(
                                                  constraints: const BoxConstraints(
                                                      minHeight: 55,
                                                      maxWidth: 80
                                                  ),
                                                  child: Align(
                                                    alignment: Alignment.center,
                                                    child: Text(childSubTasks.where((element) => element.parent==parentSubTasks[mainTaskIndex].id).toList()[subTaskIndex].username),
                                                  ),
                                                )
                                            ),
                                            CheckBoxBuilder(childSubTasks.where((element) => element.parent==parentSubTasks[mainTaskIndex].id).toList()[subTaskIndex],projectCreator.id==Utility.user.id),
                                            SizedBox(width: 20,),
                                            IconButton(
                                              onPressed: () async{
                                                deleteChildSubTask(childSubTasks.where((element) => element.parent==parentSubTasks[mainTaskIndex].id).toList()[subTaskIndex].SubTaskID);
                                              },
                                              icon: Icon(Icons.highlight_remove_outlined,color: Colors.red.shade200,),
                                            )
                                          ],
                                        );
                                      },
                                    )
                                  ]
                              );
                            },
                          ),
                        ),
                      ),
                      Flexible(
                          flex: 1,
                          child: Align(
                            alignment: Alignment.topCenter,
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(
                                  maxHeight: 600,
                                minWidth: 250
                              ),
                              child: ListView.builder(
                                shrinkWrap: true,
                                itemCount: projectMembers.length,
                                itemBuilder: (BuildContext context, int index) {
                                  return Card(
                                    elevation: 7,
                                    shape: RoundedRectangleBorder(
                                        side: const BorderSide(
                                          color: Colors.blue,
                                        ),
                                        borderRadius: BorderRadius.circular(50)
                                    ),
                                    child: ConstrainedBox(
                                      constraints: const BoxConstraints(
                                          minHeight: 50,
                                          minWidth: 300
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                                        children: [
                                          Align(
                                            alignment: Alignment.center,
                                            child: Text(projectMembers[index].username,style: TextStyle(fontSize: 17))
                                          ),
                                          SizedBox(width: 30,),
                                          IconButton(onPressed: (){
                                            deleteMember(projectMembers[index].id);
                                          }, icon: Icon(Icons.highlight_remove_rounded,color: Colors.red.shade200,))
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          )
                      )
                    ],
                  ),
                ],
              ),
            ),
          )
        )
    );
  }

}