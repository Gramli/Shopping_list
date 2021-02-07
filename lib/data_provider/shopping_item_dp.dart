import 'package:shopping_list/model/shopping_item_m.dart';
import 'package:sqflite/sqflite.dart';

class ShoppingItemDataProvider {
  static const String _tableName = "shopping_item";
  static const String _colId = "id";
  static const String _colShoppingListId = "shopping_list_id";
  static const String _colName = "name";
  static const String _colChecked = "checked";

  Future<Database> _database;

  ShoppingItemDataProvider(this._database);

  Future<int> insert(ShoppingItem shoppingItem) async {
    return await _database
        .then((database) => database.insert(_tableName, _toMap(shoppingItem)));
  }

  Future<int> delete(int id) async {
    return await _database.then((database) =>
        database.delete(_tableName, where: "$_colId = ?", whereArgs: [id]));
  }

  Future<int> update(ShoppingItem shoppingItem) async {
    return await _database.then((database) => database.update(
        _tableName, _toMap(shoppingItem),
        where: "$_colId = ?", whereArgs: [shoppingItem.id]));
  }

  Future<List<ShoppingItem>> fetchBySoppingListId(int shoppingListId) async {
    var shoppingItems = await _fetch(shoppingListId);
    return shoppingItems.map((item) => _fromObject(item)).toList();
  }

  Future<List> _fetch(int shoppingListId) async {
    return await _database.then((database) => database.rawQuery(
        "SELECT * FROM $_tableName WHERE $_colShoppingListId=$shoppingListId ORDER BY $_colId ASC"));
  }

  ShoppingItem _fromObject(dynamic object) {
    var id = object[_colId];
    var shoppinListId = object[_colShoppingListId];
    var name = object[_colName];
    var checked = object[_colChecked] == 0 ? false : true;

    return ShoppingItem.withId(id, name, shoppinListId, checked);
  }

  Map<String, dynamic> _toMap(ShoppingItem shoppingItem) {
    var mapResult = Map<String, dynamic>();
    mapResult[_colName] = shoppingItem.name;
    mapResult[_colShoppingListId] = shoppingItem.shoppingListId;
    mapResult[_colChecked] = shoppingItem.checked ? 1 : 0;
    if (shoppingItem.id != null) {
      mapResult[_colId] = shoppingItem.id;
    }

    return mapResult;
  }

  static createTable(Database db) async {
    var createTableQuery =
        "CREATE TABLE $_tableName($_colId INTEGER PRIMARY KEY,"
        "$_colName TEXT,"
        "$_colShoppingListId INTEGER,"
        "$_colChecked INTEGER)";

    await db.execute(createTableQuery);
  }
}
