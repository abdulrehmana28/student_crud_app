import 'package:flutter/material.dart';

import 'database_helper.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Student CRUD App',
      home: StudentListPage(),
    );
  }
}

class StudentListPage extends StatefulWidget {
  final Student? student;

  StudentListPage({this.student});

  @override
  _StudentListPageState createState() => _StudentListPageState();
}

class _StudentListPageState extends State<StudentListPage> {
  final _formKey = GlobalKey<FormState>();
  final _studentNameController = TextEditingController();
  final _studentAgeController = TextEditingController();
  final _studentSectionController = TextEditingController();
  final _studentGenderController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.student != null) {
      _studentNameController.text = widget.student!.studentName;
      _studentAgeController.text = widget.student!.studentAge.toString();
      _studentSectionController.text = widget.student!.studentSection;
      _studentGenderController.text = widget.student!.studentGender;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Student CRUD App'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _studentNameController,
                decoration: const InputDecoration(labelText: 'Student Name'),
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Please enter student name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _studentAgeController,
                decoration: const InputDecoration(labelText: 'Student Age'),
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Please enter student age';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _studentSectionController,
                decoration: const InputDecoration(labelText: 'Student Section'),
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Please enter student section';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _studentGenderController,
                decoration: const InputDecoration(labelText: 'Student Gender'),
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Please enter student gender';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState?.validate() ?? false) {
                    final student = Student(
                      id: widget.student?.id,
                      studentName: _studentNameController.text,
                      studentAge: int.parse(_studentAgeController.text),
                      studentSection: _studentSectionController.text,
                      studentGender: _studentGenderController.text,
                    );
                    if (widget.student == null) {
                      await DatabaseHelper().insertStudent(student);
                    } else {
                      await DatabaseHelper().updateStudent(student);
                    }
                    _studentNameController.clear();
                    _studentAgeController.clear();
                    _studentSectionController.clear();
                    _studentGenderController.clear();
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => StudentList()),
                    );
                  }
                },
                child: Text(
                    widget.student == null ? 'Add Student' : 'Update Student'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class StudentList extends StatefulWidget {
  @override
  _StudentListState createState() => _StudentListState();
}

class _StudentListState extends State<StudentList> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Student List'),
      ),
      body: FutureBuilder(
        future: DatabaseHelper().getStudents(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final students = snapshot.data as List<Student>;
            return ListView.builder(
              itemCount: students.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(students[index].studentName),
                  subtitle: Text('Age: ${students[index].studentAge}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => StudentListPage(
                                student: students[index],
                              ),
                            ),
                          ).then((_) {
                            setState(() {});
                          });
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () async {
                          await DatabaseHelper()
                              .deleteStudent(students[index].id!);
                          setState(() {});
                        },
                      ),
                    ],
                  ),
                );
              },
            );
          } else {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }
}
