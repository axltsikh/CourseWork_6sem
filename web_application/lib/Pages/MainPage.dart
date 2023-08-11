import 'dart:convert';
import 'package:context_menus/context_menus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animation_progress_bar/flutter_animation_progress_bar.dart';
import 'package:http/http.dart' as http;
import 'package:oktoast/oktoast.dart';
// import 'package:liquid_progress_indicator/liquid_progress_indicator.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:wave/config.dart';
import 'package:wave/wave.dart';
import 'package:web_application/Models/SubTask.dart';
import 'dart:html' as html;
import '../Models/CustomProject.dart';
import 'SingleProjectPage.dart';
import '../Utility.dart';


class MainPage extends StatefulWidget{
  @override
  State<StatefulWidget> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  _MainPageState(){
    GetProjects();
    html.document.body!
        .addEventListener('contextmenu', (event) => event.preventDefault());
  }
  static const _backgroundColor = Colors.white70;

  static const _colors = [
    Colors.white70,
    Color(0xFF00BBF9),
  ];

  static const _durations = [
    5000,
    4000,
  ];

  static const _heightPercentages = [
    0.0,
    0.5,
  ];
  List<CustomProject> projects = [];
  List<List<SubTask>> childSubTasks = [];
  String newEndDate = "";
  Future<void> GetProjects() async{
    final response = await http.post(Uri.http('127.0.0.1:5000','/web/getAllCreatorProjects'),headers: <String,String>{
      "Access-Control-Allow-Origin": "*",
      'Content-Type': 'application/json;charset=UTF-8',
    },body: jsonEncode(<String,String>{
      'userID': Utility.user.id.toString(),
    }));

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
      await GetChildSubTasks();
    }else{
      print("Projects error");
    }
  }
  Future<void> GetChildSubTasks() async{
    projects.forEach((element) async {
      final response = await http.post(Uri.http('127.0.0.1:5000','/web/GetAllChildSubTasks'),headers: <String,String>{
        "Access-Control-Allow-Origin": "*",
        'Content-Type': 'application/json;charset=UTF-8',
      },body: jsonEncode(<String,String>{
        'projectID': element.id.toString(),
      }));
      if(response.statusCode==200){
        List<dynamic> bodyBuffer = jsonDecode(response.body);
        List<SubTask> buffer = [];
        bodyBuffer.forEach((element) {
          buffer.add(SubTask.fromJson(element));
        });
        setState(() {
            childSubTasks.add(buffer);
        });
      }else{
        print("ChildSubTasks error");
      }
    });
  }

  double getSubtaskPercentsForProgressBars(CustomProject project){
    try{
      List<SubTask> subTasksBuffer = [];
      for (int i = 0; i < childSubTasks.length; i++) {
        if (childSubTasks[i].any((element) => element.ProjectID == project.id)) {
          subTasksBuffer = childSubTasks[i];
        }
      }
      int buffer = subTasksBuffer.length;
      if(buffer==0){
        buffer=1;
      }
      double percents = subTasksBuffer
          .where((element) => element.isTotallyDone == true)
          .toList()
          .length / buffer;
      return percents*100;
    }
    catch(e){
      print("exc");
      return 0;
    }
  }
  double getDaysPercentsForProgressBar(CustomProject project){
    try{
      int alltime = DateTime
          .parse(project.EndDate)
          .difference(DateTime.parse(project.StartDate))
          .inDays;
      int timeEllapsed = DateTime.now().difference(DateTime.parse(project.StartDate)).inDays;
      double timeElapsedPercent = (timeEllapsed / alltime);
      if(timeElapsedPercent>1){
        return 100;
      }
      return timeElapsedPercent*100;
    }catch(e){
      print("exc");
      return 0;
    }
  }
  Color getSubTaskColorByPercents(double percents){
    try{
      if(percents<40){
        return Colors.red.shade300;
      }else if(percents<70){
        return Colors.yellow.shade300;
      }
      return Colors.green.shade300;
    }
    catch(e){
      print("exc");
      return Colors.white70;
    }
  }
  Color getDaysColorByPercents(double percents){
    try{
      if(percents<40){
        return Colors.green.shade300;
      }else if(percents<70){
        return Colors.yellow.shade300;
      }
      return Colors.red.shade300;
    }
    catch(e){
      print("exc");
      return Colors.white70;
    }
  }


  Widget showDatePicker(){
    return AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(30))),
        contentPadding: EdgeInsets.only(top: 10.0),
        content: SfDateRangePicker(
          selectionMode: DateRangePickerSelectionMode.single,
          initialSelectedDate: DateTime.now(),
        )
    );
  }
  Future<void> updateProjectDate(CustomProject project)async{
    final response = await http.post(Uri.http('127.0.0.1:5000','/web/prolongProjectDate'),headers: <String,String>{
      "Access-Control-Allow-Origin": "*",
      'Content-Type': 'application/json;charset=UTF-8',
    },body: jsonEncode(<String,String>{
      'projectID': project.id.toString(),
      'endDate': newEndDate.toString()
    }));
    if(response.statusCode==200){
      await GetProjects();
      await GetChildSubTasks();
      Navigator.pop(context);
    }else{

      showToast("Произошла ошибка");
    }
  }
  Future<void> endProject(CustomProject project)async{
    List<SubTask> subTasksBuffer = [];
    for (int i = 0; i < childSubTasks.length; i++) {
      if (childSubTasks[i].any((element) => element.ProjectID == project.id)) {
        subTasksBuffer = childSubTasks[i];
      }
    }
    if(subTasksBuffer.any((element) => element.isTotallyDone == false)){
      showToast("Все задачи проекта должны быть выполнены!");
      return;
    }
    final response = await http.post(Uri.http('127.0.0.1:5000','/web/endProject'),headers: <String,String>{
      "Access-Control-Allow-Origin": "*",
      'Content-Type': 'application/json;charset=UTF-8',
    },body: jsonEncode(<String,String>{
      'projectID': project.id.toString(),
    }));
    if(response.statusCode==200){
      await GetProjects();
      await GetChildSubTasks();
    }else{
      showToast("Произошла ошибка!",position: ToastPosition.bottom,);
    }
  }
  Future<void> deleteProject(CustomProject project)async{
    final response = await http.delete(Uri.http('127.0.0.1:5000','/project/delete'),headers: <String,String>{
      "Access-Control-Allow-Origin": "*",
      'Content-Type': 'application/json;charset=UTF-8',
    },body: jsonEncode(<String,String>{
      'id': project.id.toString(),
    }));
    if(response.statusCode==200){
      await GetProjects();
      await GetChildSubTasks();
    }else{
      showToast("Произошла ошибка!",position: ToastPosition.bottom,);
    }
  }
  Widget getTextWidget(int index){
    if(index==0 && projects[index].isDone == true && projects.length==1){
      return Container(
        margin: EdgeInsets.only(left: 75),
        child: const Text("Выполненные задачи",style: TextStyle(fontSize: 25),),
      );
    }
    if(index == 0){
      return Container(
        margin: EdgeInsets.only(left: 75),
        child: const Text("Текущие задачи",style: TextStyle(fontSize: 25),),
      );
    }else if(projects[index].isDone == true && projects[index-1].isDone == false){
      return Container(
        margin: EdgeInsets.only(left: 75),
        child: const Text("Выполненные задачи",style: TextStyle(fontSize: 25),),
      );
    }
    return Text("");
  }
  Future<void> setDate(int index)async{
    var a = await showDialog(
        context: context,
        builder: (BuildContext context){
          return AlertDialog(
              shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(30))),
              contentPadding: const EdgeInsets.only(top: 10.0),
              content: Padding(
                padding: const EdgeInsets.all(15),
                child: SizedBox(
                    width: 300,
                    height: 390,
                    child: Column(
                      children: [
                        const Text("Выберите новую дату"),
                        const Divider(color: Colors.blue,),
                        SfDateRangePicker(
                          onSelectionChanged: (DateRangePickerSelectionChangedArgs args){
                            setState(() {
                              newEndDate = args.value.toString().substring(0,10);
                              print(newEndDate);
                            });
                          },
                          selectionMode: DateRangePickerSelectionMode.single,
                          initialSelectedDate: DateTime.now(),
                        ),
                        CupertinoButton.filled(
                          onPressed: (){
                            updateProjectDate(projects[index]);
                          },
                          borderRadius: BorderRadius.circular(50),
                          child: const Text("Сохранить изменения"),
                        )
                      ],
                    )
                ),
              )
          );
        }
    );
    print("prolong");
  }
  Widget inkWell(int index){
    return InkWell(
      borderRadius: BorderRadius.circular(100),
      onTap: (){Navigator.push(context, MaterialPageRoute(builder: (context)=>SingleProjectPage(projects[index])));},
      child: SizedBox(
        height: 250,
        width: 500,
        child: Column(
          children: [
            Expanded(
              flex: 1,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(projects[index].Title,style: const TextStyle(color: Colors.black,fontSize: 20))
                ],
              ),
            ),
            Expanded(
              flex: 1,
              child: Row(
                children: [
                  Container(
                      margin: const EdgeInsets.only(left: 25),
                      child: Text(projects[index].Description,style: const TextStyle(color: Colors.black))
                  )
                ],
              ),
            ),
            Expanded(
                flex: 1,
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Text(projects[index].StartDate.substring(0,10)),
                        const Text("                                                          "),
                        Text(projects[index].EndDate.substring(0,10))
                      ],
                    ),
                  ],
                )
            )
          ],
        ),
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    return ContextMenuOverlay(
      child: Scaffold(
          appBar: AppBar(
            title: Text("Все проекты"),
            actions: [
              IconButton(onPressed: (){
                GetProjects();
              }, icon:Icon(Icons.sync)),
            ],
          ),
          body: ListView.builder(
            itemCount: projects.length,
            itemBuilder: (BuildContext context,int index){
              return Column(
                children: [
                  getTextWidget(index),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Column(
                        children: [
                          Text("Выполнено задач: "),
                          Container(
                            width: 250,
                            child: FAProgressBar(
                              currentValue: getSubtaskPercentsForProgressBars(projects[index]),
                              size: 25,
                              maxValue: 100,
                              changeProgressColor: Colors.pink,
                              backgroundColor: Colors.white70,
                              border: Border.all(
                                  color: getSubTaskColorByPercents( getSubtaskPercentsForProgressBars(projects[index]))
                              ),
                              progressColor: getSubTaskColorByPercents( getSubtaskPercentsForProgressBars(projects[index])),
                              animatedDuration: const Duration(milliseconds: 300),
                              direction: Axis.horizontal,
                              verticalDirection: VerticalDirection.up,
                              displayText: '%',
                              displayTextStyle: TextStyle(color: Colors.black),
                              formatValueFixed: 0,
                            ),
                          ),
                          Container(
                            height: 15,
                          ),
                          Text("Прошло времени: "),
                          Container(
                            width: 250,
                            child: FAProgressBar(
                              currentValue: getDaysPercentsForProgressBar(projects[index]),
                              size: 25,
                              maxValue: 100,
                              border: Border.all(
                                color: getDaysColorByPercents(getDaysPercentsForProgressBar(projects[index])),
                              ),
                              changeProgressColor: Colors.pink,
                              backgroundColor: Colors.white70,
                              progressColor: getDaysColorByPercents(getDaysPercentsForProgressBar(projects[index])),
                              animatedDuration: const Duration(milliseconds: 300),
                              direction: Axis.horizontal,
                              verticalDirection: VerticalDirection.up,
                              displayText: '%',
                              formatValueFixed: 0,
                              displayTextStyle: TextStyle(color: Colors.black),
                            ),
                          ),
                        ],
                      ),
                      Container(width: 15,),
                      ContextMenuRegion(
                        contextMenu: GenericContextMenu(
                          buttonConfigs: [
                            ContextMenuButtonConfig("Продлить дату проекта", onPressed: ()async{
                              setDate(index);
                            }),
                            ContextMenuButtonConfig("Завершить проект", onPressed: (){
                              endProject(projects[index]);
                              print("end click");
                            }),
                            ContextMenuButtonConfig("Удалить проект", onPressed: (){
                              deleteProject(projects[index]);
                              print("delete click");
                            })
                          ],
                        ),
                        child: Card(
                            elevation: 10,
                            shape: RoundedRectangleBorder(
                                side: const BorderSide(
                                  color: Colors.blue,
                                ),
                                borderRadius: BorderRadius.circular(100)
                            ),
                            shadowColor: Colors.blue,
                            child: inkWell(index)
                        ),
                      ),
                    ],
                  )
                ],
              );
            },
          ),
      ),
    );
  }

}