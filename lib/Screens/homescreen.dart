// Impports
import 'package:flutter/material.dart';
import 'package:flutter_test_input/Services/globals.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_test_input/Services/auth_services.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  // Variables used in file
  Map<String, dynamic>? user;
  List<dynamic> tasks = [];
  int? editingTaskId;
  DateTime? _startDate;
  DateTime? _endDate;
  final TextEditingController _taskNameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchUserDetails();
  }


  // Function to set the task ID being edited
  void setEditingTaskId(int? taskId) {
    setState(() {
      editingTaskId = taskId;
    });
  }


  // Function to retrieve user information
  fetchUserDetails() async {
    http.Response response = await AuthServices.fetchUserDetails();
    if (response.statusCode == 200) {
      setState(() {
        user = jsonDecode(response.body);
      });
      fetchUserTasks(user!['id']);
    } else {
      print("Failed to fetch user details");
    }
  }


  // Function to retrieve tasks of the user
  fetchUserTasks(int userId) async {
    http.Response response = await AuthServices.fetchUserTasks(userId);
    if (response.statusCode == 200) {
      setState(() {
        tasks = jsonDecode(response.body);
      });
    } else {
      setState(() {
        tasks = [];
      });
      print("Failed to fetch user tasks");
    }
  }


  // Function to delete a task
  deleteTask(int? taskId) async {
    if (taskId == null) {
      print("Task ID is null, cannot delete task");
      return;
    }

    http.Response response = await AuthServices.deleteTask(taskId);
    if (response.statusCode == 200) {
      setState(() {
        tasks.removeWhere((task) => task['id'] == taskId);
        fetchUserTasks(user!["id"]);
      });
    } else {
      print("Failed to delete task. Status code: ${response.statusCode}");
      print("Response body: ${response.body}");
    }

    fetchUserTasks(user!["id"]);
  }


  // Function to create a new task
  createTask(
      {required String taskName, String? description, DateTime? startDate, DateTime? endDate, required int userId,}) async {
    http.Response response = await AuthServices.createTask(
      taskName,
      description ?? "", // Default to empty string if description is null
      startDate, // Default to current date if startDate is null
      endDate, // Default to 7 days from now if endDate is null
      user!['id'],
    );
    if (response.statusCode == 200) {
      print("Task created successfully");
      // Fetch updated tasks
      await fetchUserTasks(user!['id']);
    }
    else {
      print("Failed to create task. Status code: ${response.statusCode}");
      print("Response body: ${response.body}");
    }
  }


  // Function to update an existing task
  updateTask(
      int taskId,
      String taskName,
      String? description,
      String? startDate,
      String? endDate,
      bool finished,
      int userId) async {
    bool newFinishedStatus = !finished;

    http.Response response = await AuthServices.updateTask(
      taskId,
      taskName,
      description ?? "",
      startDate,
      endDate,
      newFinishedStatus, // Pass the updated finished status
      userId,
    );

    if (response.statusCode == 200) {
      print("Task updated successfully");
      await fetchUserTasks(user!['id']); // Reload tasks after successful update
    } else {
      print("Failed to update task. Status code: ${response.statusCode}");
      print("Response body: ${response.body}");
    }
  }


  // Function to create an overlay to add a new task
  void showCreateTaskOverlay(BuildContext context) {
    _taskNameController.text = '';
    _descriptionController.text = '';
    _startDate = null; // Set initial start date to null
    _endDate = null;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: Text("Create New Task"),
              content: SizedBox(
                width: MediaQuery.of(context).size.width * 0.8,
                height: MediaQuery.of(context).size.height * 0.5,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: _taskNameController,
                      decoration: const InputDecoration(labelText: "Task Name"),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(labelText: "Description"),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            children: [
                              TextButton(
                                onPressed: () async {
                                  DateTime? pickedDate = await showDatePicker(
                                    context: context,
                                    initialDate: _startDate ?? DateTime.now(),
                                    firstDate: DateTime.now(),
                                    lastDate: _endDate ?? DateTime(2101),
                                  );
                                  if (pickedDate != null) {
                                    TimeOfDay? pickedTime = await showTimePicker(
                                      context: context,
                                      initialTime: TimeOfDay.now(),
                                    );
                                    if (pickedTime != null) {
                                      setState(() {
                                        _startDate = DateTime(
                                          pickedDate.year,
                                          pickedDate.month,
                                          pickedDate.day,
                                          pickedTime.hour,
                                          pickedTime.minute,
                                        );
                                        if (_endDate != null && _endDate!.isBefore(_startDate!)) {
                                          _endDate = _startDate!.add(Duration(days: 1));
                                        }
                                      });
                                    }
                                  }
                                },
                                child: Text(_startDate == null
                                    ? 'Select Start Date'
                                    : '${_startDate!.year}-${_startDate!.month.toString().padLeft(2, '0')}-${_startDate!.day.toString().padLeft(2, '0')} ${_startDate!.hour.toString().padLeft(2, '0')}:${_startDate!.minute.toString().padLeft(2, '0')}'),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            children: [
                              TextButton(
                                onPressed: () async {
                                  DateTime? pickedDate = await showDatePicker(
                                    context: context,
                                    initialDate: _endDate ?? (_startDate ?? DateTime.now()),
                                    firstDate: _startDate?.subtract(Duration(minutes: 15)) ?? DateTime.now().subtract(Duration(minutes: 15)),
                                    lastDate: DateTime(2101),
                                  );
                                  if (pickedDate != null) {
                                    TimeOfDay? pickedTime = await showTimePicker(
                                      context: context,
                                      initialTime: TimeOfDay.now(),
                                    );
                                    if (pickedTime != null) {
                                      setState(() {
                                        _endDate = DateTime(
                                          pickedDate.year,
                                          pickedDate.month,
                                          pickedDate.day,
                                          pickedTime.hour,
                                          pickedTime.minute,
                                        );
                                        if (_startDate!.isSameDay(_endDate!)) {
                                          if (_endDate!.isBefore(_startDate!.add(Duration(minutes: 15)))) {
                                            _endDate = _startDate!.add(Duration(minutes: 15));
                                          }
                                        }
                                        if (_endDate!.isBefore(_startDate!)) {
                                          _endDate = _startDate!.add(Duration(days: 1));
                                        }
                                      });
                                    }
                                  }
                                },
                                child: Text(_endDate == null
                                    ? 'Select End Date'
                                    : '${_endDate!.year}-${_endDate!.month.toString().padLeft(2, '0')}-${_endDate!.day.toString().padLeft(2, '0')} ${_endDate!.hour.toString().padLeft(2, '0')}:${_endDate!.minute.toString().padLeft(2, '0')}'),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text("Cancel"),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: const Color.fromRGBO(3, 200, 98, 100),
                    foregroundColor: const Color.fromRGBO(0, 0, 0, 100),
                  ),
                  onPressed: () async {
                    String taskName = _taskNameController.text.trim();
                    String description = _descriptionController.text.trim();
                    if (taskName.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(errorSnackBar(context, "Please enter a task name"));
                      return;
                    }
                    if (_endDate != null && _endDate!.isBefore(_startDate!)) {
                      ScaffoldMessenger.of(context).showSnackBar(errorSnackBar(context, "End date must be after start date"));
                      return;
                    }
                    await createTask(
                      taskName: taskName,
                      description: description.isEmpty ? null : description,
                      startDate: _startDate,
                      endDate: _endDate,
                      userId: user!['id'],
                    );
                    Navigator.of(context).pop();
                  },
                  child: const Text("Create"),
                ),
              ],
            );
          },
        );
      },
    );
  }


  // Function to create an overlay to edit an existing task
  void showEditTaskOverlay(BuildContext context, Map<String, dynamic> initialTask) {
    // Local controllers for this edit task overlay
    final TextEditingController taskNameController =
    TextEditingController(text: initialTask['name'] ?? '');
    final TextEditingController descriptionController =
    TextEditingController(text: initialTask['description'] ?? '');
    DateTime? startDate = initialTask['start_date'] != null
        ? DateTime.parse(initialTask['start_date'])
        : null;
    DateTime? endDate = initialTask['end_date'] != null
        ? DateTime.parse(initialTask['end_date'])
        : null;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: Text("Edit Task"),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: taskNameController,
                      autofocus: true, // Autofocus on the task name field
                      decoration: const InputDecoration(labelText: "Task Name"),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: descriptionController,
                      decoration: const InputDecoration(labelText: "Description"),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            children: [
                              TextButton(
                                onPressed: () async {
                                  DateTime? pickedDate = await showDatePicker(
                                    context: context,
                                    initialDate: startDate ?? DateTime.now(),
                                    firstDate: DateTime.now(),
                                    lastDate: endDate ?? DateTime(2101),
                                  );
                                  if (pickedDate != null) {
                                    TimeOfDay? pickedTime = await showTimePicker(
                                      context: context,
                                      initialTime: TimeOfDay.now(),
                                    );
                                    if (pickedTime != null) {
                                      setState(() {
                                        startDate = DateTime(
                                          pickedDate.year,
                                          pickedDate.month,
                                          pickedDate.day,
                                          pickedTime.hour,
                                          pickedTime.minute,
                                        );
                                        // Automatically adjust end date if it's before start date
                                        if (endDate != null &&
                                            endDate!.isBefore(startDate!)) {
                                          endDate =
                                              startDate!.add(Duration(days: 1));
                                        }
                                      });
                                    }
                                  }
                                },
                                child: Text(startDate == null
                                    ? 'Select Start Date'
                                    : '${startDate!.year}-${startDate!.month.toString().padLeft(2, '0')}-${startDate!.day.toString().padLeft(2, '0')} ${startDate!.hour.toString().padLeft(2, '0')}:${startDate!.minute.toString().padLeft(2, '0')}'),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            children: [
                              TextButton(
                                onPressed: () async {
                                  DateTime? pickedDate = await showDatePicker(
                                    context: context,
                                    initialDate: endDate ?? (startDate ?? DateTime.now()),
                                    firstDate: startDate?.subtract(Duration(minutes: 15)) ?? DateTime.now().subtract(Duration(minutes: 15)),
                                    lastDate: DateTime(2101),
                                  );
                                  if (pickedDate != null) {
                                    TimeOfDay? pickedTime = await showTimePicker(
                                      context: context,
                                      initialTime: TimeOfDay.now(),
                                    );
                                    if (pickedTime != null) {
                                      setState(() {
                                        endDate = DateTime(
                                          pickedDate.year,
                                          pickedDate.month,
                                          pickedDate.day,
                                          pickedTime.hour,
                                          pickedTime.minute,
                                        );
                                        // Adjust start date if end date is before start date
                                        if (startDate != null &&
                                            endDate!.isBefore(startDate!)) {
                                          startDate =
                                              endDate!.subtract(Duration(days: 1));
                                        }
                                      });
                                    }
                                  }
                                },
                                child: Text(endDate == null
                                    ? 'Select End Date'
                                    : '${endDate!.year}-${endDate!.month.toString().padLeft(2, '0')}-${endDate!.day.toString().padLeft(2, '0')} ${endDate!.hour.toString().padLeft(2, '0')}:${endDate!.minute.toString().padLeft(2, '0')}'),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text("Cancel"),
                  onPressed: () {
                    Navigator.of(context).pop();
                    setEditingTaskId(null); // Reset editingTaskId on cancel
                  },
                ),
                TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: const Color.fromRGBO(3, 200, 98, 100),
                    foregroundColor: const Color.fromRGBO(0, 0, 0, 100),
                  ),
                  onPressed: () async {
                    String taskName = taskNameController.text.trim();
                    String description = descriptionController.text.trim();
                    if (taskName.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                          errorSnackBar(context, "Please enter a task name"));
                      return;
                    }
                    if (endDate != null && endDate!.isBefore(startDate!)) {
                      ScaffoldMessenger.of(context).showSnackBar(
                          errorSnackBar(context, "End date must be after start date"));
                      return;
                    }
                    // Delete the existing task
                    await deleteTask(initialTask['task_id']);
                    // Create a new task with updated details
                    await createTask(
                      taskName: taskName,
                      description: description.isEmpty ? null : description,
                      startDate: startDate,
                      endDate: endDate,
                      userId: user!['id'],
                    );
                    Navigator.of(context).pop();
                    setEditingTaskId(null); // Reset editingTaskId after update
                  },
                  child: const Text("Update"),
                ),
              ],
            );
          },
        );
      },
    );
  }



  // Function to show overview and score
  void showTrophyOverlay(BuildContext context) {
    // Sample data for demonstration purposes
    int totalPlanned = tasks.length;
    int totalCompleted = tasks.where((task) => task['finished'] == 1).length;
    int score = totalCompleted * 10; // Example scoring logic

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Overview'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Total Planned: $totalPlanned'),
              Text('Total Completed: $totalCompleted'),
              Text('Score: $score'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Close'),
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
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text("Home Screen"),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 20.0),
            child: IconButton(
              icon: const Icon(Icons.emoji_events),
              onPressed: () {
                showTrophyOverlay(context);
              },
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => fetchUserTasks(user!["id"]),
        child: user != null
            ? Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: tasks.length,
                  itemBuilder: (context, index) {
                    bool isFinished = tasks[index]['finished'] == 1;

                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 10.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      elevation: 10.0,
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: ListTile(
                          title: Text(tasks[index]['name']),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(tasks[index]['description'] ?? ""),
                              Text(tasks[index]["start_date"] ?? ""),
                              Text(tasks[index]["end_date"] ?? ""),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [

                              // Give the correct string to update
                              GestureDetector(
                                onTap: () {
                                  bool isFinished = tasks[index]['finished'] == 1;
                                  int taskId = tasks[index]["task_id"];

                                  // Handle potential null values for start_date and end_date
                                  String? startDateString = tasks[index]["start_date"];
                                  String? endDateString = tasks[index]["end_date"];

                                  String? newStartDate;
                                  String? newEndDate;

                                  if (startDateString != null) {
                                    DateTime startDate = DateTime.parse(startDateString);
                                    newStartDate = "${startDate.year.toString()}-${startDate.month.toString().padLeft(2, '0')}-${startDate.day.toString().padLeft(2, '0')} ${startDate.hour.toString().padLeft(2, '0')}-${startDate.minute.toString().padLeft(2, '0')}";
                                  }

                                  if (endDateString != null) {
                                    DateTime endDate = DateTime.parse(endDateString);
                                    newEndDate = "${endDate.year.toString()}-${endDate.month.toString().padLeft(2, '0')}-${endDate.day.toString().padLeft(2, '0')} ${endDate.hour.toString().padLeft(2, '0')}-${endDate.minute.toString().padLeft(2, '0')}";
                                  }

                                  updateTask(
                                    taskId,
                                    tasks[index]['name'],
                                    tasks[index]['description'],
                                    newStartDate,
                                    newEndDate,
                                    isFinished,
                                    user!['id'],
                                  ); // Toggle the task status
                                },
                                child: Icon(
                                  isFinished ? Icons.check_circle : Icons.circle,
                                  color: isFinished ? Colors.green : Colors.red,
                                ),
                              ),

                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () {
                                  deleteTask(tasks[index]['task_id']);
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.edit, color: Colors.blue),
                                onPressed: () {
                                  if (tasks[index]['finished'] != 1) {
                                    showEditTaskOverlay(context, tasks[index]);
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        )
            : const Center(child: CircularProgressIndicator()),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showCreateTaskOverlay(context);
        },
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

}

// Extends the functionality of DateTime in order to add isSameDay
extension DateTimeExtension on DateTime {
  bool isSameDay(DateTime other) {
    return this.year == other.year && this.month == other.month && this.day == other.day;
  }
}