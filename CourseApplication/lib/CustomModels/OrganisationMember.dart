class OrganisationMember{
  int id;
  String username;
  OrganisationMember(this.id,this.username);
  OrganisationMember.fromJson(Map<String,dynamic> json)
      :id = json['id'],
        username = json['username'];
  Map<String,dynamic> toJson() => {
    'id' : id,
    'username' : username
  };
}