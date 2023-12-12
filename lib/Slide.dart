class Slide {
  int id;
  String name;
  String path;
  int isCompleted;
  int isFocus;

  Slide({
    required this.id,
    required this.name,
    required this.path,
    required this.isCompleted,
    required this.isFocus,
  });

  Map<String, dynamic> toMap() {
    return {
      'slideID': id,
      'slideName': name,
      'slidePath': path,
      'isCompleted': isCompleted,
      'isFocus': isFocus,
    };
  }
}
