import 'package:hive/hive.dart';

part 'models.g.dart';

@HiveType(typeId: 0)
class TransactionModel extends HiveObject {
  @HiveField(0)
  String description;

  @HiveField(1)
  double amount;

  @HiveField(2)
  DateTime date;

  @HiveField(3)
  bool isDebit;

  TransactionModel(
      {required this.description,
      required this.amount,
      required this.date,
      required this.isDebit});
}

@HiveType(typeId: 1)
class UserModel extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  List<TransactionModel> transactions;

  UserModel({required this.name, required this.transactions});
}
