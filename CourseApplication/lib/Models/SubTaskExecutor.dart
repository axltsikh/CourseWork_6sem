class SubTaskExecutor{
  int id;
  int subTaskId;
  int executorID;
  SubTaskExecutor(this.id,this.subTaskId,this.executorID);
  SubTaskExecutor.fromJson(Map<String,dynamic> json)
      :id = json['id'],
        subTaskId = json['subTaskId'],
        executorID = json['executorID'];
  Map<String,dynamic> toJson() => {
    'id' : id,
    'executorID' : executorID,
    'subTaskId' : subTaskId,
  };
}