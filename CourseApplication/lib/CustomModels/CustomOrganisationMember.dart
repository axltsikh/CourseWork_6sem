class CustomOrganisationMember{
  int id;
  String username;
  CustomOrganisationMember(this.id,this.username);
  CustomOrganisationMember.fromJson(Map<String,dynamic> json)
      :id = json['id'],
        username = json['username'];
  Map<String,dynamic> toJson() => {
    'id' : id,
    'username' : username
  };
}