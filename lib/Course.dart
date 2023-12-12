class Course {
  int cid;
  String courseName;
  int isCompleted;
  int isFocus;
  String courseImageUrl;

  Course({
    required this.cid,
    required this.courseName,
    required this.isCompleted,
    required this.isFocus,
    required this.courseImageUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'cid': cid,
      'courseName': courseName,
      'isCompleted': isCompleted,
      'isFocus': isFocus,
      'courseImageUrl': courseImageUrl,
    };
  }
}
