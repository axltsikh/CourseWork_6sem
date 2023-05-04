import 'package:course_application/AddProjectMemberDialog.dart';
import 'package:course_application/AddSubtaskExecutorDialog.dart';
import 'package:course_application/CustomModels/OrganisationMember.dart';
import 'package:course_application/Models/Project.dart';
import 'package:course_application/Models/SubTask.dart';
import 'package:course_application/Models/SubTaskExecutor.dart';
import 'package:course_application/manyUsageTemplate/CupertinoButtonTemplate.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'CustomModels/CustomProject.dart';
class AddParentTaskDialog extends StatefulWidget{
  AddParentTaskDialog(this.project){}
  CustomProject project;
  @override
  State<StatefulWidget> createState() => _AddParentTaskDialog(project);
}

class _AddParentTaskDialog extends State<AddParentTaskDialog> {
  _AddParentTaskDialog(this.project){
    print(project.id);
  }
  CustomProject project;
  TextEditingController controller = TextEditingController();
  SubTask subTask = SubTask.empty();
  @override
  Widget build(BuildContext context) {
    return Container(
        width: 250,
        height: 200,
        child: Padding(
          padding: EdgeInsets.all(15),
          child: Column(
            children: [
              Text("Добавление подзадачи"),
              Divider(thickness: 1,color: Colors.blue,),
              SizedBox(height: 15,),
              CupertinoTextField(
                placeholder: "Название задачи",
                controller: controller,
              ),
              SizedBox(height: 15,),
              CupertinoButtonTemplate(
                  "Сохранить",
                      (){
                    subTask.title=controller.text;
                    subTask.ProjectID=project.id;
                    print(subTask.ProjectID);
                    Navigator.pop(context,subTask);
                  }
              )
            ],
          ),
        )
    );
  }

}