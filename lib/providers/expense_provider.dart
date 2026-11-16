import 'package:flutter/foundation.dart';

import '../utils/database_service.dart';

class ExpenseProvider extends ChangeNotifier {
  List<ExpenseModel> _items = [];
  bool _loading = true;

  /// Newest first.
  List<ExpenseModel> get items => _items;
  bool get loading => _loading;

  double totalIncome = 0;
  double totalExpense = 0;
  double balance = 0;

  void hisoblash() {
    for (var i = 0; i < items.length; i++) {
      if (items[i].income) {
        totalIncome += items[i].price;
      } else {
        totalExpense += items[i].price;
      }
    }

    balance = totalIncome - totalExpense;
    notifyListeners();
  }

  /// Spending per category, biggest first.
  List<MapEntry<String, double>> breakdown({required bool income}) {
    final map = <String, double>{};
    for (final e in _items.where((e) => e.income == income)) {
      map[e.type] = (map[e.type] ?? 0) + e.price;
    }
    return map.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
  }

  Future<void> load() async {
    final rows = await DatabaseService.getExpenses();
    _items = rows.reversed.toList();
    _loading = false;
    notifyListeners();
  }

  Future<void> add({
    required double price,
    required String note,
    required String type,
    required bool income,
  }) async {
    await DatabaseService.addRasxodToDb(
      ExpenseModel(id: 0, note: note, type: type, income: income, price: price),
    );
    await load();
  }

  void clear() {
    _items = [];
    notifyListeners();
  }
}
