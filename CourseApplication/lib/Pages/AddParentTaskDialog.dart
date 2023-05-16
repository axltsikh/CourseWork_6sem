import 'package:course_application/Models/SubTask.dart';
import 'package:course_application/manyUsageTemplate/CupertinoButtonTemplate.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../CustomModels/CustomProject.dart';
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

  void returnSubTask(){
    if(controller.text.length < 3){
      Fluttertoast.showToast(msg: "Минимальная длина названия задачи - 3 символа!");
      return;
    }
    subTask.title=controller.text;
    subTask.ProjectID=project.id;
    Navigator.pop(context,subTask);
  }

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
              Text("Добавление задачи"),
              Divider(thickness: 1,color: Colors.blue,),
              SizedBox(height: 15,),
              CupertinoTextField(
                placeholder: "Название задачи",
                controller: controller,
              ),
              SizedBox(height: 15,),
              CupertinoButtonTemplate(
                  "Сохранить",
                  returnSubTask
              )
            ],
          ),
        )
    );
  }

}