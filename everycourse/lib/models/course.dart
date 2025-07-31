import 'place.dart';

class Course {
  final String postID;
  final String key;
  final String userID;
  final String title;
  final int likes;
  final Duration timeEstimated;
  final List<Place> placeOrder;

  Course({
    required this.postID,
    required this.key,
    required this.userID,
    required this.title,
    this.likes = 0,
    required this.timeEstimated,
    required this.placeOrder,
  });

  factory Course.fromMap(Map<String, dynamic> map, String documentId) {
    return Course(
      postID: documentId,
      key: map['key'] ?? '',
      userID: map['userID'] ?? '',
      title: map['title'] ?? '',
      likes: map['likes'] ?? 0,
      timeEstimated: Duration(minutes: map['timeEstimated'] ?? 0),
      placeOrder: (map['placeOrder'] as List<dynamic>?)
          ?.map((place) => Place.fromMap(place))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'key': key,
      'userID': userID,
      'title': title,
      'likes': likes,
      'timeEstimated': timeEstimated.inMinutes,
      'placeOrder': placeOrder.map((place) => place.toMap()).toList(),
    };
  }

  // 좋아요 수 증가
  Course incrementLikes() {
    return Course(
      postID: postID,
      key: key,
      userID: userID,
      title: title,
      likes: likes + 1,
      timeEstimated: timeEstimated,
      placeOrder: placeOrder,
    );
  }

  // 좋아요 수 감소
  Course decrementLikes() {
    return Course(
      postID: postID,
      key: key,
      userID: userID,
      title: title,
      likes: likes > 0 ? likes - 1 : 0,
      timeEstimated: timeEstimated,
      placeOrder: placeOrder,
    );
  }
}
