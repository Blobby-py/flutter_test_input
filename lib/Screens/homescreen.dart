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
  DateTime? _startDate;
  DateTime? _endDate;
  final TextEditingController _taskNameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchUserDetails();
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
  createTask({required String taskName, String? description, DateTime? startDate, DateTime? endDate, required int userId,}) async {

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


  // Function to create an overlay to add a new task
  void showCreateTaskOverlay(BuildContext context, {Map<String, dynamic>? initialTask}) {
    // Initialize text controllers and date variables
    _taskNameController.text = initialTask != null ? initialTask['name'] ?? '' : '';
    _descriptionController.text = initialTask != null ? initialTask['description'] ?? '' : '';
    _startDate = initialTask != null && initialTask['start_date'] != null ? DateTime.parse(initialTask['start_date']) : null;
    _endDate = initialTask != null && initialTask['end_date'] != null ? DateTime.parse(initialTask['end_date']) : null;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: Text(initialTask != null ? "Edit Task" : "Create New Task"),
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
                                        // Validate end date
                                        if (_endDate != null && _endDate!.isBefore(_startDate!)) {
                                          _endDate = _startDate!.add(Duration(days: 1)); // Set end date to 1 day after start date
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
                                    initialDate: _endDate ?? (_startDate ?? DateTime.now()), // Default to start date or current date
                                    firstDate: _startDate?.subtract(Duration(minutes: 15)) ?? DateTime.now().subtract(Duration(minutes: 15)), // Minimum end date is 15 minutes before start date or now - 15 minutes if start date not set
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

                                        // Adjust end time to be at least 15 minutes after start time if they are on the same day
                                        if (_startDate!.isSameDay(_endDate!)) {
                                          if (_endDate!.isBefore(_startDate!.add(Duration(minutes: 15)))) {
                                            _endDate = _startDate!.add(Duration(minutes: 15));
                                          }
                                        }

                                        // Validate end date
                                        if (_endDate!.isBefore(_startDate!)) {
                                          _endDate = _startDate!.add(Duration(days: 1)); // Set end date to 1 day after start date
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

                    if (initialTask != null) {
                      // Handle update task logic
                      print("EDIT TASK");
                    } else {
                      // Handle create task logic
                      await createTask(
                        taskName: taskName,
                        description: description.isEmpty ? null : description,
                        startDate: _startDate,
                        endDate: _endDate,
                        userId: user!['id'],
                      );
                    }
                    Navigator.of(context).pop(); // Close the dialog after task creation/editing
                  },
                  child: Text(initialTask != null ? "Update" : "Create"),
                ),
              ],
            );
          },
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home Screen"),
      ),
      // Refresh the page when user swipes down
      body: RefreshIndicator(
        onRefresh: () => fetchUserTasks(user!["id"]), // Reload tasks when refreshing
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
                    return ListTile(
                      title: Text(tasks[index]['name']),  // Task name displayed as title
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(tasks[index]['description'] ?? ""), // Description (handle null with ??)
                          Text(tasks[index]["start_date"] ?? ""), // Start Date (handle null with ??)
                          Text(tasks[index]["end_date"] ?? ""), // End Date (handle null with ??)
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Icon green or red based on if the task has been completed or not
                          Icon(
                            isFinished ? Icons.check_circle : Icons.circle,
                            color: isFinished ? Colors.green : Colors.red,
                          ),
                          // Trashcan icon to delete a task
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              deleteTask(tasks[index]['task_id']);
                            },
                          ),
                          // Edit button to edit a task
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () {
                              showCreateTaskOverlay(context, initialTask: tasks[index]);
                            },
                          ),
                        ],
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

      // Add a new task icon
      floatingActionButton: GestureDetector(
          onTap: () => showCreateTaskOverlay(context),
          child: Container(
            width: 65,  // Width of add task button
            height: 65,  // Height of add task button
            decoration: BoxDecoration (
              shape: BoxShape.circle,
              color: Colors.black.withOpacity(0.657),
            ),

            // Plus icon in center of cirlce
            child: const Icon(
              Icons.add,
              color: Colors.white,
              size: 36,
            ),
          ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,

    );
  }
}

// Extends the functionality of DateTime in order to add isSameDay
extension DateTimeExtension on DateTime {
  bool isSameDay(DateTime other) {
    return this.year == other.year && this.month == other.month && this.day == other.day;
  }
}

