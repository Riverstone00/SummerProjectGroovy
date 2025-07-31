class CourseImage {
  final String imageURL;
  final String postID;
  final String key;
  final String userID;

  CourseImage({
    required this.imageURL,
    required this.postID,
    required this.key,
    required this.userID,
  });

  factory CourseImage.fromMap(Map<String, dynamic> map) {
    return CourseImage(
      imageURL: map['imageURL'] ?? '',
      postID: map['postID'] ?? '',
      key: map['key'] ?? '',
      userID: map['userID'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'imageURL': imageURL,
      'postID': postID,
      'key': key,
      'userID': userID,
    };
  }

  // 복합 키 생성 (Firestore에서 사용)
  String get compositeKey => '${imageURL}_${postID}_${key}_$userID';
}
