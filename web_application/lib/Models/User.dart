class User{
  int id;
  String Username;
  String Password;
  User(this.id,this.Username,this.Password);
  User.fromJson(Map<String,dynamic> json)
      :id = json['id'],
        Username = json['username'],
        Password = json['password'];
  Map<String,dynamic> toJson() => {
    'id' : id,
    'username' : Username,
    'password' : Password,
  };
}