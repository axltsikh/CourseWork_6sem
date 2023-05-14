import 'dart:convert';
import 'dart:core';
import 'dart:core';

import 'package:course_application/CustomModels/GetUserOrganisation.dart';
import 'package:course_application/CustomModels/CustomProjectMember.dart';
import 'package:course_application/CustomModels/SubTaskModel.dart';
import 'package:course_application/CustomModels/CustomOrganisationMember.dart';
import 'package:course_application/Models/Organization.dart';
import 'package:course_application/Models/SubTask.dart';
import 'package:course_application/CustomModels/CustomSubTaskModel.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:http/http.dart' as http;
import 'CustomModels/ChildSubTaskModel.dart';
import 'CustomModels/CustomProject.dart';
import 'Models/OrganisationMember.dart';
import 'Models/ProjectMember.dart';
import 'Models/User.dart';
import 'Utility.dart';
class DatabaseHandler{
  DatabaseHandler(){
    database = createDatabase();
  }
  Future<Database> database = createDatabase();
  static Future<Database> createDatabase() async{
    print("Database creation");
    final Bufferdatabase = openDatabase(
        join(await getDatabasesPath(),'CourseWork.db'),
        onCreate: (db,version) async{
          await db.execute('create table AppUser(id integer primary key AUTOINCREMENT,username text,password text,changed integer)');
          await db.execute('create table Organisation(id integer primary key AUTOINCREMENT,name text,password text,creatorID integer,changed integer,foreign key(creatorID) references AppUser(id))');
          await db.execute('create table OrganisationMember(id integer primary key AUTOINCREMENT,userID integer references AppUser(id),organisationID integer REFERENCES Organisation(id),deleted integer,changed integer)');
          await db.execute('create table Project(id INTEGER PRIMARY KEY AUTOINCREMENT,title text,decription text,startDate date,endDate date,isDone INTEGER, changed INTEGER)');
          await db.execute('create table ProjectMember(id INTEGER PRIMARY KEY AUTOINCREMENT,projectID integer references Project(id),deleted INTEGER default 0,changed INTEGER)');
          await db.execute('alter table Project add column creatorID integer references ProjectMember(id)');
          await db.execute('alter table ProjectMember add column organisationMemberID integer references OrganisationMember(id)');
          await db.execute('create table SubTask(id integer PRIMARY KEY AUTOINCREMENT,parent INTEGER null,projectID INTEGER REFERENCES Project(id),title text,isDone integer,isTotallyDone integer,changed INTEGER,weakcreated integer, created integer)');
          await db.execute('create table SubTaskExecutor(id integer PRIMARY KEY AUTOINCREMENT,subTaskID integer REFERENCES SubTask(id),executorID integer REFERENCES ProjectMember(id),changed INTEGER)');
        },
        version: 1
    );
    return Bufferdatabase;
  }

  //region reversesync
  Future<void> uploadData()async{
    await uploadAppUserData();
    await uploadProjectsData();
    uploadUnboundedParentSubTasks();
    uploadWeakCreatedChildSubTasks();
    uploadSimplyChangedChildSubTasks();
  }
  Future<void> uploadAppUserData()async{
    print("Upload user data");
    final db= await database;
    final List<Map<String,dynamic>> maps = await db.rawQuery("Select id,username,password from AppUser where changed = 1");
    var users = List.generate(maps.length, (index) {
      return User.fromJson(maps[index]);
    });
    print(users.length);
    users.forEach((element) async {
      print(element.Password);
      print(element.id);
      final String url = "http://${Utility.url}/user/changePassword";
      final response = await http.post(Uri.parse(url),headers: <String,String>{
        'Content-Type': 'application/json;charset=UTF-8',
      },body: jsonEncode(<String,String>{
        'id': element.id.toString(),
        'password': element.Password
      }));
      if(response.statusCode==200){
        print("Success");
      }else{
        print("Error");
      }
    });
  }
  Future<void> uploadProjectsData() async{
    print("uploadProjectsData");
    final db= await database;
    List<CustomProject> projectsBuffer = [];
    final List<Map<String,dynamic>> maps = await db.rawQuery("select Project.id,Project.title,Project.creatorID,Project.decription as Description,Project.endDate,Project.isDone,Project.startDate,Project.changed from Project where Project.changed=1");
    maps.toList().forEach((element) {
      int valueBuffer = element.putIfAbsent("isDone", () => null);
      bool booleanBuffer;
      if(valueBuffer == 1){
        booleanBuffer=true;
      }else{
        booleanBuffer=false;
      }
      projectsBuffer.add(CustomProject(element.putIfAbsent("id", () => null), element.putIfAbsent("title", () => null),
          element.putIfAbsent("Description", () => null), element.putIfAbsent("startDate", () => null), element.putIfAbsent("endDate", () => null),
          booleanBuffer, element.putIfAbsent("creatorID", () => null)));
    });

    for (var element in projectsBuffer) {
      int userID = 0;
      final List<Map<String,dynamic>> creatoruserID = await db.rawQuery("""select OrganisationMember.userID from ProjectMember inner join OrganisationMember on OrganisationMember.id=ProjectMember.organisationMemberID 
          inner join Project on Project.creatorID = ProjectMember.id where Project.id = ?""",[element.id]);
      creatoruserID.forEach((element) {
        userID = element.putIfAbsent("userID", () => null);
      });
      final String url = "http://${Utility.url}/reverseSync/uploadProject";
      final response = await http.post(Uri.parse(url),headers: <String,String>{
        'Content-Type': 'application/json;charset=UTF-8',
      },body: jsonEncode(<String,String>{
        'userID': userID.toString(),
        'title': element.Title,
        'description' : element.Description,
        'startDate': element.StartDate,
        'endDate' : element.EndDate
      })).then((response){
        if(response.statusCode==200){
          print("new project id: " + response.body + "localprojectid: " + element.id.toString());
          uploadProjectMembers(element.id,int.parse(response.body),element.creatorID);
        }else{
          Fluttertoast.showToast(msg: "Произошла ошибка project!");
        }
      });
    }
  }
  Future<void> uploadProjectMembers(int localProjectID,int globalProjectID,int creatorID)async{
    print("uploadProjectMembers");
    print("projectID:" + globalProjectID.toString() + "localProjectID: " + localProjectID.toString());
    Map<int,int> members= {};
    final db= await database;
    List<ProjectMember> projectMembers = [];
    int globalCreator = 0;
    final String url = "http://${Utility.url}/reverseSync/uploadProject?id="+globalProjectID.toString();
    final response = await http.get(Uri.parse(url));
    globalCreator = int.parse(response.body);
    members.addAll({creatorID : globalCreator});
    final List<Map<String,dynamic>> maps = await db.rawQuery("select id,projectID,organisationMemberID from ProjectMember where projectID = ? and id != ?",[localProjectID,creatorID]);
    maps.forEach((element) {
      projectMembers.add(ProjectMember.fromJson(element));
    });
    uploadLoop(globalProjectID, members, projectMembers).then((value){
        members = value;
        print("loopend");
        uploadParentSubTasks(globalProjectID, localProjectID,members);
    });
  }
  Future<Map<int,int>> uploadLoop(int globalProjectID,Map<int,int> members,List<ProjectMember> projectMembers) async{
    for (var element in projectMembers) {
      element.projectID = globalProjectID;
      final String url = "http://${Utility.url}/reverseSync/uploadProjectMembers";
      final response = await http.post(Uri.parse(url),headers: <String,String>{
        'Content-Type': 'application/json;charset=UTF-8',
      },body: jsonEncode(element));
      if(response.statusCode==200){
        members.addAll({element.id:int.parse(response.body)});
      }else{
        Fluttertoast.showToast(msg: "Произошла ошибка!");
      }
    }
    return members;
  }

  Future<void> uploadParentSubTasks(int globalProjectID,int localProjectID,Map<int,int> members)async {
    Map<int,int> parents = {};
    print(localProjectID);
    final db= await database;
    List<SubTask> subTasksBuffer = [];
    final List<Map<String,dynamic>> maps = await db.rawQuery("select * from SubTask where projectID=? and parent IS NULL and created = 1",[localProjectID]);
    maps.toList().forEach((element) {
      print("parentSubTask iteration");
      bool isDone = parseIntToBool(element.putIfAbsent("isDone", () => null));
      bool isTotallyDone = parseIntToBool(element.putIfAbsent("isTotallyDone", () => null));
      subTasksBuffer.add(SubTask(element.putIfAbsent("id", () => null), element.putIfAbsent("parent", () => null),
          globalProjectID, element.putIfAbsent("title", () => null), isDone, isTotallyDone));
    });
    await bufferFunc(globalProjectID, subTasksBuffer, parents).then((value){
      parents=value;
      uploadChildSubTasks(globalProjectID, members,parents);
    });
    // subTasksBuffer.forEach((element) async {
    //   element.ProjectID = globalProjectID;
    //   final String url = "http://${Utility.url}/reverseSync/uploadParentSubTask";
    //   final response = await http.post(
    //       Uri.parse(url), headers: <String, String>{
    //     'Content-Type': 'application/json;charset=UTF-8',
    //   }, body: jsonEncode(element)).then((response){
    //     if (response.statusCode == 200){
    //       print("parenttaskid: " + response.body);
    //       uploadChildSubTasks(globalProjectID, element.id,int.parse(response.body),members);
    //     } else {
    //       print("asd");
    //     }
    //   });
    // });
  }
  Future<Map<int,int>> bufferFunc(int globalProjectID,List<SubTask> subTasksBuffer,Map<int,int> parents)async{
    for(var element in subTasksBuffer){
      element.ProjectID = globalProjectID;
      final String url = "http://${Utility.url}/reverseSync/uploadParentSubTask";
      final response = await http.post(
          Uri.parse(url), headers: <String, String>{
        'Content-Type': 'application/json;charset=UTF-8',
      }, body: jsonEncode(element)).then((response){
        if (response.statusCode == 200){
          print("parenttaskid: " + response.body);
          parents.addAll({element.id:int.parse(response.body)});
          // uploadChildSubTasks(globalProjectID, element.id,int.parse(response.body),members);
        } else {
          print("asd");
        }
      });
    }
    return parents;
  }
  Future<void> uploadChildSubTasks(int globalProjectID,Map<int,int> members,Map<int,int> parents)async{
    print("uploadChildSubTasks");
    print(parents.length);
    parents.forEach((key, value){
      print("key: " + key.toString() + " value: " + value.toString());
    });
    print("projectID:" + globalProjectID.toString() + "globalparentid: " );
    final db= await database;
    List<ChildSubTaskModel> childSub = [];
      final List<Map<String,dynamic>> childmaps = await db.rawQuery("""select 
                                                                      SubTask.id as subTaskID,
                                                                      SubTask.parent as parent,
                                                                      SubTask.projectID as projectID,
                                                                      SubTask.title as title,
                                                                      SubTask.isDone as isDone,
                                                                      SubTask.isTotallyDone as isTotallyDone,
                                                                      SubTaskExecutor.executorID as executorID
                                                                      from SubTask inner Join SubTaskExecutor on SubTask.id = SubTaskExecutor.subTaskID
																	                                    inner join Project on Project.id=SubTask.projectID
                                                                      where created=1 and weakcreated=0 and Project.changed is not null""",[]);
    childmaps.toList().forEach((childelement) {
      print(childelement.putIfAbsent("executorID", () => null));
      bool isDone = parseIntToBool(childelement.putIfAbsent("isDone", () => null));
      bool isTotallyDone = parseIntToBool(childelement.putIfAbsent("isTotallyDone", () => null));
      childSub.add(ChildSubTaskModel(0, parents[childelement.putIfAbsent("parent", () => null)]!,
          globalProjectID , childelement.putIfAbsent("title", () => null), isDone,
          isTotallyDone,members[childelement.putIfAbsent("executorID", () => null)]!,
          ));
    });
    print("length: " + childSub.length.toString());
    for(var element in childSub){
      print("elelemnt: " + element.title);
      print("elelemnt: " + element.subTaskID.toString());
      print("elelemnt: " + element.parent.toString());
      // await db.rawQuery("UPDATE SubTask set changed=0,created=0,weakcreated=0 where id=?",[element.subTaskID]);
      final String url = "http://${Utility.url}/reverseSync/uploadChildSubTask";
      final response = await http.post(
          Uri.parse(url), headers: <String, String>{
        'Content-Type': 'application/json;charset=UTF-8',
      }, body: jsonEncode(element));
      if (response.statusCode == 200) {
        print("success");
      } else {
        print("asd");
      }
    }
  }


  Future<void> uploadUnboundedParentSubTasks()async {
    print("uploadUnBoundedParentSubTasks");
    final db= await database;
    List<SubTask> subTasksBuffer = [];
    final List<Map<String,dynamic>> maps = await db.rawQuery("""select SubTask.id,SubTask.parent,SubTask.title,SubTask.isDone,SubTask.isTotallyDone,SubTask.projectID from SubTask
                                                                inner join Project on Project.id = SubTask.projectID where created = 1 and Project.changed is null and parent is null""");
    maps.toList().forEach((element) {
      bool isDone = parseIntToBool(element.putIfAbsent("isDone", () => null));
      bool isTotallyDone = parseIntToBool(element.putIfAbsent("isTotallyDone", () => null));
      subTasksBuffer.add(SubTask(element.putIfAbsent("id", () => null), null,
          element.putIfAbsent("projectID", () => null), element.putIfAbsent("title", () => null), isDone, isTotallyDone));
    });
    subTasksBuffer.forEach((element) async{
      print("parenttask iteration");
      final String url = "http://${Utility.url}/reverseSync/uploadParentSubTask";
      await http.post(
          Uri.parse(url), headers: <String, String>{
        'Content-Type': 'application/json;charset=UTF-8',
      }, body: jsonEncode(element)).then((response){
        if (response.statusCode == 200) {
          print("parentsubtask iteration finished: " + response.body);
          uploadUnboundedChildSubTasks(element.id,int.parse(response.body));
        } else {
          print("asd");
        }
      });
    });
  }
  Future<void> uploadUnboundedChildSubTasks(int localParentID,int globalParentID)async{
    print("uploadUnboundedChildSubTasks");
    final db= await database;
    List<ChildSubTaskModel> childSub = [];
    print(localParentID);
    final List<Map<String,dynamic>> childmaps = await db.rawQuery("""select 
                                                                      SubTask.id as subTaskID,
                                                                      SubTask.parent as parent,
                                                                      SubTask.projectID as projectID,
                                                                      SubTask.title as title,
                                                                      SubTask.isDone as isDone,
                                                                      SubTask.isTotallyDone as isTotallyDone,
                                                                      SubTaskExecutor.executorID as executorID
                                                                      from SubTask inner Join SubTaskExecutor on SubTask.id = SubTaskExecutor.subTaskID
                                                                      where parent = ?""",[localParentID]);
    childmaps.toList().forEach((childelement) {
      print(childelement.putIfAbsent("executorID", () => null));
      bool isDone = parseIntToBool(childelement.putIfAbsent("isDone", () => null));
      bool isTotallyDone = parseIntToBool(childelement.putIfAbsent("isTotallyDone", () => null));
      childSub.add(new ChildSubTaskModel(0, globalParentID,
        childelement.putIfAbsent("projectID", () => null) , childelement.putIfAbsent("title", () => null), isDone,
        isTotallyDone,childelement.putIfAbsent("executorID", () => null),
      ));
    });
    childSub.forEach((element) async{
      final String url = "http://${Utility.url}/reverseSync/uploadChildSubTask";
      final response = await http.post(
          Uri.parse(url), headers: <String, String>{
        'Content-Type': 'application/json;charset=UTF-8',
      }, body: jsonEncode(element));
      if (response.statusCode == 200) {
        print("success");
      } else {
        print("asd");
      }
    });

  }
  Future<void> uploadWeakCreatedChildSubTasks()async{
    print("uploadWeakCreatedChildSubTasks");
    final db= await database;
    List<ChildSubTaskModel> childSub = [];
    final List<Map<String,dynamic>> childmaps = await db.rawQuery("""select 
                                                                      SubTask.id as subTaskID,
                                                                      SubTask.parent as parent,
                                                                      SubTask.projectID as projectID,
                                                                      SubTask.title as title,
                                                                      SubTask.isDone as isDone,
                                                                      SubTask.isTotallyDone as isTotallyDone,
                                                                      SubTaskExecutor.executorID as executorID
                                                                      from SubTask inner Join SubTaskExecutor on SubTask.id = SubTaskExecutor.subTaskID
                                                                      where weakcreated = 1""");
    childmaps.toList().forEach((childelement) {
      print(childelement.putIfAbsent("executorID", () => null));
      bool isDone = parseIntToBool(childelement.putIfAbsent("isDone", () => null));
      bool isTotallyDone = parseIntToBool(childelement.putIfAbsent("isTotallyDone", () => null));
      childSub.add(ChildSubTaskModel(0, childelement.putIfAbsent("parent", () => null),
        childelement.putIfAbsent("projectID", () => null) , childelement.putIfAbsent("title", () => null), isDone,
        isTotallyDone,childelement.putIfAbsent("executorID", () => null),
      ));
    });
    childSub.forEach((element) async{
      final String url = "http://${Utility.url}/reverseSync/uploadChildSubTask";
      final response = await http.post(
          Uri.parse(url), headers: <String, String>{
        'Content-Type': 'application/json;charset=UTF-8',
      }, body: jsonEncode(element));
      if (response.statusCode == 200) {
        print("success");
      } else {
        print("asd");
      }
    });
  }
  Future<void> uploadSimplyChangedChildSubTasks()async{
    print("uploadChangedChildSubTasks");
    final db= await database;
    List<SubTask> childSub = [];
    final List<Map<String,dynamic>> childmaps = await db.rawQuery("""select 
                                                                      SubTask.id as subTaskID,
                                                                      SubTask.parent as parent,
                                                                      SubTask.projectID as projectID,
                                                                      SubTask.title as title,
                                                                      SubTask.isDone as isDone,
                                                                      SubTask.isTotallyDone as isTotallyDone
                                                                      from SubTask where changed = 1""");
    childmaps.toList().forEach((childelement) {
      bool isDone = parseIntToBool(childelement.putIfAbsent("isDone", () => null));
      bool isTotallyDone = parseIntToBool(childelement.putIfAbsent("isTotallyDone", () => null));
      childSub.add(SubTask(childelement.putIfAbsent("subTaskID", () => null), childelement.putIfAbsent("parent", () => null),
        childelement.putIfAbsent("projectID", () => null) , childelement.putIfAbsent("title", () => null), isDone,
        isTotallyDone
      ));
    });
    childSub.forEach((element) async{
      final String url = "http://${Utility.url}/reverseSync/uploadSimplyChangedChildSubTask";
      final response = await http.post(
          Uri.parse(url), headers: <String, String>{
        'Content-Type': 'application/json;charset=UTF-8',
      }, body: jsonEncode(element));
      if (response.statusCode == 200) {
        print("success");
      } else {
        print("asd");
      }
    });

  }
  //endregion

  //region sync
  Future<List<User>> getUsers() async{
    final db= await database;
    final List<Map<String,dynamic>> maps = await db.query("AppUser");
    return List.generate(maps.length, (index) {
      return User.fromJson(maps[index]);
    });
  }
  Future<void> GetAllData() async{
    final db = await database;
    db.delete("AppUser");
    db.delete("Organisation");
    db.delete("OrganisationMember");
    db.delete("ProjectMember");
    db.delete("Project");
    db.delete("SubTask");
    db.delete("SubTaskExecutor");
    db.insert("AppUser", Utility.user.toJson(),conflictAlgorithm: ConflictAlgorithm.replace);
    getOrg(db);
    getProjMembers(db);
    getProjects(db);
    getSubTasks(db);
    getSubTasksExecutors(db);
  }
  Future<void> getOrg(Database db) async{
    final String url = "http://${Utility.url}/profile/getUserOrganisation?id=" + Utility.user.id.toString();
    final response = await http.get(Uri.parse(url));
    if(response.statusCode == 200){
      Map<String,dynamic> bodyBuffer = jsonDecode(response.body);
      var buffer = GetUserOrganisation.fromJson(bodyBuffer);
      Organization orgBuffer = new Organization(buffer.id, buffer.name, buffer.password, buffer.creatorID);
      db.insert("Organisation",orgBuffer.toJson(),conflictAlgorithm: ConflictAlgorithm.replace);
      getOrgMembers(db, orgBuffer);
    }
    else{
      return;
    }
  }
  Future<void> getOrgMembers(Database db,Organization org) async{
    print("orgmem");
    final String url = "http://${Utility.url}/local/getOrganisationMemberRows?id=" + org.id.toString();
    final response = await http.get(Uri.parse(url));
    if(response.statusCode == 200){
      List<dynamic> bodyBuffer = jsonDecode(response.body);
      bodyBuffer.forEach((element) {
        db.insert("OrganisationMember", element,conflictAlgorithm: ConflictAlgorithm.replace);
      });
      getAllOrganisationUsers(db, org);
    }
    else{
      return;
    }
  }
  Future<void> getAllOrganisationUsers(Database db,Organization org)async{
    print("orgmem");
    final String url = "http://${Utility.url}/local/getAllOrganisationUsersRows?id=" + org.id.toString();
    final response = await http.get(Uri.parse(url));
    if(response.statusCode == 200){
      List<dynamic> bodyBuffer = jsonDecode(response.body);
      bodyBuffer.forEach((element) {
        db.insert("AppUser", element,conflictAlgorithm: ConflictAlgorithm.replace);
      });
    }
    else{
      return;
    }
  }
  Future<void> getProjMembers(Database db)async{
    print("projmem");
    final String url = "http://${Utility.url}/local/getProjectMemberRows?id=" + Utility.user.id.toString();
    final response = await http.get(Uri.parse(url));
    if(response.statusCode == 200){
      List<dynamic> bodyBuffer = jsonDecode(response.body);
      bodyBuffer.forEach((element) {
        db.insert("ProjectMember", element,conflictAlgorithm: ConflictAlgorithm.replace);
      });
    }
    else{
      return;
    }
  }
  Future<void> getProjects(Database db)async{
    print("projectGet");
    final String url = "http://${Utility.url}/local/getProjectRows?id=" + Utility.user.id.toString();
    final response = await http.get(Uri.parse(url));
    if(response.statusCode == 200){
      List<dynamic> bodyBuffer = jsonDecode(response.body);
      bodyBuffer.forEach((element) {
        db.insert("Project", element,conflictAlgorithm: ConflictAlgorithm.replace);
      });
    }
    else{
      return;
    }
  }
  Future<void> getSubTasks(Database db)async{
    print("subTasksGet");
    final String url = "http://${Utility.url}/local/getSubTasksRows?id=" + Utility.user.id.toString();
    final response = await http.get(Uri.parse(url));
    if(response.statusCode == 200){
      List<dynamic> bodyBuffer = jsonDecode(response.body);
      bodyBuffer.forEach((element) {
        db.insert("SubTask", element,conflictAlgorithm: ConflictAlgorithm.replace);
      });
    }
    else{
      return;
    }
  }
  Future<void> getSubTasksExecutors(Database db)async{
    print("subTasksGet");
    final String url = "http://${Utility.url}/local/getSubTasksExecutorRows?id=" + Utility.user.id.toString();
    final response = await http.get(Uri.parse(url));
    if(response.statusCode == 200){
      List<dynamic> bodyBuffer = jsonDecode(response.body);
      bodyBuffer.forEach((element) {
        db.insert("SubTaskExecutor", element,conflictAlgorithm: ConflictAlgorithm.replace);
      });
    }
    else{
      return;
    }
  }
  //endregion

  Future<List<User>> getUser(String username) async{
    final db= await database;
    final List<Map<String,dynamic>> maps = await db.query("AppUser");
    return List.generate(maps.length, (index) {
      return User.fromJson(maps[index]);
    }).where((element) => element.Username == username).toList();
  }
  Future<List<CustomProject>> getProjectsFromLocal() async{
    final db= await database;
    List<CustomProject> projectsBuffer = [];
    final List<Map<String,dynamic>> maps = await db.rawQuery("select Project.id,Project.title,Project.creatorID,Project.decription as Description,Project.endDate,Project.isDone,Project.startDate From Project inner join ProjectMember on Project.id = ProjectMember.projectID inner join OrganisationMember on OrganisationMember.id = ProjectMember.organisationMemberID where OrganisationMember.userID=? and OrganisationMember.deleted=0",[Utility.user.id]);
    maps.toList().forEach((element) {
      print("iteration");
      int valueBuffer = element.putIfAbsent("isDone", () => null);
      bool booleanBuffer;
      if(valueBuffer == 1){
        booleanBuffer=true;
      }else{
        booleanBuffer=false;
      }
      projectsBuffer.add(CustomProject(element.putIfAbsent("id", () => null), element.putIfAbsent("title", () => null),
          element.putIfAbsent("Description", () => null), element.putIfAbsent("startDate", () => null), element.putIfAbsent("endDate", () => null),
           booleanBuffer, element.putIfAbsent("creatorID", () => null)));
    });
    return projectsBuffer;
  }
  //singleProjectPage
  Future<List<User>> getProjectCreatorUserID(int projectID) async{
    final db= await database;
    List<CustomProject> projectsBuffer = [];
    final List<Map<String,dynamic>> maps = await db.rawQuery("select AppUser.id,AppUser.username,AppUser.password from Project inner join ProjectMember on Project.creatorID = ProjectMember.id inner join OrganisationMember on OrganisationMember.id = ProjectMember.organisationMemberID inner join AppUser on AppUser.id = OrganisationMember.userID where Project.id = ?"
        ,[projectID]);
    return List.generate(maps.length, (index) {
      return User.fromJson(maps[index]);
    });
  }
  Future<List<CustomProjectMember>> getAllProjectMembers(int projectID) async{
    final db= await database;
    final List<Map<String,dynamic>> maps = await db.rawQuery("select ProjectMember.id,AppUser.username,OrganisationMember.id as organisationID,ProjectMember.deleted from ProjectMember inner join OrganisationMember on OrganisationMember.id = ProjectMember.organisationMemberID and OrganisationMember.deleted=0 inner join AppUser on AppUser.id = OrganisationMember.userID where projectID = ?"
        ,[projectID]);
    return List.generate(maps.length, (index) {
      return CustomProjectMember.fromJson(maps[index]);
    });
  }
  Future<List<SubTask>> getProjectParentTasks(int projectID) async{
    final db= await database;
    List<SubTask> subTasksBuffer = [];
    final List<Map<String,dynamic>> maps = await db.rawQuery("select * from SubTask where projectID=? and parent IS NULL",[projectID]);
    maps.toList().forEach((element) {
      bool isDone = parseIntToBool(element.putIfAbsent("isDone", () => null));
      bool isTotallyDone = parseIntToBool(element.putIfAbsent("isTotallyDone", () => null));
      subTasksBuffer.add(new SubTask(element.putIfAbsent("id", () => null), element.putIfAbsent("parent", () => null),
          element.putIfAbsent("projectID", () => null), element.putIfAbsent("title", () => null), isDone, isTotallyDone));
    });
    return subTasksBuffer;
  }
  Future<List<SubTaskModel>> getProjectChildTasks(int projectID) async{
    final db= await database;
    List<SubTaskModel> subTasksBuffer = [];
    final List<Map<String,dynamic>> maps = await db.rawQuery("""select SubTaskExecutor.id as subTaskExecutorID,SubTaskExecutor.subTaskID ,AppUser.username,
                                                                SubTask.title,SubTask.isDone,SubTask.parent,SubTask.isTotallyDone from SubTaskExecutor 
                                                                inner join ProjectMember on ProjectMember.id=SubTaskExecutor.executorID 
                                                                inner join OrganisationMember on OrganisationMember.id = ProjectMember.organisationMemberID
                                                                inner join AppUser on AppUser.id=OrganisationMember.userID 
                                                                inner join SubTask on SubTask.id = SubTaskExecutor.subTaskID and SubTask.projectID=? and SubTask.parent is not null""",[projectID]);
    maps.toList().forEach((element) {
      bool isDone = parseIntToBool(element.putIfAbsent("isDone", () => null));
      bool isTotallyDone = parseIntToBool(element.putIfAbsent("isTotallyDone", () => null));
      subTasksBuffer.add(new SubTaskModel(element.putIfAbsent("subTaskExecutorID", () => null),
          element.putIfAbsent("subTaskID", () => null),
          element.putIfAbsent("username", () => null),
          element.putIfAbsent("title", () => null),
          isDone, isTotallyDone,
          element.putIfAbsent("parent", () => null)));
    });
    return subTasksBuffer;
  }
  //addProjMemberDialog
  Future<List<CustomOrganisationMember>> getOrganisationMember(int userID) async{
    print(userID);
    final db= await database;
    final List<Map<String,dynamic>> maps = await db.rawQuery(
        """select OrganisationMember.id,AppUser.username from OrganisationMember inner join AppUser on AppUser.id = OrganisationMember.userID
            where  OrganisationMember.organisationID = (Select OrganisationMember.organisationID from OrganisationMember 
            where OrganisationMember.userID = ? and OrganisationMember.deleted = 0) and OrganisationMember.userID!=? and OrganisationMember.deleted = 0"""
    ,[userID,userID]);
    print(maps.length);
    return List.generate(maps.length, (index) {
      return CustomOrganisationMember.fromJson(maps[index]);
    });
  }
  //profilePage
  Future<GetUserOrganisation> getUserOrganisation() async{
    final db= await database;
    GetUserOrganisation org = GetUserOrganisation(-1, "Вы не состоите в организации", "", -1, -1);
    final List<Map<String,dynamic>> maps = await db.rawQuery(
      """select Organisation.creatorID,Organisation.id,Organisation.name,Organisation.password,
          OrganisationMember.userID from Organisation inner join OrganisationMember on 
          Organisation.id = OrganisationMember.organisationID and OrganisationMember.deleted!=1
          where OrganisationMember.userID = ?"""
    ,[Utility.user.id]);
    maps.toList().forEach((element) {
      org = GetUserOrganisation.fromJson(element);
    });
    return org;
  }
  Future<List<Organization>> getAllOrganisatios() async{
    final db= await database;
    var a = await db.rawQuery("SELECT * FROM Organisation");
    print(a.length);
    return List.generate(a.length, (index){
      return Organization.fromJson(a[index]);
    });
  }
  bool parseIntToBool(int value){
    if(value ==1){
      return true;
    }else{
      return false;
    }
  }
  Future<CustomSubTaskModel> getParenSubTaskCondition(int id)async{
    CustomSubTaskModel buffer = CustomSubTaskModel.empty();
    final db= await database;
    var a = await db.rawQuery("Select * from SubTask where id = ?",[id]);
    for (var element in a) {
      buffer = CustomSubTaskModel.fromJson(element);
    }
    return buffer;
  }
  //region localDatabase
  Future<void> updatePassword(String newPassword)async{
    final db= await database;
    try{
      db.rawQuery("Update AppUser set password = ?,changed = 1 where id = ?",[newPassword,Utility.user.id]);
      Fluttertoast.showToast(msg: "Пароль успешно изменен");
    }catch(e){
      Fluttertoast.showToast(msg: "Произошла ошибка");
    }
  }
  Future<int> leaveOrganisation() async{
    final db = await database;
    try{
      db.rawQuery("update OrganisationMember set deleted = 1,changed = 1 where userID = ?",[Utility.user.id]);
      return 1;
    }catch(e){
      return 0;
    }
  }
  Future<void> createProject(String title,String desc,String startDate,String endDate,List<CustomProjectMember> members)async{
    print("Local createProject");
    final db= await database;
    OrganisationMember member = OrganisationMember(0, 0, 0, false);
    String projectNumber="";
    String memberNumber ="";
    var organisationMember = await db.rawQuery("select * from OrganisationMember WHERE OrganisationMember.userID=? and OrganisationMember.deleted=0",[Utility.user.id]);
    organisationMember.forEach((element) {
      var a =element.putIfAbsent("deleted", () => null);
      member = OrganisationMember(element.putIfAbsent('id', () => null) as int,
          element.putIfAbsent('userID', () => null) as int,
          element.putIfAbsent('organisationID', () => null) as int,
          parseIntToBool(a as int)
          );
    });
    db.rawQuery("insert into Project(title,decription,startDate,endDate,isDone,changed,creatorID) values(?,?,?,?,?,?,?)",[title,desc,startDate,endDate,0,1,null]);
    var a = await db.rawQuery("select seq from sqlite_sequence where name=?",["Project"]);
    a.forEach((element) {
      projectNumber = element.putIfAbsent("seq", () => null).toString();
    });
    db.rawQuery("insert into ProjectMember(projectID,changed,organisationMemberID) values (?,?,?)",[projectNumber,1,member.id]);
    a = await db.rawQuery("select seq from sqlite_sequence where name=?",["ProjectMember"]);
    a.forEach((element) {
      memberNumber = element.putIfAbsent("seq", () => null).toString();
    });
    db.rawQuery("update Project set creatorID = ? where id = ?",[memberNumber,projectNumber]);
    addProjectMembers(members, projectNumber);
  }
  Future<void> addProjectMembers(List<CustomProjectMember> members,String projectID) async{
    final db= await database;
    members.forEach((element) {
      db.rawQuery("insert into ProjectMember(projectID,changed,organisationMemberID) values(?,?,?)",[projectID,1,element.organisationID]);
    });
  }
  Future<void> addParentSubTask(SubTask subtask)async{
    print("subtask add");
    final db= await database;
    db.rawQuery("insert into SubTask(parent,projectID,title,isDone,isTotallyDone,changed,weakcreated,created) values(?,?,?,?,?,?,?,?)",[
      null,subtask.ProjectID,subtask.title,0,0,0,0,1
    ]);
  }
  Future<void> addChildSubTask(SubTask subtask,CustomProjectMember subtaskexecutor,int status)async{
    print("subtask add");
    final db= await database;
    if(status == 1){
      db.rawQuery("insert into SubTask(parent,projectID,title,isDone,isTotallyDone,changed,weakcreated,created) values(?,?,?,?,?,?,?,?)",[
        subtask.parent,subtask.ProjectID,subtask.title,0,0,0,0,1
      ]);
    }else if(status == 0){
      db.rawQuery("insert into SubTask(parent,projectID,title,isDone,isTotallyDone,changed,weakcreated,created) values(?,?,?,?,?,?,?,?)",[
        subtask.parent,subtask.ProjectID,subtask.title,0,0,0,1,0
      ]);
    }
    String subTaskNumber="";
    var a = await db.rawQuery("select seq from sqlite_sequence where name=?",["SubTask"]);
    a.forEach((element) {
      subTaskNumber = element.putIfAbsent("seq", () => null).toString();
    });
    addSubTaskExecutor(subTaskNumber, subtaskexecutor);
  }
  Future<void> addSubTaskExecutor(String subTaskNumber,CustomProjectMember subtaskexecutor)async{
    print(subtaskexecutor.id);
    print(subtaskexecutor.organisationID);
    print("subtaskexecutor add");
    final db= await database;
    db.rawQuery("insert into SubTaskExecutor(subTaskID,executorID,changed) values(?,?,?)",[
      subTaskNumber,subtaskexecutor.id,1
    ]);
  }
  Future<void> commitChanges(List<SubTaskModel> buffer)async{
    print("commit");
    final db = await database;
    buffer.forEach((element) {
      print(element.SubTaskID);
      print(element.isDone);
      if(element.isDone==true){
        db.rawQuery("Update SubTask set isDone = 1,isTotallyDone = 1,changed = 1 where id = ?",[element.SubTaskID]);
      }else if(element.isDone==false){
        db.rawQuery("Update SubTask set isDone = 0,changed = 1 where id = ?",[element.SubTaskID]);
      }
    });
  }
  Future<void> offerChanges(List<SubTaskModel> buffer) async{
    print("offer");
    final db = await database;
    buffer.forEach((element) {
      db.rawQuery("UPDATE SubTask set isDone = ?,changed = 1 where id = ?",[element.isDone,element.SubTaskID]);
    });
  }
  //endregion
}