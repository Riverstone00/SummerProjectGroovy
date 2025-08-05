class Like {
  final String userID;
  final String postID;
  final String key;

  Like({
    required this.userID,
    required this.postID,
    required this.key,
  });

  factory Like.fromMap(Map<String, dynamic> map) {
    return Like(
      userID: map['userID'] ?? '',
      postID: map['postID'] ?? '',
      key: map['key'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userID': userID,
      'postID': postID,
      'key': key,
    };
  }

  // 복합 키 생성 (Firestore에서 사용)
  String get compositeKey => '${userID}_${postID}_$key';
}
