import 'package:flutter/material.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:prova_2/models/expenses.dart';
import 'package:prova_2/services/expenses_services.dart';

class ExpensesView extends StatefulWidget {
  @override
  _ExpensesViewState createState() => _ExpensesViewState();
}

class _ExpensesViewState extends State<ExpensesView> {
  final ExpenseService _expenseService = ExpenseService();
  List<Expense> _expenses = [];
  Map<String, double> _categoryTotal = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadExpenses();
  }

  void _loadExpenses() {
    _expenseService.getExpenses().listen((expenses) {
      setState(() {
        _expenses = expenses;
        _categoryTotal = _calculateCategoryTotal(expenses);
        _isLoading = false;
      });
    });
  }

  Map<String, double> _calculateCategoryTotal(List<Expense> expenses) {
    Map<String, double> categoryTotal = {};

    for (var expense in expenses) {
      categoryTotal.update(
        expense.category,
        (value) => value + expense.amount,
        ifAbsent: () => expense.amount,
      );
    }

    return categoryTotal;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Despesas por Categoria'),
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : _categoryTotal.isNotEmpty
              ? Center(
                  child: Container(
                    padding: EdgeInsets.all(16.0),
                    height: MediaQuery.of(context).size.height * 0.5,
                    width: MediaQuery.of(context).size.width * 0.8,
                    child: PieChart(
                      dataMap: _categoryTotal,
                      chartType: ChartType.disc,
                      ringStrokeWidth: 32,
                      colorList: [
                        Colors.grey[700]!,
                        Colors.grey[600]!,
                        Colors.black87,
                        Color.fromARGB(255, 78, 76, 76),
                        Color.fromARGB(255, 0, 0, 0),
                        Color.fromARGB(255, 95, 113, 121),
                      ],
                      chartValuesOptions: ChartValuesOptions(
                        showChartValuesInPercentage: true,
                        showChartValuesOutside: true,
                        decimalPlaces: 2,
                      ),
                      legendOptions: LegendOptions(
                        showLegendsInRow: true,
                        legendPosition: LegendPosition.bottom,
                        showLegends: true,
                      ),
                    ),
                  ),
                )
              : Center(
                  child: Text('Nenhuma despesa encontrada.'),
                ),
    );
  }
}
