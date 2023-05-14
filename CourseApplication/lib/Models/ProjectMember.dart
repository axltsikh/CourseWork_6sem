class ProjectMember{
  int id;
  int projectID;
  int organisationMemberID;
  ProjectMember(this.id,this.projectID,this.organisationMemberID);
  ProjectMember.fromJson(Map<String,dynamic> json)
      :id = json['id'],
        projectID = json['projectID'],
        organisationMemberID = json['organisationMemberID'];
  Map<String,dynamic> toJson() => {
    'id' : id,
    'projectID' : projectID,
    'organisationMemberID' : organisationMemberID
  };
}