class ProjectMember{
  int id;
  String username;
  int organisationID;
  ProjectMember(this.id,this.username,this.organisationID);
  ProjectMember.fromJson(Map<String,dynamic> json)
      :id = json['id'],
        username = json['username'],
        organisationID = json['organisationID'];
  Map<String,dynamic> toJson() => {
    'id' : id,
    'username' : username,
    'organisationID' : organisationID
  };
}