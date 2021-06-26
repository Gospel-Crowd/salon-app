import 'package:flutter/material.dart';
import 'package:salon_creator/app.dart';
import 'package:firebase_core/firebase_core.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(SalonCreatorApp());
}
