class Hashtag {
  final String tagName;
  final String postID;
  final String key;

  Hashtag({
    required this.tagName,
    required this.postID,
    required this.key,
  });

  factory Hashtag.fromMap(Map<String, dynamic> map) {
    return Hashtag(
      tagName: map['tagName'] ?? '',
      postID: map['postID'] ?? '',
      key: map['key'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'tagName': tagName,
      'postID': postID,
      'key': key,
    };
  }

  // 복합 키 생성 (Firestore에서 사용)
  String get compositeKey => '${tagName}_${postID}_$key';

  // 태그명 정규화 (# 제거, 소문자 변환)
  String get normalizedTagName {
    String normalized = tagName.toLowerCase();
    if (normalized.startsWith('#')) {
      normalized = normalized.substring(1);
    }
    return normalized;
  }
}
