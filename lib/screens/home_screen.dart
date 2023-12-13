import 'package:flutter/material.dart';
import 'package:td/entity/student_model.dart';
import 'package:td/screens/add_student_screen.dart';
import '../service/student_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  TextEditingController email = TextEditingController();
  TextEditingController name = TextEditingController();
  List<StudentModel> students = [];
  StudentModel? student;
  StudentService studentService = StudentService();
  List<String> classes = [
    "DSI 31",
    "DSI 32",
    "DSI 33",
    "DSI 34",
    "DSI 35",
    "DSI 36"
  ];
  String? selectedClass;

  @override
  void initState() {
    getData();
    super.initState();
  }

  // get the list of students
  Future<void> getData() async {
    List<StudentModel> fetchedStudents = await studentService.getStudents();
    setState(() {
      students = fetchedStudents;
    });
  }

  Future<void> getStudentById(int id) async {
    StudentModel? fetchedStudent = await studentService.getStudentById(id);
    setState(() {
      student = fetchedStudent;
    });
  }

  Future<void> editData(int id) async {
    await getStudentById(id);
    if (student != null) {
      name.text = student!.name!;
      email.text = student!.email!;
      selectedClass = student!.classe!;
      // ignore: use_build_context_synchronously
      showDialog(
          context: context,
          builder: (context) {
            return Dialog(
                backgroundColor: Colors.white,
                child: Container(
                    height: MediaQuery.sizeOf(context).height * .4,
                    padding: const EdgeInsets.all(15),
                    child: Column(
                      children: [
                        TextFormField(controller: name),
                        TextFormField(controller: email),
                        DropdownButtonFormField<String>(
                          value: selectedClass,
                          items: classes.map((String value) {
                            return DropdownMenuItem<String>(
                                value: value, child: Text(value));
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              selectedClass = value;
                            });
                          },
                          decoration:
                              const InputDecoration(labelText: 'Select Class'),
                        ),
                        ElevatedButton(
                            onPressed: () async {
                              bool success = await studentService.editStudent(
                                  id, name.text, email.text, selectedClass!);
                              if (success) {
                                int index =
                                    students.indexWhere((s) => s.id == id);
                                if (index != -1) {
                                  students[index] = StudentModel(
                                      id: id,
                                      name: name.text,
                                      email: email.text);
                                }
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text("Valid")));
                                setState(() {});
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text("Error")),
                                );
                              }
                            },
                            child: const Text("edit"))
                      ],
                    )));
          });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error getting student data")),
      );
    }
  }

  Future<void> deleteStudent(int id) async {
    bool success = await studentService.deleteStudent(id);

    if (success) {
      int index = students.indexWhere((s) => s.id == id);
      if (index != -1) {
        students.removeAt(index);
      }
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Valid")));
      setState(() {});
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Error")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: [
          //const SizedBox(height: 50),
          Container(
              margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
              child: const Text(
                "List of students",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              )),
          ListView.builder(
            itemCount: students.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) => ListTile(
              leading: CircleAvatar(
                  backgroundColor: Colors.blue,
                  child: Text("${students[index].id!}")),
              title: Text(students[index].name!),
              subtitle: Text(students[index].email!),
              trailing: SizedBox(
                width: 100,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    InkWell(
                        onTap: () => editData(students[index].id!),
                        child: const Icon(Icons.edit)),
                    InkWell(
                        onTap: () => deleteStudent(students[index].id!),
                        child: const Icon(Icons.delete)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => Navigator.push(context,
            MaterialPageRoute(builder: (context) => const AddStudent())),
      ),
    );
  }
}
