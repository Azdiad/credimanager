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

  // Using ValueNotifier to track totals
  ValueNotifier<double> totalBalanceNotifier = ValueNotifier(0);
  ValueNotifier<double> totalDebitNotifier = ValueNotifier(0);
  ValueNotifier<double> totalCreditNotifier = ValueNotifier(0);

  @override
  void initState() {
    super.initState();
    _updateTotals(); // Initialize totals on startup
  }

  void _updateTotals() {
    double totalBalance = 0;
    double totalDebit = 0;
    double totalCredit = 0;

    for (var user in userBox.values) {
      totalBalance += user.transactions?.fold(
            0,
            (sum, transaction) => transaction.isDebit
                ? sum! - transaction.amount
                : sum! + transaction.amount,
          ) ??
          0;

      totalDebit += getTotalDebitForUser(user);
      totalCredit += getTotalCreditForUser(user);
    }

    // Update the notifiers
    totalBalanceNotifier.value = totalBalance;
    totalDebitNotifier.value = totalDebit;
    totalCreditNotifier.value = totalCredit;
  }

  double getTotalDebitForUser(UserModel user) {
    return user.transactions?.fold(
          0,
          (sum, transaction) =>
              transaction.isDebit ? sum! + transaction.amount : sum,
        ) ??
        0;
  }

  double getTotalCreditForUser(UserModel user) {
    return user.transactions?.fold(
          0,
          (sum, transaction) =>
              !transaction.isDebit ? sum! + transaction.amount : sum,
        ) ??
        0;
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
                  _updateTotals(); // Update totals after adding user
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
        title: ValueListenableBuilder<double>(
          valueListenable: totalBalanceNotifier,
          builder: (context, totalBalance, _) {
            return Text(
              'Total Balance: \$${totalBalance.toStringAsFixed(2)}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20, // Increased font size
              ),
            );
          },
        ),
        centerTitle: true,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Column(
            children: [
              ValueListenableBuilder<double>(
                valueListenable: totalDebitNotifier,
                builder: (context, totalDebit, _) {
                  return Text(
                    'Total Debit: \$${totalDebit.toStringAsFixed(2)}',
                    style: TextStyle(color: Colors.red), // Total debit color
                  );
                },
              ),
              ValueListenableBuilder<double>(
                valueListenable: totalCreditNotifier,
                builder: (context, totalCredit, _) {
                  return Text(
                    'Total Credit: \$${totalCredit.toStringAsFixed(2)}',
                    style: TextStyle(color: Colors.green), // Total credit color
                  );
                },
              ),
              Expanded(
                child: ValueListenableBuilder(
                  valueListenable: userBox.listenable(),
                  builder: (context, Box<UserModel> box, _) {
                    if (box.isEmpty) {
                      return Center(child: Text('No users added yet'));
                    } else {
                      return ListView.builder(
                        itemCount: box.length,
                        itemBuilder: (context, index) {
                          UserModel user = box.getAt(index)!;
                          double balance = user.transactions?.fold(
                                0,
                                (sum, transaction) => transaction.isDebit
                                    ? sum! - transaction.amount
                                    : sum! + transaction.amount,
                              ) ??
                              0;
                          double totalDebit = getTotalDebitForUser(user);
                          double totalCredit = getTotalCreditForUser(user);

                          return Card(
                            margin: const EdgeInsets.symmetric(
                                vertical: 8, horizontal: 16),
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
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Balance: \$${balance.toStringAsFixed(2)}',
                                    style: TextStyle(
                                        color:
                                            Colors.grey[600]), // Subtitle color
                                  ),
                                  Text(
                                    'Total Debit: \$${totalDebit.toStringAsFixed(2)}',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                  Text(
                                    'Total Credit: \$${totalCredit.toStringAsFixed(2)}',
                                    style: TextStyle(color: Colors.green),
                                  ),
                                ],
                              ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        UserDetailPage(user, index),
                                  ),
                                ).then((_) {
                                  // Update totals after returning from UserDetailPage
                                  _updateTotals();
                                });
                              },
                            ),
                          );
                        },
                      );
                    }
                  },
                ),
              ),
            ],
          );
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

  @override
  void dispose() {
    // Dispose the notifiers when no longer needed
    totalBalanceNotifier.dispose();
    totalDebitNotifier.dispose();
    totalCreditNotifier.dispose();
    super.dispose();
  }
}
