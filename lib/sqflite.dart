import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:prepmaster/Course.dart';
import 'package:prepmaster/Slide.dart';

class DatabaseHelper {
  static Database? _database;
  static const String dbName = 'prepmaster.db';

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await initDatabase();
    return _database!;
  }

  Future<Database> initDatabase() async {
    final path = await getDatabasesPath();
    final dbPath = join(path, dbName);

    return await openDatabase(dbPath, version: 1, onCreate: (db, version) async {
      await db.execute('''
      CREATE TABLE Courses (
        cid INTEGER PRIMARY KEY,
        courseName TEXT,
        isCompleted INTEGER DEFAULT 0,
        isFocus INTEGER DEFAULT 0,
        courseImageUrl TEXT
      )
    ''');

      // Adding Slides table creation
      await db.execute('''
      CREATE TABLE Slides (
        slideID INTEGER PRIMARY KEY,
        slideName TEXT,
        slideType TEXT,
        slidePath TEXT,
        isCompleted INTEGER DEFAULT 0,
        isFocus INTEGER DEFAULT 0
      )
    ''');

      // Adding CourseSlides table creation
      await db.execute('''
      CREATE TABLE CourseSlides (
        courseID INTEGER,
        slideID INTEGER,
        FOREIGN KEY (courseID) REFERENCES Courses(cid),
        FOREIGN KEY (slideID) REFERENCES Slides(slideID),
        PRIMARY KEY (courseID, slideID)
      )
    ''');
    });
  }


  Future<void> insertCourse(Course course) async {
    final db = await database;
    await db.insert('Courses', course.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Course>> getCourses() async {
    final db = await database;
    final List<Map<String, dynamic>> courses = await db.query('Courses');
    return List.generate(courses.length, (index) {
      return Course(
        cid: courses[index]['cid'],
        courseName: courses[index]['courseName'],
        isCompleted: courses[index]['isCompleted'],
        isFocus: courses[index]['isFocus'],
        courseImageUrl: courses[index]['courseImageUrl'],
      );
    });
  }

  Future<void> updateCourse(Course course) async {
    final db = await database;
    await db.update(
      'Courses',
      course.toMap(),
      where: 'cid = ?',
      whereArgs: [course.cid],
    );
  }

  Future<void> deleteCourse(int courseId) async {
    final db = await database;

    // Fetch all slide IDs associated with the given courseId
    final List<Map<String, dynamic>> slideIds = await db.query(
      'CourseSlides',
      where: 'courseID = ?',
      whereArgs: [courseId],
    );

    // Delete slides from Slides table based on the slide IDs associated with the courseId
    for (final slideIdMap in slideIds) {
      final slideId = slideIdMap['slideID'] as int;

      // Delete slides from Slides table
      await db.delete(
        'Slides',
        where: 'slideID = ?',
        whereArgs: [slideId],
      );
    }

    // Delete entries from CourseSlides table based on the courseId
    await db.delete(
      'CourseSlides',
      where: 'courseID = ?',
      whereArgs: [courseId],
    );

    // Finally, delete the course from the Courses table
    await db.delete(
      'Courses',
      where: 'cid = ?',
      whereArgs: [courseId],
    );
  }

  // Adding CRUD operations for Slides
  Future<void> insertSlide(Slide slide, int courseId) async {
    final db = await database;
    final slideId = await db.insert('Slides', slide.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);

    // Insert into CourseSlides table
    final values = <String, dynamic>{
      'courseID': courseId,
      'slideID': slideId,
    };
    await db.insert('CourseSlides', values,
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Slide>> getSlides() async {
    final db = await database;
    final List<Map<String, dynamic>> slides = await db.query('Slides');
    return List.generate(slides.length, (index) {
      return Slide(
        id: slides[index]['slideID'],
        name: slides[index]['slideName'],
        path: slides[index]['slidePath'],
        isCompleted: slides[index]['isCompleted'],
        isFocus: slides[index]['isFocus'],
      );
    });
  }

  Future<void> deleteSlide(int slideId, int courseId) async {
    final db = await database;

    // Delete from CourseSlides table based on slideID only
    await db.delete(
      'CourseSlides',
      where: 'slideID = ?',
      whereArgs: [slideId],
    );

    // Delete the slide itself from the Slides table
    await db.delete(
      'Slides',
      where: 'slideID = ?',
      whereArgs: [slideId],
    );
  }

  // Adding CRUD operations for CourseSlides
  Future<List<Slide>> getSlidesForCourse(int courseId) async {
    final db = await database;
    final List<Map<String, dynamic>> slides = await db.rawQuery(
        'SELECT s.* FROM Slides s INNER JOIN CourseSlides cs ON s.slideID = cs.slideID WHERE cs.courseID = ?',
        [courseId.toString()]);
    return List.generate(slides.length, (index) {
      return Slide(
        id: slides[index]['slideID'],
        name: slides[index]['slideName'],
        path: slides[index]['slidePath'],
        isCompleted: slides[index]['isCompleted'],
        isFocus: slides[index]['isFocus'],
      );
    });
  }
}
