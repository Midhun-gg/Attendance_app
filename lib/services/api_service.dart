import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:io';

class ApiService {
  static const String baseUrl = "http://10.0.2.2:8000"; 
  // ⚠️ Android emulator: use 10.0.2.2 instead of localhost

  // ---------------- CLASSES ----------------
  static Future<bool> addClass(int classNumber, String section) async {
    var req = http.MultipartRequest('POST', Uri.parse("$baseUrl/add_class"));
    req.fields['class_number'] = classNumber.toString();
    req.fields['section'] = section;
    var res = await req.send();
    return res.statusCode == 200;
  }

  static Future<List<dynamic>> listClasses() async {
    var res = await http.get(Uri.parse("$baseUrl/list_classes"));
    if (res.statusCode == 200) {
      return jsonDecode(res.body)["classes"];
    }
    throw Exception("Failed to load classes");
  }

  static Future<bool> deleteClass(int classNumber, String section) async {
    var req = http.MultipartRequest('POST', Uri.parse("$baseUrl/delete_class"));
    req.fields['class_number'] = classNumber.toString();
    req.fields['section'] = section;
    var res = await req.send();
    return res.statusCode == 200;
  }

  // ---------------- STUDENTS ----------------
  static Future<bool> addStudent(int classId, String pen, String name, File imageFile) async {
    var req = http.MultipartRequest('POST', Uri.parse("$baseUrl/add_student"));
    req.fields['class_id'] = classId.toString();
    req.fields['pen'] = pen;
    req.fields['name'] = name;
    req.files.add(await http.MultipartFile.fromPath('file', imageFile.path));
    var res = await req.send();
    return res.statusCode == 200;
  }

  static Future<List<dynamic>> listStudents(int classId) async {
    var res = await http.get(Uri.parse("$baseUrl/list_students?class_id=$classId"));
    if (res.statusCode == 200) {
      return jsonDecode(res.body)["students"];
    }
    throw Exception("Failed to load students");
  }

  static Future<bool> deleteStudent(String pen) async {
    var req = http.MultipartRequest('POST', Uri.parse("$baseUrl/delete_student"));
    req.fields['pen'] = pen;
    var res = await req.send();
    return res.statusCode == 200;
  }

  // ---------------- ATTENDANCE ----------------
  static Future<List<String>> uploadAttendance(int classId, String date, File imageFile) async {
    var req = http.MultipartRequest('POST', Uri.parse("$baseUrl/upload_attendance"));
    req.fields['class_id'] = classId.toString();
    req.fields['date'] = date;
    req.files.add(await http.MultipartFile.fromPath('file', imageFile.path));
    var res = await http.Response.fromStream(await req.send());

    if (res.statusCode == 200) {
      return List<String>.from(jsonDecode(res.body)["present_pens"]);
    }
    throw Exception("Failed to upload attendance");
  }

  static Future<bool> editAttendance(int classId, String pen, String date, int present) async {
    var req = http.MultipartRequest('POST', Uri.parse("$baseUrl/edit_attendance"));
    req.fields['class_id'] = classId.toString();
    req.fields['pen'] = pen;
    req.fields['date'] = date;
    req.fields['present'] = present.toString();
    var res = await req.send();
    return res.statusCode == 200;
  }

  static Future<List<dynamic>> viewAttendance(int classId, {String? date}) async {
    var url = "$baseUrl/view_attendance?class_id=$classId";
    if (date != null) url += "&date=$date";
    var res = await http.get(Uri.parse(url));
    if (res.statusCode == 200) {
      return jsonDecode(res.body)["attendance_records"];
    }
    throw Exception("Failed to load attendance");
  }
}