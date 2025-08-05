class User {
  final String userID;
  final String? userName;
  final bool isStudent;

  User({
    required this.userID,
    this.userName,
    this.isStudent = false,
  });

  factory User.fromMap(Map<String, dynamic> map, String documentId) {
    return User(
      userID: documentId,
      userName: map['userName'],
      isStudent: map['isStudent'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userName': userName,
      'isStudent': isStudent,
    };
  }

  User copyWith({
    String? userName,
    bool? isStudent,
  }) {
    return User(
      userID: userID,
      userName: userName ?? this.userName,
      isStudent: isStudent ?? this.isStudent,
    );
  }
}
