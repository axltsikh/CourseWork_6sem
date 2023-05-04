class ProjectMember{
  int id;
  int projectID;
  int organisationMemberId;
  ProjectMember(this.id,this.projectID,this.organisationMemberId);
  ProjectMember.fromJson(Map<String,dynamic> json)
      :id = json['id'],
        projectID = json['projectID'],
        organisationMemberId = json['organisationMemberId'];
  Map<String,dynamic> toJson() => {
    'id' : id,
    'projectID' : projectID,
    'organisationMemberId' : organisationMemberId
  };
}