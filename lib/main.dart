import 'package:flutter/material.dart';
import 'package:prepmaster/sqflite.dart';
import 'package:prepmaster/Course.dart';

void main() => runApp(const PrepMaster());

class PrepMaster extends StatelessWidget {
  const PrepMaster({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(primaryColor: Colors.purple[900]),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final DatabaseHelper dbHelper = DatabaseHelper();
  List<Course> courses = []; // List to hold courses

  @override
  void initState() {
    super.initState();
    _refreshCourseList(); // Fetch courses when the page loads
  }

  Future<void> _refreshCourseList() async {
    List<Course> list = await dbHelper.getCourses();
    setState(() {
      courses = list;
    });
  }

  Future<void> _addCourseDialog(BuildContext context) async {
    TextEditingController nameController = TextEditingController();

    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Course'),
          content: TextField(
            controller: nameController,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(labelText: 'Course Name'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                Course newCourse = Course(
                  cid: 0, // You may set a proper ID when saving to the database
                  courseName: nameController.text,
                  courseImageUrl: 'placeholder_url',
                  isCompleted: 0, // Default value for isCompleted (false)
                  isFocus: 0, // Default value for isFocus (false)
                );
                await dbHelper.insertCourse(newCourse);
                _refreshCourseList();
                Navigator.of(context).pop();
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PrepMaster'),
      ),
      body: ListView.builder(
        itemCount: courses.length,
        itemBuilder: (context, index) {
          return Card(
            clipBehavior: Clip.antiAlias,
            shadowColor: Colors.blueAccent,
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16)
            ),
            child: Stack(
              children: [
                Ink.image(
                  image: NetworkImage('https://images.unsplash.com/photo-1517059224940-d4af9eec41b7?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=MnwxfDB8MXxyYW5kb218MHx8Y29tcHV0ZXJ8fHx8fHwxNzAyMjE2MzI0&ixlib=rb-4.0.3&q=80&utm_campaign=api-credit&utm_medium=referral&utm_source=unsplash_source&w=1080',),
                  colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.5), BlendMode.srcOver),
                  height: 240,
                  child: InkWell(
                    onTap: (){},
                  ),
                  fit: BoxFit.cover,
                ),
                Positioned(
                  bottom: 2,
                  left: 5,
                  right: 5,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        courses[index].courseName,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 24,
                        ),
                      ),
                      ButtonBar(
                        alignment: MainAxisAlignment.center,
                        children: [
                          TextButton(
                            onPressed: () {},
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.white,
                              ),
                            child: Icon(Icons.delete,color: Colors.white),

                          ),
                          TextButton(
                            onPressed: () {},
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.white,
                            ),
                            child: Icon(Icons.add,color: Colors.white),
                          ),
                          TextButton(
                            onPressed: () {},
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.white,
                            ),
                            child: Icon(Icons.edit,color: Colors.white),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            )
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _addCourseDialog(context);
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
