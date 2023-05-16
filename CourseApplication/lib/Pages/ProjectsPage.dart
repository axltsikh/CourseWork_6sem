import 'dart:async';
import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:course_application/Pages/CreateProjectPage.dart';
import 'package:course_application/CustomModels/CustomProject.dart';
import 'package:course_application/Pages/SingleProjectPage.dart';
import 'package:course_application/Utility/Utility.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../CustomModels/GetUserOrganisation.dart';

class ProjectsPage extends StatefulWidget{
  ProjectsPage(){}
  @override
  State<StatefulWidget> createState() => _ProjectsPageState();
}
class _ProjectsPageState extends State<ProjectsPage>{
  StreamSubscription<ConnectivityResult>? a;
  bool firstinit=true;
  _ProjectsPageState(){
    getOrganisation();
    getGlobalData();
    // (Connectivity().checkConnectivity()).then((value){
    //   if(value == ConnectivityResult.none){
    //     GetProjects();
    //     firstinit=false;
    //   }
    // });
    // a = Connectivity().onConnectivityChanged.listen((ConnectivityResult event){
    //   if(event == ConnectivityResult.wifi || event == ConnectivityResult.mobile){
    //     print("asdasd");
    //     if(Utility.connectionStatus==false){
    //       reBuild();
    //     }
    //   }else if(event==ConnectivityResult.none){
    //     print("none");
    //   }
    //   else{
    //     print("none");
    //     Utility.connectionStatus=false;
    //   }
    // });
    // print("asd");
    GetProjects();
  }


  //region useless trash
  // Future<void> reBuild()async{
  //   uploadMyData().then((value){
  //     GetProjects();
  //     Future.delayed(Duration(seconds: 5)).then((value)async{
  //       print("starting sync");
  //       await getGlobalData();
  //     });
  //   });
  // }
  // Future<bool> uploadMyData()async{
  //   await Utility.databaseHandler.uploadData().then((value){
  //   });
  //   return true;
  // }
  // Future<void> checkConn()async{
  //   final connectivityResult = await (Connectivity().checkConnectivity());
  //   if(connectivityResult != ConnectivityResult.none){
  //     await Utility.databaseHandler.GetAllData();
  //     GetProjects();
  //   }else{
  //     GetProjects();
  //   }
  // }
  //endregionasd

  Future<void> getGlobalData()async{
    final connectivityResult = await (Connectivity().checkConnectivity());
    if(connectivityResult == ConnectivityResult.none){
      return;
    }
    Future.delayed(Duration(seconds: 3)).then((value)async{
      print("duration finished");
      await Utility.databaseHandler.GetAllData();
    });
  }
  Future<void> getOrganisation() async{
    final connectivityResult = await (Connectivity().checkConnectivity());
    if(connectivityResult == ConnectivityResult.none){
      var org = await Utility.databaseHandler.getUserOrganisation();
      setState(() {
        userOrganisation = org;
      });
    }else{
      final String url = "http://${Utility.url}/profile/getUserOrganisation?id=" + Utility.user.id.toString();
      final response = await http.get(Uri.parse(url));
      if(response.statusCode == 200){
        Map<String,dynamic> bodyBuffer = jsonDecode(response.body);
        setState(() {
          userOrganisation = GetUserOrganisation.fromJson(bodyBuffer);
        });
      }
      else{
        setState(() {
          userOrganisation = GetUserOrganisation(-1, "Вы не состоите в организации", "", -1, -1);
        });
      }
    }
  }

  @override
  void didUpdateWidget(covariant ProjectsPage oldWidget) {
    print("update");
    GetProjects();
    super.didUpdateWidget(oldWidget);
  }
  Widget getTextWidget(int index){
    if(index==0 && projects[index].isDone == true && projects.length==1){
      return Container(
        margin: EdgeInsets.only(left: 75),
        child: const Text("Выполненные задачи",style: TextStyle(fontSize: 25),),
      );
    }
    if(index == 0){
      return const Align(
        alignment: AlignmentDirectional.center,
        child: Text("Текущие проекты",style: TextStyle(fontSize: 25),),
      );
    }else if(projects[index].isDone == true && projects[index-1].isDone == false){
      return const Align(
        alignment: AlignmentDirectional.center,
        child: Column(
          children: [
            Divider(color: Colors.blue,),
            Text("Завершенные проекты",style: TextStyle(fontSize: 25),),
          ],
        )
      );
    }
    return Text("");
  }
  Widget getFloatingButton(){
    if(userOrganisation.id==-1){
      return Text("");
    }else{
      return FloatingActionButton(
          onPressed: (){
            Navigator.of(context).push(
                CupertinoPageRoute(builder: (context) => CreateProjectPage())
            ).then((value){GetProjects();});
          },
          backgroundColor: Colors.blue,
          child: Container(
            child: const Icon(Icons.add),
          )
      );
    }
  }
  List<CustomProject> projects = [];
  GetUserOrganisation userOrganisation = GetUserOrganisation(-1, "", "", 0, 0);
  Future<void> GetProjects() async{
    getOrganisation();
    final connectivityResult = await (Connectivity().checkConnectivity());
    if(connectivityResult == ConnectivityResult.none){
      print("Get projects from local database request");
      var buffer = await Utility.databaseHandler.getProjectsFromLocal();
      setState(() {
        projects = buffer.where((element) => element.isDone ==false).toList();
        projects += buffer.where((element) => element.isDone == true).toList();
      });
      return;
    }else{
      final String url = "http://${Utility.url}/project/getAllUserProjects?userID=${Utility.user.id}";
      final response = await http.get(Uri.parse(url));
      if(response.statusCode==200){
        projects.clear();
        List<dynamic> bodyBuffer = jsonDecode(response.body);
        List<CustomProject> buffer = [];
        bodyBuffer.forEach((element) {
          buffer.add(CustomProject.fromJson(element));
        });
        setState(() {
          projects = buffer.where((element) => element.isDone ==false).toList();
          projects += buffer.where((element) => element.isDone == true).toList();
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
        child: getFloatingButton()
      ),
      appBar: AppBar(
        title: Text("Все проекты"),
      ),
      body: RefreshIndicator(
        onRefresh: GetProjects,
        child: Padding(
          padding: EdgeInsets.all(5),
          child: ListView.builder(
            itemCount: projects.length,
            itemBuilder: (BuildContext context,int index){
              return Column(
                children: [
                  getTextWidget(index),
                  Card(
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
                  )
                ],
              );
            },
          ),
        ),
      )

    );
  }

}