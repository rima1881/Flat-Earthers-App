import 'package:flutter/material.dart';
import 'map_screen.dart'; // Import the map screen
// ignore: unused_import
import 'sidebar.dart'; // Import the sidebar

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MapScreen(), // Call the MapScreen directly, no title needed
    );
  }
}
