import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static const String dbName = 'students.db';
  static const String tableName = 'std';

  static Database? _database;

  Future<Database?> get database async {
    if (_database == null) {
      _database = await initDB();
    }
    return _database;
  }

  initDB() async {
    final path = join(await getDatabasesPath(), dbName);
    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $tableName (
        id INTEGER PRIMARY KEY,
        student_name TEXT,
        student_age INTEGER,
        student_section TEXT,
        student_gender TEXT
      )
    ''');
  }

  Future<int> insertStudent(Student student) async {
    final db = await database;
    return await db!.insert(tableName, student.toMap());
  }

  Future<List<Student>> getStudents() async {
    final db = await database;
    final students = await db!.query(tableName);
    return students.map((student) => Student.fromMap(student)).toList();
  }

  Future<int> updateStudent(Student student) async {
    final db = await database;
    return await db!.update(tableName, student.toMap(),
        where: 'id =?', whereArgs: [student.id]);
  }

  Future<int> deleteStudent(int id) async {
    final db = await database;
    return await db!.delete(tableName, where: 'id =?', whereArgs: [id]);
  }
}

class Student {
  int? id;
  String studentName;
  int studentAge;
  String studentSection;
  String studentGender;

  Student(
      {this.id,
      required this.studentName,
      required this.studentAge,
      required this.studentSection,
      required this.studentGender});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'student_name': studentName,
      'student_age': studentAge,
      'student_section': studentSection,
      'student_gender': studentGender,
    };
  }

  factory Student.fromMap(Map<String, dynamic> map) {
    return Student(
      id: map['id'],
      studentName: map['student_name'],
      studentAge: map['student_age'],
      studentSection: map['student_section'],
      studentGender: map['student_gender'],
    );
  }
}
