// class_management_page.dart

import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'add_student_page.dart';
import '../services/api_service.dart';

class ClassManagementPage extends StatefulWidget {
  final int classId;
  final String className;
  final String sectionName;

  const ClassManagementPage({
    super.key,
    required this.classId,
    required this.className,
    required this.sectionName,
  });

  @override
  _ClassManagementPageState createState() => _ClassManagementPageState();
}

class _ClassManagementPageState extends State<ClassManagementPage> {
  List<dynamic> students = [];
  List<dynamic> attendanceRecords = [];
  bool isLoading = false;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadStudents();
  }

  Future<void> _loadStudents() async {
    setState(() => isLoading = true);
    try {
      final studentList = await ApiService.listStudents(widget.classId);
      setState(() {
        students = studentList;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error loading students: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _uploadAttendance() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1800,
        maxHeight: 1800,
        imageQuality: 80,
      );

      if (image != null) {
        final now = DateTime.now();
        final dateStr = DateFormat('yyyy-MM-dd').format(now);
        
        setState(() => isLoading = true);
        
        final response = await ApiService.uploadAttendance(
          widget.classId,
          dateStr,
          File(image.path),
        );
        
        setState(() => isLoading = false);
        
        final presentPens = response['present_pens'] as List<dynamic>;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Attendance uploaded! ${presentPens.length} students marked present"),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error uploading attendance: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _viewAttendance() async {
    try {
      setState(() => isLoading = true);
      final records = await ApiService.viewAttendance(widget.classId);
      setState(() {
        attendanceRecords = records;
        isLoading = false;
      });
      
      // Show attendance records in a dialog
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Attendance Records'),
          content: SizedBox(
            width: double.maxFinite,
            height: 400,
            child: ListView.builder(
              itemCount: records.length,
              itemBuilder: (context, index) {
                final record = records[index];
                return ListTile(
                  title: Text(record['name'] ?? 'Unknown'),
                  subtitle: Text('PEN: ${record['pen']} - ${record['date']}'),
                  trailing: Icon(
                    record['present'] ? Icons.check_circle : Icons.cancel,
                    color: record['present'] ? Colors.green : Colors.red,
                  ),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Close'),
            ),
          ],
        ),
      );
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error loading attendance: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _deleteStudent(String pen) async {
    try {
      await ApiService.deleteStudent(pen);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Student deleted successfully"),
          backgroundColor: Colors.green,
        ),
      );
      _loadStudents(); // Refresh the list
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error deleting student: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Class ${widget.className} - Section ${widget.sectionName}'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Class Management',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[800],
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Class ${widget.className} - Section ${widget.sectionName}',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 40),

                  // Upload Attendance Button
                  _buildManagementButton(
                    context,
                    'Upload Attendance',
                    Icons.upload_file,
                    Colors.blue,
                    _uploadAttendance,
                  ),

                  SizedBox(height: 20),

                  // View Attendance Button
                  _buildManagementButton(
                    context,
                    'View Attendance',
                    Icons.visibility,
                    Colors.blue,
                    _viewAttendance,
                  ),

                  SizedBox(height: 20),

                  // Add Student Button
                  _buildManagementButton(
                    context,
                    'Add Student',
                    Icons.person_add,
                    Colors.blue,
                    () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddStudentPage(
                            classId: widget.classId,
                            className: widget.className,
                            sectionName: widget.sectionName,
                          ),
                        ),
                      );
                      if (result == true) {
                        _loadStudents(); // Refresh the list
                      }
                    },
                  ),

                  SizedBox(height: 30),

                  // Students List
                  Text(
                    'Students (${students.length})',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[800],
                    ),
                  ),
                  SizedBox(height: 10),
                  
                  Expanded(
                    child: students.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.people_outline,
                                  size: 80,
                                  color: Colors.grey[400],
                                ),
                                SizedBox(height: 20),
                                Text(
                                  'No students added yet',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            itemCount: students.length,
                            itemBuilder: (context, index) {
                              final student = students[index];
                              return Card(
                                margin: EdgeInsets.symmetric(vertical: 4),
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundImage: student['photo'] != null
                                        ? NetworkImage(student['photo'])
                                        : null,
                                    child: student['photo'] == null
                                        ? Icon(Icons.person)
                                        : null,
                                  ),
                                  title: Text(student['name'] ?? 'Unknown'),
                                  subtitle: Text('PEN: ${student['pen']}'),
                                  trailing: IconButton(
                                    icon: Icon(Icons.delete, color: Colors.red),
                                    onPressed: () => _showDeleteDialog(student['pen']),
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
    );
  }

  void _showDeleteDialog(String pen) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Student'),
        content: Text('Are you sure you want to delete this student?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteStudent(pen);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Delete'),
          ),
        ],
      ),
    );
  }

  Widget _buildManagementButton(
      BuildContext context,
      String title,
      IconData icon,
      Color color,
      VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 24),
        label: Text(
          title,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
