class UserModel {
  String uid;
  String firstName;
  String lastName;
  String email;
  bool isAdmin;

  UserModel.empty()
      : uid = '',
        firstName = '',
        lastName = '',
        email = '',
        isAdmin = false;

  UserModel({
    required this.uid,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.isAdmin = false,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      email: json['email'],
      isAdmin: json['isAdmin'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'isAdmin': isAdmin,
    };
  }
}
