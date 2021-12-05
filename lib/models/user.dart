class User {
  User(
      {this.name,
      this.email,
      this.password,
      this.id,
      this.username,
      this.token,
      this.picture});

  int? id;
  String? name;
  String? email;
  String? username;
  String? password;
  String? token;
  String? picture;

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json["id"],
        name: json["name"],
        email: json["email"],
        username: json["username"],
        password: json["password"],
        token: json["token"],
        picture: json["picture"],
      );
}

User currentUser = User();
