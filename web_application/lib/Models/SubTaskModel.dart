class SubTaskModel{
  int SubTaskExecutorID;
  int SubTaskID;
  String username;
  String title;
  bool isDone;
  bool isTotallyDone;
  int parent;
  SubTaskModel(this.SubTaskExecutorID,this.SubTaskID,this.username,this.title,this.isDone,this.isTotallyDone,this.parent);
  SubTaskModel.fromJson(Map<String,dynamic> json)
      :SubTaskExecutorID = json['subTaskExecutorID'],
        SubTaskID = json['subTaskID'],
        username = json['username'],
        title = json['title'],
        isDone = json['isDone'],
        isTotallyDone = json['isTotallyDone'],
        parent = json['parent'];
  Map<String,dynamic> toJson() => {
    'subTaskExecutorID' : SubTaskExecutorID,
    'subTaskID' : SubTaskID,
    'username' : username,
    'title' : title,
    'isDone' : isDone,
    'isDisTotallyDoneone' : isTotallyDone,
    'parent' : parent,
  };
}