class CustomProject{
  int id;
  String Title;
  String Description;
  String StartDate;
  String EndDate;
  bool isDone;
  int creatorID;

  CustomProject(this.id,this.Title,this.Description,this.StartDate,this.EndDate,this.isDone,this.creatorID);
  CustomProject.fromJson(Map<String,dynamic> json)
      :id = json['id'],
        Title = json['title'],
        Description = json['Description'],
        StartDate = json['startDate'],
        EndDate = json['endDate'],
        isDone = json['isDone'],
        creatorID = json['creatorID'];
  Map<String,dynamic> toJson() => {
    'id' : id,
    'Title' : Title,
    'Description' : Description,
    'StartDate' : StartDate,
    'EndDate' : EndDate,
    'isDone' : isDone,
    'creatorID' : creatorID,
  };
}
