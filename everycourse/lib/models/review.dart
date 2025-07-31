class Review {
  final String userID;
  final String postID;
  final String userID2; // 코스 작성자 ID
  final String key;
  final int rating; // 10점 만점

  Review({
    required this.userID,
    required this.postID,
    required this.userID2,
    required this.key,
    this.rating = 10,
  });

  factory Review.fromMap(Map<String, dynamic> map) {
    return Review(
      userID: map['userID'] ?? '',
      postID: map['postID'] ?? '',
      userID2: map['userID2'] ?? '',
      key: map['key'] ?? '',
      rating: map['rating'] ?? 10,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userID': userID,
      'postID': postID,
      'userID2': userID2,
      'key': key,
      'rating': rating,
    };
  }

  // 복합 키 생성 (Firestore에서 사용)
  String get compositeKey => '${userID}_${postID}_${userID2}_$key';

  // 평점 유효성 검사
  bool get isValidRating => rating >= 1 && rating <= 10;
}
