import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseService {
  static late Database db;
  static String dataBaseName = 'track.db';

  static Future<void> init(String folder) async {
    final cachePath =
        await getDatabasesPath(); // * android/cache/database/foldername
    final path = join(cachePath, folder);
    db = await openDatabase(path, version: 1, onCreate: _createDB);
  }

  static Future _createDB(Database database, int version) async {
    await database.execute('''
    CREATE TABLE userInfo (
      name TEXT,
      lastName TEXT,
      email TEXT,
      password INTEGER
    )
    ''');

    await database.execute('''
    CREATE TABLE expenses (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      price REAL,
      note TEXT,
      type TEXT,
      income INTEGER
    )
    ''');
  }

  static Future<void> addUserToDB(
    String name,
    String lastName,
    String email,
    String password,
  ) async {
    final row = {
      "name": name,
      "lastName": lastName,
      "email": email,
      "password": int.parse(password),
    };

    await db.insert('userInfo', row);
  }

  static Future<UserModel?> getUser() async {
    final rows = await db.query('userInfo', limit: 1);
    if (rows.isEmpty) return null;
    final e = rows.first;
    return UserModel(
      name: e['name'] as String,
      lastName: e['lastName'] as String,
      email: e['email'] as String,
    );
  }

  static Future<void> logOut() async {
    await db.delete('userInfo');
  }

  static Future<void> addRasxodToDb(ExpenseModel rasxor) async {
    final row = {
      "price": rasxor.price,
      "note": rasxor.note,
      "type": rasxor.type,
      "income": rasxor.income == true ? 1 : 0,
    };

    await db.insert('expenses', row);
  }

  static Future<List<ExpenseModel>> getExpenses() async {
    final rows = await db.query('expenses');
    return rows
        .map(
          (e) => ExpenseModel(
            id: e['id'] as int,
            note: e['note'] as String,
            type: e['type'] as String,
            income: e['income'] == 1,
            price: (e['price'] as num).toDouble(),
          ),
        )
        .toList();
  }
}

// ! Bu provider ichida turadi ui ga malumotlarni osonroq chiqarish uchun
class ExpenseModel {
  final String note;
  final int id;
  final String type;
  final bool income; // * rasxodmi yoki rasxodmasmi
  final double price;

  ExpenseModel({
    required this.id,
    required this.note,
    required this.type,
    required this.income,
    required this.price,
  });
}

class UserModel {
  final String name;
  final String lastName;
  final String email;

  UserModel({required this.name, required this.lastName, required this.email});

  String get fullName => '$name $lastName'.trim();
  String get initials =>
      '${name.isNotEmpty ? name[0] : ''}${lastName.isNotEmpty ? lastName[0] : ''}'
          .toUpperCase();
}
