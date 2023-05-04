import 'dart:convert';
import 'dart:core';
import 'dart:core';

import 'package:course_application/CustomModels/GetUserOrganisation.dart';
import 'package:course_application/CustomModels/ProjectMember.dart';
import 'package:course_application/CustomModels/SubTaskModel.dart';
import 'package:course_application/CustomModels/OrganisationMember.dart';
import 'package:course_application/Models/Organization.dart';
import 'package:course_application/Models/SubTask.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:http/http.dart' as http;
import 'CustomModels/CustomProject.dart';
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
          await db.execute('create table AppUser(id integer primary key AUTOINCREMENT,username text,password text)');
          await db.execute('create table Organisation(id integer primary key AUTOINCREMENT,name text,password text,creatorID integer,foreign key(creatorID) references AppUser(id))');
          await db.execute('create table OrganisationMember(id integer primary key AUTOINCREMENT,userID integer references AppUser(id),organisationID integer REFERENCES Organisation(id),deleted integer)');
          await db.execute('create table Project(id INTEGER PRIMARY KEY AUTOINCREMENT,title text,decription text,startDate date,endDate date,isDone INTEGER)');
          await db.execute('create table ProjectMember(id INTEGER PRIMARY KEY AUTOINCREMENT,projectID integer references Project(id))');
          await db.execute('alter table Project add column creatorID integer references ProjectMember(id)');
          await db.execute('alter table ProjectMember add column organisationMemberID integer references OrganisationMember(id)');
          await db.execute('create table SubTask(id integer PRIMARY KEY AUTOINCREMENT,parent INTEGER null,projectID INTEGER REFERENCES Project(id),title text,isDone integer,isTotallyDone integer)');
          await db.execute('create table SubTaskExecutor(id integer PRIMARY KEY AUTOINCREMENT,subTaskID integer REFERENCES SubTask(id),executorID integer REFERENCES ProjectMember(id))');
        },
        version: 1
    );
    return Bufferdatabase;
  }

  //sync
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
    final String url = "http://10.0.2.2:5000/profile/getUserOrganisation?id=" + Utility.user.id.toString();
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
    final String url = "http://10.0.2.2:5000/local/getOrganisationMemberRows?id=" + org.id.toString();
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
    final String url = "http://10.0.2.2:5000/local/getAllOrganisationUsersRows?id=" + org.id.toString();
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
    final String url = "http://10.0.2.2:5000/local/getProjectMemberRows?id=" + Utility.user.id.toString();
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
    final String url = "http://10.0.2.2:5000/local/getProjectRows?id=" + Utility.user.id.toString();
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
    final String url = "http://10.0.2.2:5000/local/getSubTasksRows?id=" + Utility.user.id.toString();
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
    final String url = "http://10.0.2.2:5000/local/getSubTasksExecutorRows?id=" + Utility.user.id.toString();
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
    print(projectsBuffer.length);
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
  Future<List<ProjectMember>> getAllProjectMembers(int projectID) async{
    final db= await database;
    final List<Map<String,dynamic>> maps = await db.rawQuery("select ProjectMember.id,AppUser.username,OrganisationMember.id as organisationID from ProjectMember inner join OrganisationMember on OrganisationMember.id = ProjectMember.organisationMemberID and OrganisationMember.deleted=0 inner join AppUser on AppUser.id = OrganisationMember.userID where projectID = ?"
        ,[projectID]);
    return List.generate(maps.length, (index) {
      return ProjectMember.fromJson(maps[index]);
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
  Future<List<OrganisationMember>> getOrganisationMember(int userID) async{
    final db= await database;
    final List<Map<String,dynamic>> maps = await db.rawQuery(
        """select OrganisationMember.id,AppUser.username from OrganisationMember inner join AppUser on AppUser.id = OrganisationMember.userID
            where  OrganisationMember.organisationID = (Select OrganisationMember.organisationID from OrganisationMember 
            where OrganisationMember.userID = ? and OrganisationMember.deleted = 0) and OrganisationMember.userID!=? and OrganisationMember.deleted = 0"""
    ,[userID,userID]);
    return List.generate(maps.length, (index) {
      return OrganisationMember.fromJson(maps[index]);
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

  bool parseIntToBool(int value){
    if(value ==1){
      return true;
    }else{
      return false;
    }
  }
  
}