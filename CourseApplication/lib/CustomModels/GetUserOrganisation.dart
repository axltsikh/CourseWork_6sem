class GetUserOrganisation{
  int id;
  String name;
  String password;
  int creatorID;
  int userID;
  GetUserOrganisation(this.id,this.name,this.password,this.creatorID,this.userID);
  GetUserOrganisation.fromJson(Map<String,dynamic> json)
      :id = json['id'],
       name = json['name'],
       password = json['password'],
       creatorID = json['creatorID'],
       userID = json['userID'];
  Map<String,dynamic> toJson() => {
      'id' : id,
      'name' : name,
      'password' : password,
      'creatorID' : creatorID,
      'userID' : userID
  };
}