import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:io';

class ApiService {
  static const String baseUrl = "http://10.0.2.2:8000"; 
  // ⚠️ Android emulator: use 10.0.2.2 instead of localhost
  // For physical device: use your computer's IP address
  // For web: use localhost:8000

  // ---------------- CLASSES ----------------
  static Future<Map<String, dynamic>> addClass(int classNumber, String section) async {
    try {
      var req = http.MultipartRequest('POST', Uri.parse("$baseUrl/add_class"));
      req.fields['class_number'] = classNumber.toString();
      req.fields['section'] = section;
      
      var res = await req.send();
      var responseBody = await res.stream.bytesToString();
      
      if (res.statusCode == 200) {
        return jsonDecode(responseBody);
      } else {
        throw Exception("Failed to add class: $responseBody");
      }
    } catch (e) {
      throw Exception("Error adding class: $e");
    }
  }

  static Future<List<dynamic>> listClasses() async {
    try {
      var res = await http.get(Uri.parse("$baseUrl/list_classes"));
      if (res.statusCode == 200) {
        return jsonDecode(res.body)["classes"];
      }
      throw Exception("Failed to load classes: ${res.body}");
    } catch (e) {
      throw Exception("Error loading classes: $e");
    }
  }

  static Future<Map<String, dynamic>> deleteClass(int classNumber, String section) async {
    try {
      var req = http.MultipartRequest('POST', Uri.parse("$baseUrl/delete_class"));
      req.fields['class_number'] = classNumber.toString();
      req.fields['section'] = section;
      
      var res = await req.send();
      var responseBody = await res.stream.bytesToString();
      
      if (res.statusCode == 200) {
        return jsonDecode(responseBody);
      } else {
        throw Exception("Failed to delete class: $responseBody");
      }
    } catch (e) {
      throw Exception("Error deleting class: $e");
    }
  }

  // ---------------- STUDENTS ----------------
  static Future<Map<String, dynamic>> addStudent(int classId, String pen, String name, File imageFile) async {
    try {
      var req = http.MultipartRequest('POST', Uri.parse("$baseUrl/add_student"));
      req.fields['class_id'] = classId.toString();
      req.fields['pen'] = pen;
      req.fields['name'] = name;
      req.files.add(await http.MultipartFile.fromPath('file', imageFile.path));
      
      var res = await req.send();
      var responseBody = await res.stream.bytesToString();
      
      if (res.statusCode == 200) {
        return jsonDecode(responseBody);
      } else {
        throw Exception("Failed to add student: $responseBody");
      }
    } catch (e) {
      throw Exception("Error adding student: $e");
    }
  }

  static Future<List<dynamic>> listStudents(int classId) async {
    try {
      var res = await http.get(Uri.parse("$baseUrl/list_students?class_id=$classId"));
      if (res.statusCode == 200) {
        return jsonDecode(res.body)["students"];
      }
      throw Exception("Failed to load students: ${res.body}");
    } catch (e) {
      throw Exception("Error loading students: $e");
    }
  }

  static Future<Map<String, dynamic>> deleteStudent(String pen) async {
    try {
      var req = http.MultipartRequest('POST', Uri.parse("$baseUrl/delete_student"));
      req.fields['pen'] = pen;
      
      var res = await req.send();
      var responseBody = await res.stream.bytesToString();
      
      if (res.statusCode == 200) {
        return jsonDecode(responseBody);
      } else {
        throw Exception("Failed to delete student: $responseBody");
      }
    } catch (e) {
      throw Exception("Error deleting student: $e");
    }
  }

  // ---------------- ATTENDANCE ----------------
  static Future<Map<String, dynamic>> uploadAttendance(int classId, String date, File imageFile) async {
    try {
      var req = http.MultipartRequest('POST', Uri.parse("$baseUrl/upload_attendance"));
      req.fields['class_id'] = classId.toString();
      req.fields['date'] = date;
      req.files.add(await http.MultipartFile.fromPath('file', imageFile.path));
      
      var res = await req.send();
      var responseBody = await res.stream.bytesToString();

      if (res.statusCode == 200) {
        return jsonDecode(responseBody);
      } else {
        throw Exception("Failed to upload attendance: $responseBody");
      }
    } catch (e) {
      throw Exception("Error uploading attendance: $e");
    }
  }

  static Future<Map<String, dynamic>> editAttendance(int classId, String pen, String date, int present) async {
    try {
      var req = http.MultipartRequest('POST', Uri.parse("$baseUrl/edit_attendance"));
      req.fields['class_id'] = classId.toString();
      req.fields['pen'] = pen;
      req.fields['date'] = date;
      req.fields['present'] = present.toString();
      
      var res = await req.send();
      var responseBody = await res.stream.bytesToString();
      
      if (res.statusCode == 200) {
        return jsonDecode(responseBody);
      } else {
        throw Exception("Failed to edit attendance: $responseBody");
      }
    } catch (e) {
      throw Exception("Error editing attendance: $e");
    }
  }

  static Future<List<dynamic>> viewAttendance(int classId, {String? date}) async {
    try {
      var url = "$baseUrl/view_attendance?class_id=$classId";
      if (date != null) url += "&date=$date";
      
      var res = await http.get(Uri.parse(url));
      if (res.statusCode == 200) {
        return jsonDecode(res.body)["attendance_records"];
      }
      throw Exception("Failed to load attendance: ${res.body}");
    } catch (e) {
      throw Exception("Error loading attendance: $e");
    }
  }
}