class OrganisationMember{
  int id;
  int userID;
  int organisationID;
  bool deleted;
  OrganisationMember(this.id,this.userID,this.organisationID,this.deleted);
  OrganisationMember.fromJson(Map<String,dynamic> json)
      :id = json['id'],
        userID = json['userID'],
        organisationID = json['organisationID'],
        deleted = json['deleted'];
  Map<String,dynamic> toJson() => {
    'id' : id,
    'userID' : userID,
    'organisationID' : organisationID,
    'deleted' : deleted
  };
}