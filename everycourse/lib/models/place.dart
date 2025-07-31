class Place {
  final String postID;
  final String key;
  final String name;
  final Duration time;
  final int viewCount;

  Place({
    required this.postID,
    required this.key,
    required this.name,
    required this.time,
    this.viewCount = 0,
  });

  factory Place.fromMap(Map<String, dynamic> map) {
    return Place(
      postID: map['postID'] ?? '',
      key: map['key'] ?? '',
      name: map['name'] ?? '',
      time: Duration(minutes: map['time'] ?? 0),
      viewCount: map['viewCount'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'postID': postID,
      'key': key,
      'name': name,
      'time': time.inMinutes,
      'viewCount': viewCount,
    };
  }

  // 조회수 증가
  Place incrementViewCount() {
    return Place(
      postID: postID,
      key: key,
      name: name,
      time: time,
      viewCount: viewCount + 1,
    );
  }
}
