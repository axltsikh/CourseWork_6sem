class Organization{
  int id;
  String name;
  String password;
  int creatorID;

  Organization(this.id,this.name,this.password,this.creatorID);
  Organization.fromJson(Map<String,dynamic> json)
      :id = json['id'],
        name = json['name'],
        password = json['password'],
        creatorID = json['creatorID'];
  Map<String,dynamic> toJson() => {
    'id' : id,
    'name' : name,
    'password' : password,
    'creatorID' : creatorID,
  };
}