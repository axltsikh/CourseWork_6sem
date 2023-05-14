import 'package:course_application/DatabaseHandler.dart';

import 'Models/User.dart';

class Utility{
  static String url = "10.0.2.2:5000";
  //10.0.2.2:5000 emulator
  //192.168.60.55:5000 phone
  static int asd = 1;
  static User user = User(0,"","");
  static DatabaseHandler databaseHandler = DatabaseHandler();
  static bool connectionStatus = false;
}