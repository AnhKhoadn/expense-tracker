import 'package:expense_tracker/bar_graph/bar_graph.dart';
import 'package:expense_tracker/components/my_drawer.dart';
import 'package:expense_tracker/components/my_list_title.dart';
import 'package:expense_tracker/database/expense_database.dart';
import 'package:expense_tracker/helper/helper_functions.dart';
import 'package:expense_tracker/models/expense.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Text controllers
  TextEditingController nameController = TextEditingController();
  TextEditingController amountController = TextEditingController();

  // futures to load graph data & monthly total
  Future<Map<String, double>>? _monthlyTotalFuture;
  Future<double>? _calculateCurrentMonthTotal;

  @override
  void initState() {
    // read database on initial startup
    Provider.of<ExpenseDatabase>(context, listen: false).readExpense();

    // load futures
    refreshData();

    super.initState();
  }

  // refresh graph data
  void refreshData() {
    _monthlyTotalFuture =
        Provider.of<ExpenseDatabase>(context, listen: false).calculateMonthlyTotals();
    _calculateCurrentMonthTotal =
        Provider.of<ExpenseDatabase>(context, listen: false).calculateCurrentMonthTotal();
  }

  // open add expense box
  void openNewExpenseBox() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('New Expense'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // name
            TextField(
              controller: nameController,
              decoration: const InputDecoration(hintText: 'Expense name'),
            ),

            // amount
            TextField(
              controller: amountController,
              decoration: const InputDecoration(hintText: 'Amount'),
            ),
          ],
        ),
        actions: [
          _cancelButton(),
          _createNewExpenseButton(),
        ],
      ),
    );
  }

  // open edit box
  void openEditBox(Expense existingExpense) {
    // fill existing information
    nameController.text = existingExpense.name;
    amountController.text = existingExpense.amount.toString();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Expense'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // name
            TextField(
              controller: nameController,
              decoration: InputDecoration(hintText: nameController.text),
            ),

            // amount
            TextField(
              controller: amountController,
              decoration: InputDecoration(hintText: amountController.text),
            ),
          ],
        ),
        actions: [
          _cancelButton(),
          _editExpenseButton(existingExpense),
        ],
      ),
    );
  }

  // open delete box
  void openDeleteBox(Expense expense) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Are you sure you want to delete this expense?'),
        actions: [
          _cancelButton(),
          _deleteExpenseButton(expense.id),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ExpenseDatabase>(builder: (context, value, child) {
      // get dates
      int startMonth = value.getStartMonth();
      int startYear = value.getStartYear();
      int currentMonth = DateTime.now().month;
      int currentYear = DateTime.now().year;

      // calculate the number of months since the first month to know how many bar will display
      int monthCount = calculateMonthCount(startYear, startMonth, currentYear, currentMonth);

      return Scaffold(
          backgroundColor: Theme.of(context).colorScheme.background,
          floatingActionButton: FloatingActionButton(
            backgroundColor: Theme.of(context).colorScheme.onBackground,
            foregroundColor: Theme.of(context).colorScheme.surface,
            onPressed: openNewExpenseBox,
            child: const Icon(Icons.add),
          ),
          drawer: const MyDrawer(),
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            title: FutureBuilder<double>(
              future: _calculateCurrentMonthTotal,
              builder: (context, snapshot) {
                // loaded
                if (snapshot.connectionState == ConnectionState.done) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // total
                      const Spacer(),
                      Text(formatAmount(snapshot.data!)),
                      const Spacer(),
                      // month
                      Text(getCurrentMonthName()),
                    ],
                  );
                }
                // loading
                else {
                  return const Text('Loading...');
                }
              },
            ),
          ),
          body: SafeArea(
            child: Column(
              children: [
                // bar graph
                SizedBox(
                  height: 250,
                  child: FutureBuilder(
                    future: _monthlyTotalFuture,
                    builder: (context, snapshot) {
                      // data is loaded
                      if (snapshot.connectionState == ConnectionState.done) {
                        Map<String, double> monthlyTotals = snapshot.data ?? {};

                        // create the list of monthly summary
                        List<double> monthlySummary = List.generate(monthCount, (index) {
                          // calculated year-month
                          int year = startYear + (startMonth + index - 1) ~/ 12;
                          int month = (startMonth + index - 1) % 12 + 1;

                          // create the key to format year-month
                          String yearMonthKey = '$year-$month';

                          // return total of year-month, 0 if it doesn't exist
                          return monthlyTotals[yearMonthKey] ?? 0;
                        });

                        return MyBarGraph(monthlySummary: monthlySummary, startMonth: startMonth);
                      }
                      // loading
                      else {
                        return const Center(
                          child: Text('Loading...'),
                        );
                      }
                    },
                  ),
                ),

                const SizedBox(height: 25),

                // expense list
                Expanded(
                  child: ListView.builder(
                    itemCount: value.allExpenses.length,
                    itemBuilder: (context, index) {
                      // reverse the index to show latest item first
                      int reversedIndex = value.allExpenses.length - 1 - index;

                      // get each expense
                      Expense individualExpense = value.allExpenses[reversedIndex];
                      return MyListTitle(
                        title: individualExpense.name,
                        trailing: formatAmount(individualExpense.amount),
                        date: DateFormat('yyyy/MM/dd').format(individualExpense.date),
                        onEditPressed: (context) => openEditBox(individualExpense),
                        onDeletePressed: (context) => openDeleteBox(individualExpense),
                      );
                    },
                  ),
                ),
              ],
            ),
          ));
    });
  }

  Widget _cancelButton() {
    return MaterialButton(
        onPressed: () {
          Navigator.pop(context);

          nameController.clear();
          amountController.clear();
        },
        child: const Text('Cancel'));
  }

  Widget _createNewExpenseButton() {
    return MaterialButton(
      onPressed: () async {
        if (nameController.text.isNotEmpty && amountController.text.isNotEmpty) {
          Navigator.pop(context);

          // create expense
          Expense newExpense = Expense(
            name: nameController.text,
            amount: convertStringToDouble(amountController.text),
            date: DateTime.now(),
          );

          // save to database
          await context.read<ExpenseDatabase>().createNewExpense(newExpense);

          // refresh graph
          refreshData();

          nameController.clear();
          amountController.clear();
        }
      },
      child: const Text('Save'),
    );
  }

  Widget _editExpenseButton(Expense expense) {
    return MaterialButton(
      onPressed: () async {
        // save when at least 1 field has been changed
        if (nameController.text.isNotEmpty || amountController.text.isNotEmpty) {
          Navigator.pop(context);
          // edit expense
          Expense updatedExpense = Expense(
            name: nameController.text.isNotEmpty ? nameController.text : expense.name,
            amount: amountController.text.isNotEmpty
                ? convertStringToDouble(amountController.text)
                : expense.amount,
            date: DateTime.now(),
          );

          // still the same id
          int existingId = expense.id;

          // save to database
          await context.read<ExpenseDatabase>().updateExpense(existingId, updatedExpense);

          // refresh graph
          refreshData();
        }
      },
      child: const Text('Save'),
    );
  }

  Widget _deleteExpenseButton(int id) {
    return MaterialButton(
      onPressed: () async {
        Navigator.pop(context);
        // delete expense
        await context.read<ExpenseDatabase>().deleteExpense(id);

        // refresh graph
        refreshData();
      },
      child: const Text('Delete'),
    );
  }
}
