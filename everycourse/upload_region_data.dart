import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'lib/utils/region_data_uploader.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  
  runApp(const RegionUploaderApp());
}

class RegionUploaderApp extends StatelessWidget {
  const RegionUploaderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Region Data Uploader',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const RegionDataUploader(),
    );
  }
}
