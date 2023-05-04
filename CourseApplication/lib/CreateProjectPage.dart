import 'dart:convert';
import 'package:course_application/CustomModels/OrganisationMember.dart';
import 'package:course_application/manyUsageTemplate/CupertinoButtonTemplate.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:http/http.dart' as http;
import 'AddProjectMemberDialog.dart';
import 'CustomModels/ProjectMember.dart';
import 'Utility.dart';

class CreateProjectPage extends StatefulWidget{
  CreateProjectPage({super.key}){}
  @override
  State<StatefulWidget> createState() => _CreateProjectPage();
}
class _CreateProjectPage extends State<CreateProjectPage> {
  String startDate="Начало";
  String endDate="Конец";
  List<OrganisationMember> organisationMembers = <OrganisationMember>[];
  List<ProjectMember> projectMembers = <ProjectMember>[];
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  //

  Widget showDatePicker(){
    return AlertDialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(30))),
      contentPadding: EdgeInsets.only(top: 10.0),
      content: SfDateRangePicker(
        selectionMode: DateRangePickerSelectionMode.range,
        initialSelectedRange: PickerDateRange(
          DateTime.now().subtract(const Duration(days: 4)),
            DateTime.now().add(const Duration(days: 3))),
        )
      );
  }
  Future<void> createProject() async{
    final String url = "http://10.0.2.2:5000/project/create";
    final response = await http.post(Uri.parse(url),headers: <String,String>{
      'Content-Type': 'application/json;charset=UTF-8',
    },body: jsonEncode(<String,String>{
      'userID': Utility.user.id.toString(),
      'title': titleController.text,
      'description' : descriptionController.text,
      'startDate': startDate,
      'endDate' : endDate
    }));
    if(response.statusCode==200){
      print("Заебись");
      await addProjectMembers();
    }else{
      print("asd");
    }
  }
  Future<void> addProjectMembers() async{
    print(projectMembers.length);
    const String url = "http://10.0.2.2:5000/project/addMembers";
    final response = await http.post(Uri.parse(url),headers: <String,String>{
      'Content-Type': 'application/json;charset=UTF-8',
    },body: jsonEncode(projectMembers));
    if(response.statusCode==200){
      print("Заебись");
    }else{
      print("asd");
    }
  }
  //
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Создание проекта"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(10),
          child: Column(
            children: [
              Card(
                  elevation: 15,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50)
                  ),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                        minHeight: 50,
                        minWidth: 250
                    ),
                    child: CupertinoTextField.borderless(
                      textAlign: TextAlign.center,
                      placeholder: "Название",
                      controller: titleController,
                    ),
                  )
              ),
              Card(
                  elevation: 15,
                  shadowColor: Colors.grey,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50)
                  ),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                        minHeight: 150,
                        minWidth: 250
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          margin: EdgeInsets.only(left: 25,top: 25),
                          child: CupertinoTextField.borderless(
                            maxLines: null,
                            controller: descriptionController,
                            placeholder: "Введите описание",
                          ),
                        )
                      ],
                    ),
                  )
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Card(
                      elevation: 15,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50)
                      ),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(
                            minHeight: 50,
                            minWidth: 100
                        ),
                        child: Align(
                            alignment: Alignment.center,
                            child: Container(
                                child: Text(startDate)
                            )
                        ),
                      )
                  ),
                  Card(
                      elevation: 15,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50)
                      ),
                      child: ConstrainedBox(
                          constraints: const BoxConstraints(
                              minHeight: 50,
                              minWidth: 120
                          ),
                          child: CupertinoButtonTemplate(
                            "Выбрать даты",
                              () async{
                                var a = await showDialog(
                                    context: context,
                                    builder: (BuildContext context){
                                      return AlertDialog(
                                          shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.all(Radius.circular(30))),
                                          contentPadding: EdgeInsets.only(top: 10.0),
                                          content: Padding(
                                            padding: EdgeInsets.all(15),
                                            child: Container(
                                              width: 300,
                                              height: 250,
                                              child: SfDateRangePicker(
                                                onSelectionChanged: (DateRangePickerSelectionChangedArgs args){
                                                  setState(() {
                                                    startDate = args.value.startDate.toString().substring(0,10);
                                                    var buffer = args.value.endDate ?? args.value.startDate;
                                                    endDate = buffer.toString().substring(0,10);
                                                  });
                                                },

                                                selectionMode: DateRangePickerSelectionMode.range,
                                                initialSelectedRange: PickerDateRange(
                                                    DateTime.now().subtract(const Duration(days: 4)),
                                                    DateTime.now().add(const Duration(days: 3))),
                                              ),
                                            ),
                                          )
                                      );
                                    }
                                );
                              }
                          )
                      )
                  ),
                  Card(
                      elevation: 15,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50)
                      ),
                      child: ConstrainedBox(
                          constraints: const BoxConstraints(
                              minHeight: 50,
                              minWidth:100
                          ),
                          child: Align(
                              alignment: Alignment.center,
                              child: Container(
                                  child: Text(endDate)
                              )
                          ),
                      )
                  ),
                ],
              ),
              SizedBox(height: 25,),
              Divider(),
              Align(
                alignment: Alignment.center,
                child: Text("Управление участниками"),
              ),
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: 150
                ),
                child: ListView.builder(
                  itemCount: projectMembers.length,
                  itemBuilder: (BuildContext context,int index){
                    return Card(
                      elevation: 10,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50)
                      ),
                      child: SizedBox(
                        height: 40,
                        child: Align(
                          alignment: Alignment.center,
                          child: Text(projectMembers[index].username as String),
                        ),
                      ),
                    );
                  },
                ),
              ),
              CupertinoButtonTemplate("Добавить участника", () async{
                var a = await showDialog(
                    context: context,
                    builder: (BuildContext context){
                      return AlertDialog(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(30))),
                        contentPadding: EdgeInsets.only(top: 10.0),
                        content: AddProjectMemberDialog(projectMembers),
                      );
                    }
                );
                setState(() {
                  if(a!=null){
                    projectMembers.add(a);
                  }
                });
              }),
              Container(height: 25,),
              CupertinoButtonTemplate("Создать проект", createProject)
            ],
          ),
        )
      ),
    );
  }

}