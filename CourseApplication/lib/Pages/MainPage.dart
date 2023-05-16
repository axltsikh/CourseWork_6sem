import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:course_application/Pages/ProfilePage.dart';
import 'package:course_application/Pages/ProjectsPage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../Utility/Utility.dart';

class MainPage extends StatefulWidget{
  @override
  State<StatefulWidget> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> with WidgetsBindingObserver{
  Widget getItem(int index){
    if(index == 1){
      return ProfilePage();
    }else{
      return ProjectsPage();
    }
  }
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if(state == AppLifecycleState.paused){
        Connectivity().checkConnectivity().then((value){
          if(value == ConnectivityResult.wifi || value == ConnectivityResult.mobile){
            Utility.databaseHandler.uploadData().then((value){
              Future.delayed(Duration(seconds: 3)).then((value){
                Utility.databaseHandler.GetAllData();
              });
            });
          }
        });
    }
  }
  @override
  Widget build(BuildContext context) {
    return CupertinoTabScaffold(

        tabBar: CupertinoTabBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(icon: Icon(Icons.list),label: "Проекты"),
            BottomNavigationBarItem(icon: Icon(Icons.person),label: "Профиль")
          ],
        ),
        tabBuilder: (BuildContext context,int index){
          return CupertinoTabView(
            builder: (BuildContext context){
              return getItem(index);
            },
          );
        }
    );
  }
  
}