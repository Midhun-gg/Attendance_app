//home_page.dart

import 'package:flutter/material.dart';
import 'add_class_page.dart';
import 'browse_class_page.dart';
import 'delete_class_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Class Management'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
      ),
      body: Container(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Class Management System',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.blue[800],
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 50),
            _buildMenuButton(
              context,
              'Add a Class',
              Icons.add_circle,
              Colors.green,
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddClassPage()),
              ),
            ),
            SizedBox(height: 20),
            _buildMenuButton(
              context,
              'Browse a Class',
              Icons.search,
              Colors.blue,
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => BrowseClassPage()),
              ),
            ),
            SizedBox(height: 20),
            _buildMenuButton(
              context,
              'Delete a Class',
              Icons.delete,
              Colors.red,
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => DeleteClassPage()),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuButton(BuildContext context, String title, IconData icon,
      Color color, VoidCallback onPressed) {
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