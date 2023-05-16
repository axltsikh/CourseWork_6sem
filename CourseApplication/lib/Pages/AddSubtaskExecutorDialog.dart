import 'package:course_application/CustomModels/CustomProjectMember.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';



class AddSubTaskExecutorDialog extends StatefulWidget{
  AddSubTaskExecutorDialog(this.projectMembers){}
  List<CustomProjectMember> projectMembers;
  @override
  State<StatefulWidget> createState() => _AddSubTaskExecutorDialog(projectMembers);
}

class _AddSubTaskExecutorDialog extends State<AddSubTaskExecutorDialog> {
  _AddSubTaskExecutorDialog(this.projectMembers){}
  List<CustomProjectMember> projectMembers;

  @override
  Widget build(BuildContext context) {
    return Container(
        width: 250,
        height: 350,
        child: Padding(
          padding: EdgeInsets.all(15),
          child: Column(
            children: [
              Text("Добавление исполнителя"),
              Divider(thickness: 1,color: Colors.blue),
              ConstrainedBox(
                constraints: BoxConstraints(
                    maxHeight: 285
                ),
                child:  ListView.builder(
                    shrinkWrap: true,
                    itemCount: projectMembers.length,
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
                              onTap: () => Navigator.pop(context,projectMembers[index]),
                              child: Align(
                                alignment: Alignment.center,
                                child: Text(projectMembers[index].username),
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