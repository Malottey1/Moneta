class User {
  final int userId;
  final String firstName;
  final String lastName;
  final String email;
  final String gender;
  final String dateOfBirth;
  final String profilePicture;

  User({
    required this.userId,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.gender,
    required this.dateOfBirth,
    required this.profilePicture,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userId: json['user_id'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      email: json['email'],
      gender: json['gender'],
      dateOfBirth: json['date_of_birth'],
      profilePicture: json['profile_picture'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'gender': gender,
      'date_of_birth': dateOfBirth,
      'profile_picture': profilePicture,
    };
  }
}