class SubTask{
  int id=0;
  int? parent=null;
  int ProjectID=0;
  String title="";
  bool isDone=false;
  bool isTotallyDone=false;
  SubTask(this.id,this.parent,this.ProjectID,this.title,this.isDone,this.isTotallyDone);
  SubTask.empty();
    SubTask.fromJson(Map<String,dynamic> json)
        :id = json['id'],
          parent = json['parent'],
          ProjectID = json['projectID'],
          title = json['title'],
          isTotallyDone = json['isTotallyDone'],
          isDone = json['isDone'];
    Map<String,dynamic> toJson() => {
      'id' : id,
      'parent' : parent,
      'projectID' : ProjectID,
      'title' : title,
      'isDone' : isDone,
      'isTotallyDone':isTotallyDone
    };
}