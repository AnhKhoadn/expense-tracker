import 'package:expense_tracker/models/expense.dart';
import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

import '../helper/helper_functions.dart';

class ExpenseDatabase extends ChangeNotifier {
  static late Isar isar;
  final List<Expense> _allExpenses = [];

  List<Expense> get allExpenses => _allExpenses;

  // initialize database
  static Future<void> initialize() async {
    final dir = await getApplicationDocumentsDirectory();
    isar = await Isar.open([ExpenseSchema], directory: dir.path);
  }

  Future<void> readExpense() async{
    List<Expense> fetchExpense = await isar.expenses.where().findAll();

    _allExpenses.clear();
    _allExpenses.addAll(fetchExpense);

    // update UI
    notifyListeners();
  }

  Future<void> createNewExpense(Expense newExpense) async{
    // add
    await isar.writeTxn(() => isar.expenses.put(newExpense));

    await readExpense();
  }

  Future<void> updateExpense(int id, Expense updatedExpense) async{
    updatedExpense.id = id;

    await isar.writeTxn(() => isar.expenses.put(updatedExpense));

    await readExpense();
  }

  Future<void> deleteExpense(int id) async{
    await isar.writeTxn(() => isar.expenses.delete(id));

    await readExpense();
  }


  // calculate total expense each month, year
  Future<Map<String, double>> calculateMonthlyTotals() async {
    // read expenses from database
    await readExpense();

    // create a map to track total expenses per month
    // 0 120.000 jan, 1 220000 feb
    Map<String, double> monthlyTotals = {};

    for(var expense in _allExpenses){
      // get year-month from expense date
      String yearMonth = '${expense.date.year.toString()}-${expense.date.month.toString()}';

      // if year-month is not yet in the map initialize to 0
      if(!monthlyTotals.containsKey(yearMonth)) {
        monthlyTotals[yearMonth] = 0;
      }

      // add expense amount to total of each month
      monthlyTotals[yearMonth] = monthlyTotals[yearMonth]! + expense.amount;
    }

    return monthlyTotals;
  }

  // calculate current month total
  Future<double> calculateCurrentMonthTotal() async {
    // read expenses from db
    await readExpense();

    // get the current month, year
    int currentMonth = DateTime.now().month;
    int currentYear = DateTime.now().year;

    // get expenses from this month, this year
    List<Expense> currentMonthExpenses = _allExpenses.where((expense) {
      return expense.date.month == currentMonth && expense.date.year == currentYear;
    }).toList();

    // calculate total amount for current month
    double total = currentMonthExpenses.fold(0, (sum, expense) => sum + expense.amount);

    return total;
  }

  // get start month
  int getStartMonth() {
    if(_allExpenses.isEmpty) {
      return DateTime.now().month; // default to current month if no expenses are recorded
    }

    // sort expenses by date
    _allExpenses.sort((a, b) => a.date.compareTo(b.date),
    );
    return _allExpenses.first.date.month;
  }

  // get start year
  int getStartYear() {
    if(_allExpenses.isEmpty) {
      return DateTime.now().year; // default to current year if no expenses are recorded
    }

    // sort expenses by date
    _allExpenses.sort((a, b) => a.date.compareTo(b.date),
    );
    return _allExpenses.first.date.year;
  }
}
