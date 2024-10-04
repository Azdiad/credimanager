import 'package:flutter/material.dart';
import 'package:account_manage/hive/models.dart';

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
    double? amount = double.tryParse(amountController.text) ?? 0;
    if (amount <= 0) return;

    // Create a new transaction
    TransactionModel newTransaction = TransactionModel(
      description: descriptionController.text,
      amount: amount,
      date: selectedDate,
      isDebit: isDebit,
    );

    // Add the transaction to the user and save it
    widget.user.transactions?.add(newTransaction);
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
          title: const Text("Add Transaction"),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTextField(descriptionController, 'Description'),
                const SizedBox(height: 10),
                _buildTextField(amountController, 'Amount', isAmount: true),
                const SizedBox(height: 10),
                _buildRadioButtons(),
                const SizedBox(height: 10),
                Text('Selected Date: ${selectedDate.toLocal()}'),
                ElevatedButton(
                  onPressed: () => _selectDate(context),
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    backgroundColor: Colors.teal,
                  ),
                  child: const Text('Select Date'),
                ),
              ],
            ),
          ),
          actions: [
            _buildDialogButton('Add', _addTransaction, Colors.green),
            _buildDialogButton(
                'Cancel', () => Navigator.pop(context), Colors.red),
          ],
        );
      },
    );
  }

  Widget _buildTextField(TextEditingController controller, String label,
      {bool isAmount = false}) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        fillColor: Colors.blue[50],
        filled: true,
      ),
      keyboardType: isAmount ? TextInputType.number : TextInputType.text,
    );
  }

  Widget _buildRadioButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('Debit'),
        Radio<bool>(
          value: true,
          groupValue: isDebit,
          onChanged: (value) {
            setState(() {
              isDebit = value!;
            });
          },
        ),
        const SizedBox(width: 20),
        const Text('Credit'),
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
    );
  }

  Widget _buildDialogButton(String text, VoidCallback onPressed, Color color) {
    return ElevatedButton(
      onPressed: () {
        onPressed();
        Navigator.pop(context);
      },
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        backgroundColor: color,
      ),
      child: Text(
        text,
        style: const TextStyle(color: Colors.white),
      ),
    );
  }

  void _editTransaction(int index) {
    TransactionModel transaction = widget.user.transactions![index];

    // Populate the form fields with the current values
    descriptionController.text = transaction.description ?? '';
    amountController.text = transaction.amount.toString();
    selectedDate = transaction.date ?? DateTime.now();
    isDebit = transaction.isDebit ?? true;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Edit Transaction"),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTextField(descriptionController, 'Description'),
                const SizedBox(height: 10),
                _buildTextField(amountController, 'Amount', isAmount: true),
                const SizedBox(height: 10),
                _buildRadioButtons(),
              ],
            ),
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    _deleteTransaction(index);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    backgroundColor: Colors.red,
                  ),
                  child: const Text(
                    'Delete',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                _buildDialogButton('Cancel', () => Navigator.pop(context),
                    const Color.fromARGB(255, 252, 95, 84)),
                _buildDialogButton('Save', () {
                  setState(() {
                    widget.user.transactions![index] = TransactionModel(
                      description: descriptionController.text,
                      amount: double.tryParse(amountController.text) ?? 0,
                      isDebit: isDebit,
                      date: selectedDate,
                    );

                    widget.user.save();
                  });
                }, Colors.green),
              ],
            ),
          ],
        );
      },
    );
  }

  void _deleteTransaction(int index) {
    setState(() {
      widget.user.transactions?.removeAt(index);
      widget.user.save();
    });
  }

  @override
  Widget build(BuildContext context) {
    double balance = widget.user.transactions?.fold(0, (sum, transaction) {
          return transaction.isDebit
              ? sum! - transaction.amount
              : sum! + transaction.amount;
        }) ??
        0;

    return Scaffold(
      appBar: AppBar(
        title: Text("Transactions for ${widget.user.name ?? 'User'}"),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(2.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  height: 50,
                  width: MediaQuery.of(context).size.width / 1.1,
                  decoration: const BoxDecoration(color: Colors.teal),
                  child: Center(
                      child: Text(
                    'Balance : ${balance ?? 0.00}',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.normal),
                  )),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Expanded(child: _buildTransactionTable()),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTransactionDialog,
        child: const Icon(Icons.add),
        backgroundColor: Colors.teal,
      ),
    );
  }

  Widget _buildTransactionTable() {
    return DataTable(
      columnSpacing: 0,
      headingRowColor:
          WidgetStateProperty.resolveWith<Color>((Set<WidgetState> states) {
        return Colors.teal;
      }),
      columns: const [
        DataColumn(
          label: SizedBox(
            width: 50,
            child: Text(
              'Date',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
        DataColumn(
          label: SizedBox(
            width: 100,
            child: Text(
              'Description',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
        DataColumn(
          label: SizedBox(
            width: 60,
            child: Text(
              'Credit',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
        DataColumn(
          label: SizedBox(
            width: 60,
            child: Text(
              'Debit',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
      ],
      rows: widget.user.transactions?.map<DataRow>((transaction) {
            return DataRow(
              cells: [
                DataCell(
                  onTap: () => _editTransaction(
                      widget.user.transactions!.indexOf(transaction)),
                  Container(
                    height: 40,
                    width: MediaQuery.of(context).size.width / 4,
                    decoration: BoxDecoration(
                      color: Colors.blue[
                          50], // Set filled background color for the Date cell
                      border: const Border(
                        right:
                            BorderSide(color: Colors.grey), // Vertical divider
                      ),
                    ),
                    padding: const EdgeInsets.all(
                        8), // Add padding for better appearance
                    child: Text(
                      transaction.date?.toLocal().toString().split(' ')[0] ??
                          '',
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                DataCell(
                  onTap: () => _editTransaction(
                      widget.user.transactions!.indexOf(transaction)),
                  Container(
                    height: 40,
                    width: MediaQuery.of(context).size.width / 4,
                    decoration: BoxDecoration(
                      color: Colors.blue[
                          100], // Set filled background color for the Description cell
                      border: const Border(
                        right:
                            BorderSide(color: Colors.grey), // Vertical divider
                      ),
                    ),
                    padding: const EdgeInsets.all(
                        8), // Add padding for better appearance
                    child: SingleChildScrollView(
                      child: Text(
                        transaction.description ?? '',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
                DataCell(
                  onTap: () => _editTransaction(
                      widget.user.transactions!.indexOf(transaction)),
                  Container(
                    height: 40,
                    width: MediaQuery.of(context).size.width / 5,
                    decoration: BoxDecoration(
                      color: transaction.isDebit
                          ? Colors.red[100]
                          : Colors.green[
                              100], // Conditional color based on transaction type
                      border: const Border(
                        right:
                            BorderSide(color: Colors.grey), // Vertical divider
                      ),
                    ),
                    padding: const EdgeInsets.all(
                        8), // Add padding for better appearance
                    child: Text(
                      transaction.isDebit
                          ? ''
                          : '\$${transaction.amount.toStringAsFixed(2)}',
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                DataCell(
                  onTap: () => _editTransaction(
                      widget.user.transactions!.indexOf(transaction)),
                  Container(
                    height: 40,
                    width: MediaQuery.of(context).size.width / 5,
                    decoration: BoxDecoration(
                      color: transaction.isDebit
                          ? Colors.green[100]
                          : Colors.red[
                              100], // Conditional color based on transaction type
                    ),
                    padding: const EdgeInsets.all(
                        8), // Add padding for better appearance
                    child: Text(
                      transaction.isDebit
                          ? '\$${transaction.amount.toStringAsFixed(2)}'
                          : '',
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            );
          }).toList() ??
          [],
    );
  }
}
