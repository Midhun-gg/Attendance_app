// browse_class_page.dart
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'class_management_page.dart';
import '../services/api_service.dart';

class BrowseClassPage extends StatefulWidget {
  const BrowseClassPage({super.key});

  @override
  _BrowseClassPageState createState() => _BrowseClassPageState();
}

class _BrowseClassPageState extends State<BrowseClassPage> {
  List<Map<String, dynamic>> classes = [];
  String? selectedClass;
  String? selectedSection;
  bool isLoading = true;

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
          content: Text("⚠️ Error loading classes: ${e.toString()}"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Extract unique class_numbers
    final classNumbers = classes.map((c) => c["class_number"].toString()).toSet().toList()..sort();

    // Extract sections for the selected class
    final sections = selectedClass != null
        ? (classes
            .where((c) => c["class_number"].toString() == selectedClass)
            .map((c) => c["section"].toString())
            .toSet()
            .toList()
            .cast<String>()
          ..sort())
        : <String>[];

    return Scaffold(
      appBar: AppBar(
        title: Text('Browse Class'),
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
                    'Select Class to Browse',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[800],
                    ),
                  ),
                  SizedBox(height: 40),

                  // Class Dropdown
                  Text('Select Class:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  SizedBox(height: 10),
                  _buildDropdown(
                    selectedClass,
                    "Choose Class",
                    classNumbers,
                    (val) {
                      setState(() {
                        selectedClass = val;
                        selectedSection = null;
                      });
                    },
                  ),

                  SizedBox(height: 30),

                  // Section Dropdown
                  Text('Select Section:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  SizedBox(height: 10),
                  _buildDropdown(
                    selectedSection,
                    "Choose Section",
                    sections,
                    (val) {
                      setState(() {
                        selectedSection = val;
                      });
                    },
                  ),

                  SizedBox(height: 50),

                  // Continue Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: (selectedClass != null && selectedSection != null)
                          ? () {
                              // Find classId for selected class+section
                              final selected = classes.firstWhere(
                                (c) =>
                                    c["class_number"].toString() == selectedClass &&
                                    c["section"].toString() == selectedSection,
                              );

                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ClassManagementPage(
                                    classId: selected["id"],        // ✅ pass backend id
                                    className: selectedClass!,
                                    sectionName: selectedSection!,
                                  ),
                                ),
                              );
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        'Continue',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildDropdown(String? value, String hint, List<String> items, ValueChanged<String?> onChanged) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          hint: Text(hint),
          isExpanded: true,
          items: items.map((val) {
            return DropdownMenuItem<String>(
              value: val,
              child: Text(val),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
