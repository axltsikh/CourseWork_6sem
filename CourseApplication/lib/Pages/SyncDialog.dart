import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:course_application/Models/SubTask.dart';
import 'package:course_application/manyUsageTemplate/CupertinoButtonTemplate.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../CustomModels/CustomProject.dart';
import '../Utility/Utility.dart';
import 'ProjectsPage.dart';
class SyncDialog extends StatefulWidget{
  @override
  State<StatefulWidget> createState() => _SyncDialog();
}

class _SyncDialog extends State<SyncDialog> {

  void sync()async{
    state=true;
    setState(() {
      getState();
    });
    Fluttertoast.showToast(msg: "Синхронизация началсь");
    await uploadMyData().then((value) {
      Future.delayed(Duration(seconds: 3)).then((value)async{
        await getGlobalData().then((value){
          Fluttertoast.showToast(msg: "Синхронизация прошла успешно");
          Navigator.pop(context);
        });
      });
    });
  }
  Future<bool> uploadMyData()async{
    await Utility.databaseHandler.uploadData().then((value){
    });
    return true;
  }
  Future<void> getGlobalData()async{
    final connectivityResult = await (Connectivity().checkConnectivity());
    if(connectivityResult == ConnectivityResult.none){
      return;
    }
    Future.delayed(Duration(seconds: 5)).then((value)async{
      print("duration finished");
      await Utility.databaseHandler.GetAllData();
    });
  }
  void decline(){
    Navigator.pop(context);
  }
  bool state=false;
  Widget getState(){
    if(!state){
      return Text("Желаете провести синхронизацию?");
    }else{
      return Center(child: CircularProgressIndicator());
    }
  }
  Widget buttons(){
    if(!state){
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          CupertinoButtonTemplate("Да", () {sync();}),
          CupertinoButtonTemplate("Нет", () {decline();})
        ],
      );
    }else{
      return Text("");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        width: 250,
        height: 200,
        child: Padding(
          padding: EdgeInsets.all(15),
          child: Column(
            children: [
              Text("Синхронизация"),
              Divider(thickness: 1,color: Colors.blue,),
              SizedBox(height: 15,),
              getState(),
              SizedBox(height: 25,),
              buttons()
            ],
          ),
        )
    );
  }

}