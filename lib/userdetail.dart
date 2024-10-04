import 'package:account_manage/hive/models.dart';
import 'package:flutter/material.dart';

class UserDetailPage extends StatefulWidget {
  final UserModel user;
  final int userIndex;

  UserDetailPage(this.user, this.userIndex);

  @override
  _UserDetailPageState createState() => _UserDetailPageState();
}

class _UserDetailPageState extends State<UserDetailPage> {
  final TextEditingController amountController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  DateTime selectedDate = DateTime.now();
  bool isDebit = true;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  void _addTransaction() {
    double amount = double.tryParse(amountController.text) ?? 0;
    if (amount == 0) return;

    // Create a new transaction
    TransactionModel newTransaction = TransactionModel(
      description: descriptionController.text,
      amount: amount,
      date: selectedDate,
      isDebit: isDebit,
    );

    // Add the transaction to the user and save it
    widget.user.transactions.add(newTransaction);
    widget.user.save();

    // Clear input fields after adding the transaction
    amountController.clear();
    descriptionController.clear();
    selectedDate = DateTime.now(); // Reset to current date
    isDebit = true; // Reset to default value

    setState(() {}); // Refresh UI
  }

  void _showAddTransactionDialog() {
    // Reset the controllers and values for a new transaction
    descriptionController.clear();
    amountController.clear();
    selectedDate = DateTime.now();
    isDebit = true;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Add Transaction"),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          content: Container(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: descriptionController,
                  decoration: InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    fillColor: Colors.blue[50],
                    filled: true,
                  ),
                ),
                SizedBox(height: 10),
                TextField(
                  controller: amountController,
                  decoration: InputDecoration(
                    labelText: 'Amount',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    fillColor: Colors.blue[50],
                    filled: true,
                  ),
                  keyboardType: TextInputType.number,
                ),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Debit'),
                    Radio<bool>(
                      value: true,
                      groupValue: isDebit,
                      onChanged: (value) {
                        setState(() {
                          isDebit = value!;
                        });
                      },
                    ),
                    SizedBox(width: 20),
                    Text('Credit'),
                    Radio<bool>(
                      value: false,
                      groupValue: isDebit,
                      onChanged: (value) {
                        setState(() {
                          isDebit = value!;
                        });
                      },
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Text('Selected Date: ${selectedDate.toLocal()}'),
                ElevatedButton(
                  onPressed: () => _selectDate(context),
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    backgroundColor: Colors.teal,
                  ),
                  child: Text('Select Date'),
                ),
              ],
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                _addTransaction(); // Add transaction and refresh UI
                Navigator.pop(context); // Close dialog
              },
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                backgroundColor: Colors.green,
              ),
              child: Text('Add'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
              },
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                backgroundColor: Colors.red,
              ),
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  void _editTransaction(int index) {
    TransactionModel transaction = widget.user.transactions[index];

    // Populate the form fields with the current values
    descriptionController.text = transaction.description;
    amountController.text = transaction.amount.toString();
    selectedDate = transaction.date;
    isDebit = transaction.isDebit;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Edit Transaction"),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          content: Container(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: descriptionController,
                  decoration: InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    fillColor: Colors.blue[50],
                    filled: true,
                  ),
                ),
                SizedBox(height: 10),
                TextField(
                  controller: amountController,
                  decoration: InputDecoration(
                    labelText: 'Amount',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    fillColor: Colors.blue[50],
                    filled: true,
                  ),
                  keyboardType: TextInputType.number,
                ),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Debit'),
                    Radio<bool>(
                      value: true,
                      groupValue: isDebit,
                      onChanged: (value) {
                        setState(() {
                          isDebit = value!;
                        });
                      },
                    ),
                    SizedBox(width: 20),
                    Text('Credit'),
                    Radio<bool>(
                      value: false,
                      groupValue: isDebit,
                      onChanged: (value) {
                        setState(() {
                          isDebit = value!;
                        });
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                // Update the transaction in the list
                setState(() {
                  widget.user.transactions[index] = TransactionModel(
                    description: descriptionController.text,
                    amount: double.parse(amountController.text),
                    isDebit: isDebit,
                    date: selectedDate,
                  );

                  // Save the updated user data to Hive
                  widget.user.save();
                });

                Navigator.pop(context); // Close the dialog
              },
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                backgroundColor: Colors.green,
              ),
              child: Text('Save'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                backgroundColor: Colors.red,
              ),
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  void _deleteTransaction(int index) {
    setState(() {
      widget.user.transactions.removeAt(index);
      widget.user.save();
    });
  }

  @override
  Widget build(BuildContext context) {
    double balance = widget.user.transactions.fold(0, (sum, transaction) {
      return transaction.isDebit
          ? sum - transaction.amount
          : sum + transaction.amount;
    });

    return Scaffold(
        appBar: AppBar(
          title: Text("Transactions for ${widget.user.name}"),
          backgroundColor: Colors.teal,
        ),
        body: Padding(
            padding: const EdgeInsets.all(16.0),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
                color: Colors.blue[50],
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Balance: \$${balance.toStringAsFixed(2)}',
                        style: TextStyle(
                            fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 10),
              Expanded(
                  child: ListView.builder(
                      itemCount: widget.user.transactions.length,
                      itemBuilder: (context, index) {
                        final transaction = widget.user.transactions[
                            widget.user.transactions.length - 1 - index];
                        return Card(
                          elevation: 3,
                          margin: EdgeInsets.symmetric(vertical: 5),
                          child: ListTile(
                            title: Text(transaction.description),
                            subtitle:
                                Text("Date: ${transaction.date.toLocal()}"),
                            trailing: Text(
                              "\$${transaction.amount.toStringAsFixed(2)}",
                              style: TextStyle(
                                  color: transaction.isDebit
                                      ? Colors.red
                                      : Colors.green),
                            ),
                            onTap: () => _editTransaction(index),
                            onLongPress: () => _deleteTransaction(index),
                          ),
                        );
                      })),
              SizedBox(height: 10),
              Center(
                child: ElevatedButton(
                    onPressed: _showAddTransactionDialog,
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      backgroundColor: Colors.teal,
                    ),
                    child: Icon(
                      Icons.add,
                      color: Colors.white,
                    )),
              ),
            ])));
  }
}
