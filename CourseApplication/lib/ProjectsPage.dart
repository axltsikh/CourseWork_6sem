import 'dart:convert';
import 'dart:math';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:course_application/CreateProjectPage.dart';
import 'package:course_application/CustomModels/CustomProject.dart';
import 'package:course_application/Models/Project.dart';
import 'package:course_application/SingleProjectPage.dart';
import 'package:course_application/Utility.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ProjectsPage extends StatefulWidget{
  ProjectsPage(){}
  @override
  State<StatefulWidget> createState() => _ProjectsPageState();
}
class _ProjectsPageState extends State<ProjectsPage>{
  _ProjectsPageState(){
    print("ProjectsCreate");
    GetProjects();
  }

  @override
  void didUpdateWidget(covariant ProjectsPage oldWidget) {
    print("update");
    GetProjects();
    super.didUpdateWidget(oldWidget);
  }

  List<CustomProject> projects = [];
  Future<void> GetProjects() async{
    final connectivityResult = await (Connectivity().checkConnectivity());
    if(connectivityResult == ConnectivityResult.none){
      print("Local db  question");
      var buffer = await Utility.databaseHandler.getProjectsFromLocal();
      setState(() {
        projects = buffer;
      });
      return;
    }else{
      final String url = "http://10.0.2.2:5000/project/getAllUserProjects?userID=${Utility.user.id}";
      final response = await http.get(Uri.parse(url));
      if(response.statusCode==200){
        projects.clear();
        List<dynamic> bodyBuffer = jsonDecode(response.body);
        print(bodyBuffer.toString());
        setState(() {
          bodyBuffer.forEach((element) {
            projects.add(CustomProject.fromJson(element));
          });
        });
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.startDocked,
      floatingActionButton: Container(
        margin: EdgeInsets.only(bottom: 75),
        child: FloatingActionButton(
          onPressed: (){
            Navigator.of(context).push(
                CupertinoPageRoute(builder: (context) => CreateProjectPage())
            );
          },
          backgroundColor: Colors.blue,
          child: Container(
            child: const Icon(Icons.add),
          )
        ),
      ),
      appBar: AppBar(
        title: Text("Projects"),
      ),
      body: Padding(
        padding: EdgeInsets.all(5),
        child: ListView.builder(
          itemCount: projects.length,
          itemBuilder: (BuildContext context,int index){
            return Card(
                elevation: 10,
                shape: RoundedRectangleBorder(
                    side: BorderSide(
                      color: Colors.blue,

                    ),
                    borderRadius: BorderRadius.circular(50)
                ),
                child: SizedBox(
                  height: 150,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(50),
                    onTap: (){
                      Navigator.of(context).push(
                          CupertinoPageRoute(builder: (context) => SingleProjectPage(projects[index]))
                      );
                    },
                    child: Column(
                      children: [
                        Expanded(
                          flex: 1,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(projects[index].Title,style: TextStyle(color: Colors.black,fontSize: 20))
                            ],
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Row(
                            children: [
                              Container(
                                  margin: EdgeInsets.only(left: 25),
                                  child: Text(projects[index].Description,style: TextStyle(color: Colors.black))
                              )
                            ],
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Text(projects[index].StartDate.substring(0,10)),
                              const Text("                                                    "),
                              Text(projects[index].EndDate.substring(0,10))
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                )
            );
          },
        ),
      )

    );
  }
  @override
  void dispose() {

    super.dispose();
  }
}