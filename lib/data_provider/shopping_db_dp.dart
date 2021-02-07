import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shopping_list/data_provider/shopping_item_dp.dart';
import 'package:shopping_list/data_provider/shopping_list_dp.dart';

class ShoppingDbDataProvider {
  static Database _db;

  Future<Database> get db async {
    if (_db == null) {
      _db = await _initializeDb();
    }

    return _db;
  }

  static final ShoppingDbDataProvider _todoDataProvider =
      ShoppingDbDataProvider._internal();

  ShoppingDbDataProvider._internal();

  factory ShoppingDbDataProvider() {
    return _todoDataProvider;
  }

  Future<Database> _initializeDb() async {
    var directory = await getApplicationDocumentsDirectory();
    var path = '${directory.path}todos.db';
    var todosDb = await openDatabase(path, version: 1, onCreate: _createDb);
    return todosDb;
  }
}

void _createDb(Database db, int version) async {
  await ShoppingListDataProvider.createTable(db);
  await ShoppingItemDataProvider.createTable(db);
}
