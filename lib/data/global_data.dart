// global_data.dart
import '../models/school_class.dart';

List<SchoolClass> addedClasses = [];

void sortClasses() {
  addedClasses.sort((a, b) {
    int classCompare = a.className.compareTo(b.className);
    if (classCompare != 0) return classCompare;
    return a.sectionName.compareTo(b.sectionName);
  });
}