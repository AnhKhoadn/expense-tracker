import 'package:isar/isar.dart';

// generate Isar file
// cmd: dart run build_runner build
part 'expense.g.dart';

@Collection()
class Expense {
  // id auto increase
  Id id = Isar.autoIncrement;
  final String name;
  final double amount;
  final DateTime date;

  Expense({required this.name, required this.amount, required this.date});
}
