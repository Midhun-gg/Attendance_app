// delete_class_page.dart
import 'package:flutter/material.dart';
import '../services/api_service.dart';

class DeleteClassPage extends StatefulWidget {
  const DeleteClassPage({super.key});

  @override
  _DeleteClassPageState createState() => _DeleteClassPageState();
}

class _DeleteClassPageState extends State<DeleteClassPage> {
  bool isLoading = true;
  List<Map<String, dynamic>> classes = [];

  @override
  void initState() {
    super.initState();
    _fetchClasses();
  }

  Future<void> _fetchClasses() async {
    try {
      final serverClasses = await ApiService.listClasses();
      setState(() {
        classes = List<Map<String, dynamic>>.from(serverClasses);
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading classes: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _deleteClassFromAPI(Map<String, dynamic> cls) async {
    setState(() => isLoading = true);
    try {
      final response = await ApiService.deleteClass(
        int.parse(cls["class_number"].toString()),
        cls["section"].toString(),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response["message"] ?? 'Class deleted successfully!'),
          backgroundColor: Colors.red,
          action: SnackBarAction(
            label: 'UNDO',
            textColor: Colors.white,
            onPressed: () async {
              try {
                await ApiService.addClass(
                  int.parse(cls["class_number"].toString()),
                  cls["section"].toString(),
                );
                await _fetchClasses();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Class restored successfully!'),
                    backgroundColor: Colors.green,
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Failed to restore class: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error deleting class: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      await _fetchClasses();
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text('Delete Class'),
        backgroundColor: Colors.red[600],
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
                    'Delete Classes',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.red[800],
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Select a class to delete',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 30),
                  Expanded(
                    child: classes.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.school_outlined,
                                  size: 80,
                                  color: Colors.grey[400],
                                ),
                                SizedBox(height: 20),
                                Text(
                                  'No classes available',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            itemCount: classes.length,
                            itemBuilder: (context, index) {
                              return _buildClassCard(classes[index]);
                            },
                          ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildClassCard(Map<String, dynamic> cls) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8),
      elevation: 3,
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: Colors.blue[100],
            borderRadius: BorderRadius.circular(25),
          ),
          child: Icon(
            Icons.school,
            color: Colors.blue[600],
            size: 30,
          ),
        ),
        title: Text(
          'Class ${cls["class_number"]} - Section ${cls["section"]}',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          'Tap delete to remove this class',
          style: TextStyle(
            color: Colors.grey[600],
          ),
        ),
        trailing: Container(
          decoration: BoxDecoration(
            color: Colors.red,
            borderRadius: BorderRadius.circular(8),
          ),
          child: IconButton(
            icon: Icon(Icons.delete, color: Colors.white),
            onPressed: () => _showDeleteDialog(cls),
          ),
        ),
      ),
    );
  }

  void _showDeleteDialog(Map<String, dynamic> cls) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Delete Class',
            style: TextStyle(color: Colors.red[800]),
          ),
          content: Text(
            'Are you sure you want to delete Class ${cls["class_number"]} - Section ${cls["section"]}?\n\nThis action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Cancel',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _deleteClassFromAPI(cls);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}
