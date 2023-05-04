import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:taskbuddy/providers/task_provider.dart';
import 'package:taskbuddy/views/Userpage.dart';
import 'package:taskbuddy/views/splashScreen.dart';
import 'package:taskbuddy/views/utils/dialog_box.dart';
import 'package:taskbuddy/views/utils/tasktile.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

import '../providers/auth_provider.dart';
import 'constants.dart';

List<String> assigne = [
  "All",
  "Self",
];

class TaskPage extends StatefulWidget {
  const TaskPage({super.key});

  @override
  State<TaskPage> createState() => _TaskPageState();
}

class _TaskPageState extends State<TaskPage> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  List<String> Priority = [
    "All Priority",
    "High",
    "Medium",
    "Low",
  ];

  var isLoading = false;
  String? selectedAssigne;
  String? selectedPriority;
  final auth = FirebaseAuth.instance;
  var isInit = true;
  CollectionReference? assigneeRef;
  CollectionReference taskRef = FirebaseFirestore.instance.collection("Users");

  @override
  void initState() {
    _nameController.text = "";
    _phoneController.text = "";
    super.initState();
  }

  @override
  void didChangeDependencies() {
    if (isInit) {
      getAssignee();
    }
    isInit = false;
    super.didChangeDependencies();
  }

  Future getAssignee() async {
    assigne.clear();
    assigne.add("All");
    assigne.add("Self");
    assigneeRef = await FirebaseFirestore.instance
        .collection("Users")
        .doc(auth.currentUser!.uid)
        .collection('Assignee')
        .get()
        .then((value) {
      if (value.size > 0) {
        value.docs.forEach((element) {
          assigne.add(element["Name"]);
        });
      }
      return null;
    });
    setState(() {
      isLoading = false;
    });
  }

  Future _reload() async {
    getAssignee();
  }

  Future logout() async{
    var authProvider = Provider.of<Auth>(context, listen: false);
    await authProvider.signOut().then((value) {
      Fluttertoast.showToast(
        msg: "Log Out Successfully !",
        toastLength: Toast.LENGTH_SHORT,
        timeInSecForIosWeb: 1,
        backgroundColor: kprimaryColor,
        textColor: Colors.white,
        fontSize: 16.0,
      );
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (ctx) => const SplashScreen()),
      );
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TaskProvider>(context);
    var taskList = provider.tasksFilter(3, "All");
    if (selectedAssigne == null) {
      if (selectedPriority == "High") {
        taskList = provider.tasksFilter(0, "All");
      } else if (selectedPriority == "Medium") {
        taskList = provider.tasksFilter(1, "All");
      } else if (selectedPriority == "Low") {
        taskList = provider.tasksFilter(2, "All");
      } else {
        taskList = provider.tasksFilter(3, "All");
      }
    } else {
      if (selectedAssigne == null) {
        if (selectedPriority == "High") {
          taskList = provider.tasksFilter(0, "All");
        } else if (selectedPriority == "Medium") {
          taskList = provider.tasksFilter(1, "All");
        } else if (selectedPriority == "Low") {
          taskList = provider.tasksFilter(2, "All");
        } else {
          taskList = provider.tasksFilter(3, "All");
        }
      } else {
        if (selectedPriority == "High") {
          taskList = provider.tasksFilter(0, selectedAssigne!);
        } else if (selectedPriority == "Medium") {
          taskList = provider.tasksFilter(1, selectedAssigne!);
        } else if (selectedPriority == "Low") {
          taskList = provider.tasksFilter(2, selectedAssigne!);
        } else {
          taskList = provider.tasksFilter(3, selectedAssigne!);
        }
      }
    }
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;

    return RefreshIndicator(
      onRefresh: _reload,
      child: SafeArea(
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          appBar: AppBar(
            title: const Text(
              'Gala Task',
              style: TextStyle(color: Colors.white),
            ),
            actions: [
              IconButton(
                icon: const Icon(
                  Icons.logout_outlined,
                  color: Colors.white,
                ),
                onPressed: () {
                  logout();
                },
              )
            ],
            centerTitle: true,
          ),
          floatingActionButton: SpeedDial(
            backgroundColor: kprimaryColor,
            overlayColor: Colors.black,
            overlayOpacity: 0.4,
            spacing: 12,
            animatedIcon: AnimatedIcons.add_event,
            children: [
              SpeedDialChild(
                  child: Icon(CupertinoIcons.doc_checkmark_fill,
                      color: kprimaryColor),
                  label: 'Add Task',
                  onTap: () {
                    showDialog(
                        context: context,
                        builder: (context) => AddTaskAlertDialog(
                              assignee: assigne,
                            ));
                  }),
              SpeedDialChild(
                  child:
                      Icon(CupertinoIcons.person_add_solid, color: kprimaryColor),
                  label: 'Add User',
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => UsersScreen()));
                  }),
            ],
          ),
          body: Column(
            children: [
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      width: 200,
                      height: 50.0,
                      decoration: kInputBox,
                      child: DropdownButton<String>(
                        underline: const SizedBox(),
                        hint: const FittedBox(
                            fit: BoxFit.scaleDown, child: Text("All Assignee")),
                        value: selectedAssigne,
                        items: assigne.map((category) {
                          return DropdownMenuItem<String>(
                            value: category,
                            child: SizedBox(
                                height: 30,
                                width: 150,
                                child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text(category))),
                          );
                        }).toList(),
                        onChanged: (newValue) {
                          setState(() {
                            selectedAssigne = newValue!;
                          });
                        },
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      height: 50.0,
                      decoration: kInputBox,
                      child: DropdownButton<String>(
                        underline: const SizedBox(),
                        hint: const Text('All Priority'),
                        value: selectedPriority,
                        items: Priority.map((category) {
                          return DropdownMenuItem<String>(
                            value: category,
                            child: Text(category),
                          );
                        }).toList(),
                        onChanged: (newValue) {
                          setState(() {
                            selectedPriority = newValue!;
                          });
                        },
                      ),
                    ),
                  ),
                ],
              ),
              taskList.isEmpty
                  ? const Padding(
                      padding: EdgeInsets.only(top: 50.0),
                      child: Center(
                        child: Text(
                          "No Current Task Created !",
                          style: TextStyle(fontSize: 25),
                        ),
                      ),
                    )
                  : SizedBox(
                    width: double.infinity,
                    height: 400,
                    child: ListView.separated(
                      scrollDirection: Axis.vertical,
                      padding: const EdgeInsets.all(16),
                      separatorBuilder: (context, index) =>
                          Container(height: 8),
                      itemCount: taskList.length,
                      itemBuilder: (context, index) {
                        final task = taskList[index];
                        return TaskTile(task: task);
                      },
                    ),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}
