import 'package:account_manage/hive/models.dart';
import 'package:account_manage/userdetail.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final Box<UserModel> userBox = Hive.box<UserModel>('users');

  double getTotalBalance() {
    double totalBalance = 0;
    for (var user in userBox.values) {
      totalBalance += user.transactions.fold(
        0,
        (sum, transaction) => transaction.isDebit
            ? sum - transaction.amount
            : sum + transaction.amount,
      );
    }
    return totalBalance;
  }

  void _addUser() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String userName = '';
        return AlertDialog(
          title: Text("Add User"),
          content: TextField(
            onChanged: (value) => userName = value,
            decoration: InputDecoration(labelText: 'Enter user name'),
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.teal, // Text color
              ),
              onPressed: () {
                if (userName.isNotEmpty) {
                  UserModel newUser =
                      UserModel(name: userName, transactions: []);
                  userBox.add(newUser);
                  setState(() {}); // To refresh UI after adding user
                }
                Navigator.pop(context);
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal, // App bar color
        title: Text(
          'Total Balance: \$${getTotalBalance().toStringAsFixed(2)}',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20, // Increased font size
          ),
        ),
        centerTitle: true,
      ),
      body: ValueListenableBuilder(
        valueListenable: userBox.listenable(),
        builder: (context, Box<UserModel> box, _) {
          if (box.isEmpty) {
            return Center(child: Text('No users added yet'));
          } else {
            return ListView.builder(
              itemCount: box.length,
              itemBuilder: (context, index) {
                UserModel user = box.getAt(index)!;
                double balance = user.transactions.fold(
                  0,
                  (sum, transaction) => transaction.isDebit
                      ? sum - transaction.amount
                      : sum + transaction.amount,
                );
                return Card(
                  margin:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  elevation: 4,
                  color: Colors.white, // Card background color
                  child: ListTile(
                    title: Text(
                      user.name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.teal, // Text color
                      ),
                    ),
                    subtitle: Text(
                      'Balance: \$${balance.toStringAsFixed(2)}',
                      style:
                          TextStyle(color: Colors.grey[600]), // Subtitle color
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => UserDetailPage(user, index),
                        ),
                      );
                    },
                  ),
                );
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.teal, // Floating action button color
        onPressed: _addUser,
        child: Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }
}
