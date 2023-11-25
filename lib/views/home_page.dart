import 'package:flutter/material.dart';
import 'package:prova_2/models/expenses.dart';
import 'package:prova_2/services/expenses_services.dart';
import 'package:intl/intl.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ExpenseService _expenseService = ExpenseService();
  final _formKey = GlobalKey<FormState>();
  List<Expense> _expenses = [];
  double _totalExpenses = 0.0;

  final _categoryController = TextEditingController();
  final _amountController = TextEditingController();
  final _paymentMethodController = TextEditingController();
  final _descriptionController = TextEditingController();
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadExpenses();
  }

  void _loadExpenses() {
    _expenseService.getExpenses().listen((expenses) {
      setState(() {
        _expenses = expenses;
        _totalExpenses = expenses.fold(0.0, (sum, item) => sum + item.amount);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final formatCurrency =
        NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

    return Scaffold(
      appBar: AppBar(
        title: Text('Seu Controle Financeiro'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddExpenseModal(),
        child: Icon(Icons.add),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.attach_money,
                      color: Colors.green,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Total das Movimentações',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Text(
                  '${formatCurrency.format(_totalExpenses)}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Atividades recentes',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Divider(height: 1, thickness: 1),
          Expanded(
            child: ListView.builder(
              itemCount: _expenses.length,
              itemBuilder: (context, index) {
                Expense expense = _expenses[index];
                return ListTile(
                  title: Text(expense.category),
                  subtitle:
                      Text('Valor: ${formatCurrency.format(expense.amount)}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () => _showEditExpenseModal(expense),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () => _showDeleteConfirmation(expense),
                      ),
                    ],
                  ),
                  onTap: () => _showExpenseDetails(expense),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(Expense expense) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmar Exclusão'),
          content: Text('Deseja excluir esta despesa?'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Excluir'),
              onPressed: () {
                _expenseService.deleteExpense(expense.id).then((_) {
                  Navigator.of(context).pop();
                  _loadExpenses();
                });
              },
            ),
          ],
        );
      },
    );
  }

  void _showEditExpenseModal(Expense expense) {
    _categoryController.text = expense.category;
    _amountController.text = expense.amount.toStringAsFixed(2);
    _paymentMethodController.text = expense.paymentMethod;
    _descriptionController.text = expense.description ?? '';
    _selectedDate = expense.date;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Editar Despesa'),
          content: _buildExpenseForm(),
          actions: <Widget>[
            TextButton(
              child: Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Salvar'),
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  _updateExpense(expense);
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _showAddExpenseModal() {
    _categoryController.clear();
    _amountController.clear();
    _paymentMethodController.clear();
    _descriptionController.clear();
    _selectedDate = DateTime.now();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Adicionar Despesa'),
          content: _buildExpenseForm(),
          actions: <Widget>[
            TextButton(
              child: Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Adicionar'),
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  _addExpense();
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _updateExpense(Expense oldExpense) {
    Expense updatedExpense = Expense(
      id: oldExpense.id,
      category: _categoryController.text,
      amount: double.parse(_amountController.text),
      paymentMethod: _paymentMethodController.text,
      description: _descriptionController.text,
      date: _selectedDate,
    );
    _expenseService.updateExpense(updatedExpense).then((_) => _loadExpenses());
  }

  void _addExpense() {
    Expense newExpense = Expense(
      category: _categoryController.text,
      amount: double.parse(_amountController.text),
      paymentMethod: _paymentMethodController.text,
      description: _descriptionController.text,
      date: _selectedDate,
    );
    _expenseService.addExpense(newExpense).then((_) => _loadExpenses());
  }

  void _showExpenseDetails(Expense expense) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Detalhes da Despesa'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Categoria: ${expense.category}'),
                Text('Valor: ${expense.amount.toStringAsFixed(2)}'),
                Text('Data: ${DateFormat('dd/MM/yyyy').format(expense.date)}'),
                Text('Método de Pagamento: ${expense.paymentMethod}'),
                Text('Descrição: ${expense.description ?? 'N/A'}'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Fechar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildExpenseForm() {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          TextFormField(
            controller: _categoryController,
            decoration: InputDecoration(labelText: 'Categoria'),
            validator: (value) => value!.isEmpty ? 'Campo obrigatório' : null,
          ),
          TextFormField(
            controller: _amountController,
            decoration: InputDecoration(labelText: 'Valor'),
            keyboardType: TextInputType.number,
            validator: (value) => value!.isEmpty ? 'Campo obrigatório' : null,
          ),
          TextFormField(
            controller: _paymentMethodController,
            decoration: InputDecoration(labelText: 'Método de Pagamento'),
            validator: (value) => value!.isEmpty ? 'Campo obrigatório' : null,
          ),
          TextFormField(
            controller: _descriptionController,
            decoration: InputDecoration(labelText: 'Descrição (opcional)'),
          ),
          ListTile(
            title: Text(
              'Data da Despesa',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              DateFormat('dd/MM/yyyy').format(_selectedDate),
              style: TextStyle(fontSize: 18),
            ),
            onTap: () => _selectDate(context),
          ),
        ],
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null && pickedDate != _selectedDate)
      setState(() {
        _selectedDate = pickedDate;
      });
  }
}
