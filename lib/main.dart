import 'package:account_manage/entrypage.dart';
import 'package:account_manage/hive/models.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart'; // Hive flutter package

void main() async {
  // Initialize Hive and register adapters
  await Hive.initFlutter();

  // Register Hive adapters for TransactionModel and UserModel
  Hive.registerAdapter(TransactionModelAdapter());
  Hive.registerAdapter(UserModelAdapter());

  // Open the box for storing user data
  await Hive.openBox<UserModel>('users');

  runApp(MoneyManagerApp());
}

class MoneyManagerApp extends StatelessWidget {
  const MoneyManagerApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: PasswordEntryPage(),
    );
  }
}
