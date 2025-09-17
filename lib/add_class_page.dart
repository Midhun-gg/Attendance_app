import 'package:flutter/material.dart';
import '../models/school_class.dart';
import '../services/api_service.dart';  // <-- Import API service
import '../data/global_data.dart';

class AddClassPage extends StatefulWidget {
  const AddClassPage({super.key});

  @override
  _AddClassPageState createState() => _AddClassPageState();
}

class _AddClassPageState extends State<AddClassPage> {
  String? selectedClass;
  String? selectedSection;
  bool isLoading = false;

  final List<String> classes = [
    '1', '2', '3', '4', '5', '6', '7', '8', '9', '10'
  ];

  final List<String> sections = ['A', 'B', 'C'];

  Future<void> addClass() async {
    if (selectedClass != null && selectedSection != null) {
      setState(() => isLoading = true);

      try {
        // Call backend API
        bool success = await ApiService.addClass(
          int.parse(selectedClass!), 
          selectedSection!,
        );

        if (success) {
          // Refresh global class list from backend
          var serverClasses = await ApiService.listClasses();
          addedClasses = serverClasses
              .map((c) => SchoolClass(
                    className: c["class_number"].toString(),
                    sectionName: c["section"],
                  ))
              .toList();

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Class $selectedClass-$selectedSection added successfully!',
              ),
              backgroundColor: Colors.green,
            ),
          );

          setState(() {
            selectedClass = null;
            selectedSection = null;
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Failed to add class"),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error: $e"),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Class'),
        backgroundColor: Colors.green[600],
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Create New Class',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.green[800],
              ),
            ),
            const SizedBox(height: 40),

            // Class Dropdown
            const Text(
              'Select Class:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: selectedClass,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Choose Class",
              ),
              items: classes.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text('Class $value'),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() => selectedClass = newValue);
              },
            ),

            const SizedBox(height: 30),

            // Section Dropdown
            const Text(
              'Select Section:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: selectedSection,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Choose Section",
              ),
              items: sections.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text('Section $value'),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() => selectedSection = newValue);
              },
            ),

            const SizedBox(height: 50),

            // Add Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: (selectedClass != null && selectedSection != null && !isLoading)
                    ? addClass
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Add Class',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
