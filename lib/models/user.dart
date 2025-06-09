class User {
  final String email;
  final String username;

  User({required this.email, required this.username});

  factory User.fromJson(Map<String, dynamic> json) => 
    User(username: json['username'] as String, email: json['email'] as String);

    Map<String, dynamic> toJson() => {'email': email, 'username': username};
  }

