class User {
  User({
    this.name,
    this.email,
    this.password,
    this.id,
    this.username,
    this.token,
  });

  int? id;
  String? name;
  String? email;
  String? username;
  String? password;
  String? token;

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json["id"],
        name: json["name"],
        email: json["email"],
        username: json["username"],
        password: json["password"],
        token: json["token"],
      );
}

User currentUser = User();
