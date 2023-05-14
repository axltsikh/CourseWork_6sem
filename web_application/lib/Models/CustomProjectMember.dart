class CustomProjectMember{
  int id;
  String username;
  int organisationID;
  int deleted;
  CustomProjectMember(this.id,this.username,this.organisationID,this.deleted);
  CustomProjectMember.fromJson(Map<String,dynamic> json)
      :id = json['id'],
        username = json['username'],
        organisationID = json['organisationID'],
        deleted =json['deleted']==true?1:0;
  Map<String,dynamic> toJson() => {
    'id' : id,
    'username' : username,
    'organisationID' : organisationID,
    'deleted':deleted
  };
}