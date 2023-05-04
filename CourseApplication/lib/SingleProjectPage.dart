import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:course_application/AddParentTaskDialog.dart';
import 'package:course_application/AddProjectMemberDialog.dart';
import 'package:course_application/AddSubTaskDialog.dart';
import 'package:course_application/CustomModels/CustomProject.dart';
import 'package:course_application/CustomModels/ProjectMember.dart';
import 'package:course_application/CustomModels/SubTaskModel.dart';
import 'package:course_application/Utility.dart';
import 'package:course_application/manyUsageTemplate/CheckBoxBuilder.dart';
import 'package:course_application/manyUsageTemplate/CupertinoButtonTemplate.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:http/http.dart' as http;
import 'Models/SubTask.dart';
import 'Models/User.dart';

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
  List<ProjectMember> projectMembers = [];
  List<SubTask> parentSubTasks = [];
  List<SubTaskModel> childSubTasks = [];
  List<SubTaskModel> childSubTasksSnapshot = [];
  User projectCreator = User(0,"","");
  String ButtonText = "";
  Future<void> InitializeProject() async{
    final connectivityResult = await (Connectivity().checkConnectivity());
    projectMembers.clear();
    parentSubTasks.clear();
    childSubTasks.clear();
    if(connectivityResult == ConnectivityResult.none){
      await localInitialization();
    }else {
      await globalInitialization();
    }
  }
  Future<void> addProjectMember(ProjectMember member) async {
    const String url = "http://10.0.2.2:5000/project/addMembers";
    final response = await http.post(Uri.parse(url), headers: <String, String>{
      'Content-Type': 'application/json;charset=UTF-8',
    }, body: jsonEncode(<String, String>{
      'organisationID': member.organisationID.toString(),
      'projectID': project.id.toString(),
    }));
    if (response.statusCode == 200) {
      InitializeProject();
    } else {
      print("Ошибка");
    }}
  Future<void> addParentSubTask(SubTask subtask) async {
      const String url = "http://10.0.2.2:5000/project/addParentSubTask";
      final response = await http.post(
          Uri.parse(url), headers: <String, String>{
        'Content-Type': 'application/json;charset=UTF-8',
      }, body: jsonEncode(subtask));
      if (response.statusCode == 200) {
        InitializeProject();
      } else {
        print("asd");
      }
    }

  Future<void> saveChanges()async{
    if(projectCreator.id==Utility.user.id){
      commitChanges();
    }else{
      List<SubTaskModel> buffer = [];
      for(int i =0;i<childSubTasks.length;i++){
        if(childSubTasks[i].isDone!=childSubTasksSnapshot[i].isDone){
          buffer.add(childSubTasks[i]);
        }
      }
      if(buffer.isEmpty){
        print("Нет никаких изменений");
      }else{
        await offerChanges(buffer);
      }
    }
  }
  Future<void> offerChanges(List<SubTaskModel> buffer) async{
    final String url = "http://10.0.2.2:5000/project/offerChanges";
    final response = await http.post(Uri.parse(url),headers: <String,String>{
      'Content-Type': 'application/json;charset=UTF-8',
    },body: jsonEncode(buffer));
    if(response.statusCode==200){
      InitializeProject();
    }else{
      print('Error');
    }
  }
  Future<void> commitChanges() async{
    final String url = "http://10.0.2.2:5000/project/commitChanges";
    final response = await http.post(Uri.parse(url),headers: <String,String>{
      'Content-Type': 'application/json;charset=UTF-8',
    },body: jsonEncode(childSubTasks.where((element) => element.isTotallyDone==false).toList()));
    if(response.statusCode==200){
      InitializeProject();
    }else{
      print('Error');
    }
  }

  Future<void> localInitialization() async {
    print("Local db init question");
    var creatorBuffer = await Utility.databaseHandler.getProjectCreatorUserID(project.id);
    for (var element in creatorBuffer) {
      projectCreator = element;
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
    var projectMembersBuffer = await Utility.databaseHandler.getAllProjectMembers(project.id);
    setState(() {
      projectMembers = projectMembersBuffer;
    });
    var parentSubTasksBuffer = await Utility.databaseHandler.getProjectParentTasks(project.id);
    setState(() {
      parentSubTasks = parentSubTasksBuffer;
    });
    var childSubTasksBuffer = await Utility.databaseHandler.getProjectChildTasks(project.id);
    setState(() {
      childSubTasks = childSubTasksBuffer;
      childSubTasksSnapshot = childSubTasksBuffer;
    });
  }
  Future<void> globalInitialization() async{
    String creatorUrl = "http://10.0.2.2:5000/project/getProjectCreatorUserID?projectID=" + project.id.toString();
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
    String url = "http://10.0.2.2:5000/project/getAllProjectMembers?projectID=" + project.id.toString();
    final response = await http.get(Uri.parse(url));
    List<dynamic> bodyBuffer = jsonDecode(response.body);
    bodyBuffer.forEach((bodyBufferElement) {
      setState(() {
        projectMembers.add(ProjectMember.fromJson(bodyBufferElement));
      });
    });
    print(projectMembers.length);
    String parenturl = "http://10.0.2.2:5000/project/getProjectParentTasks?projectID=" + project.id.toString();
    final secondResponse = await http.get(Uri.parse(parenturl));
    List<dynamic> parentTasksBuffer = jsonDecode(secondResponse.body);
    parentTasksBuffer.forEach((element) {
      setState(() {
        parentSubTasks.add(SubTask.fromJson(element));
      });
    });
    String childurl = "http://10.0.2.2:5000/project/getProjectChildTasks?projectID=" + project.id.toString();
    final thirdResponse = await http.get(Uri.parse(childurl));
    List<dynamic> childTasksBuffer = jsonDecode(thirdResponse.body);
    for (var element in childTasksBuffer) {
      setState(() {
        childSubTasks.add(SubTaskModel.fromJson(element));
        childSubTasksSnapshot.add(SubTaskModel.fromJson(element));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomSheet: Container(
          margin: const EdgeInsets.only(bottom: 70,left: 120),
          child: CupertinoButton.filled(
              padding: EdgeInsets.fromLTRB(20,0,20,0),
              child: Text(ButtonText),
              onPressed: saveChanges,
              borderRadius: BorderRadius.circular(100)
          )
      ),
      appBar: AppBar(
        title: const Text("project.Title"),
      ),
      body: Container(
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Flexible(
                  flex: 2,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                        maxHeight: 300
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
                                        minHeight: 50,
                                        maxWidth: 250
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment
                                          .spaceAround,
                                      children: [
                                        Container(width: 10,),
                                        Text(parentSubTasks[mainTaskIndex].title),
                                        Container(width: 60,),
                                        IconButton(
                                          onPressed: () async{
                                            var a = await showDialog(
                                                context: context,
                                                builder: (BuildContext context) {
                                                  return AlertDialog(
                                                    shape: const RoundedRectangleBorder(
                                                        borderRadius: BorderRadius.all(
                                                            Radius.circular(30))),
                                                    contentPadding: const EdgeInsets.only(top: 10.0),
                                                    content: AddSubTaskDialog(project,projectMembers,parentSubTasks[mainTaskIndex].id),
                                                  );
                                                }
                                            );
                                            if (a != null) {
                                              if(a==true){
                                                InitializeProject();
                                              }
                                            }
                                          },
                                          icon: const Icon(Icons.add),
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
                                                    minHeight: 25,
                                                    maxWidth: 110
                                                ),
                                                child: Padding(
                                                  padding: const EdgeInsets.all(10),
                                                  child: Text(childSubTasks.where((element) => element.parent==parentSubTasks[mainTaskIndex].id).toList()[subTaskIndex].title),
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
                                                minHeight: 35,
                                                maxWidth: 80
                                            ),
                                            child: Align(
                                              alignment: Alignment.center,
                                              child: Text(childSubTasks.where((element) => element.parent==parentSubTasks[mainTaskIndex].id).toList()[subTaskIndex].username),
                                            ),
                                          )
                                      ),
                                      CheckBoxBuilder(childSubTasks.where((element) => element.parent==parentSubTasks[mainTaskIndex].id).toList()[subTaskIndex],projectCreator.id==Utility.user.id),
                                      // Checkbox(
                                      //   value: childSubTasks.where((element) => element.parent==parentSubTasks[mainTaskIndex].id).toList()[subTaskIndex].isDone,
                                      //   onChanged: (bool? value) {
                                      //     setState(() {
                                      //       childSubTasks.where((element) => element.parent==parentSubTasks[mainTaskIndex].id).toList()[subTaskIndex].isDone =
                                      //       value!;
                                      //     });
                                      //   },
                                      // )
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
                            maxHeight: 250
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
                                    minHeight: 25,
                                    minWidth: 50
                                ),
                                child: Align(
                                  alignment: Alignment.center,
                                  child: Text(projectMembers[index].username),
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                    flex: 2,
                    child: Align(
                      alignment: Alignment.center,
                      child: CupertinoButtonTemplate(
                          "Добавить\nзадачу", () async {
                        var a = await showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.all(
                                        Radius.circular(30))),
                                contentPadding: const EdgeInsets.only(top: 10.0),
                                content: AddParentTaskDialog(project),
                              );
                            }
                        );
                        if (a != null) {
                          addParentSubTask(a);
                        }
                      }),
                    )
                ),
                Flexible(
                  flex: 1,
                  child: CupertinoButtonTemplate(
                      "Добавить\nучастника", () async {
                    var a = await showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.all(
                                    Radius.circular(30))),
                            contentPadding: const EdgeInsets.only(top: 10.0),
                            content: AddProjectMemberDialog(projectMembers),
                          );
                        }
                    );
                    if (a != null) {
                      addProjectMember(a);
                    }
                  }),
                )

              ],
            )
          ],
        ),
      ),
    );
  }

  }