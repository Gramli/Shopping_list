import 'package:sqflite/sqflite.dart';
import 'package:shopping_list/model/shopping_list_m.dart';
import 'package:shopping_list/data_provider/shopping_item_dp.dart';

class ShoppingListDataProvider {
  static const String _tableName = "shopping_list";
  static const String _colId = "id";
  static const String _colCreated = "created";
  static const String _colName = "name";

  ShoppingItemDataProvider _shoppingItemDataProvider;
  Future<Database> _database;

  ShoppingListDataProvider(this._database, this._shoppingItemDataProvider);

  Future<int> insertWithItems(ShoppingList shoppingList) async {
    var result = await _insert(shoppingList);
    for (var shoppingItem in shoppingList.items) {
      shoppingItem.shoppingListId = result;
      await _shoppingItemDataProvider.insert(shoppingItem);
    }
    return result;
  }

  Future<int> _insert(ShoppingList shoppingList) async {
    return await _database
        .then((database) => database.insert(_tableName, _toMap(shoppingList)));
  }

  Future<List<ShoppingList>> fetchWithItems() async {
    var result = List<ShoppingList>();
    var rawShoppingLists = await _fetch();

    for (var rawShoppingList in rawShoppingLists) {
      var shoppingList = _fromObject(rawShoppingList);
      var shoppingListItems =
          await _shoppingItemDataProvider.fetchBySoppingListId(shoppingList.id);
      shoppingList.items.addAll(shoppingListItems);
      result.add(shoppingList);
    }

    return result;
  }

  Future<List> _fetch() async {
    return await _database.then((database) => database
        .rawQuery("SELECT * FROM $_tableName ORDER BY $_colCreated ASC"));
  }

  Future<int> count() async {
    return Sqflite.firstIntValue(await _database.then(
        (database) => database.rawQuery("SELECT COUNT(*) FROM $_tableName")));
  }

  Future<int> updateWithItems(ShoppingList shoppingList) {
    for (var shoppingListItem in shoppingList.items) {
      if (shoppingListItem.id != null) {
        _shoppingItemDataProvider.update(shoppingListItem);
      } else {
        _shoppingItemDataProvider.insert(shoppingListItem);
      }
    }
    return _update(shoppingList);
  }

  Future<int> _update(ShoppingList shoppingList) async {
    return await _database.then((database) => database.update(
        _tableName, _toMap(shoppingList),
        where: "$_colId = ?", whereArgs: [shoppingList.id]));
  }

  Future<int> deleteWithItems(ShoppingList shoppingList) async {
    for (var shoppingListItem in shoppingList.items) {
      if (shoppingListItem.id != null) {
        _shoppingItemDataProvider.delete(shoppingListItem.id);
      }
    }
    return _delete(shoppingList);
  }

  Future<int> _delete(ShoppingList shoppingList) async {
    return await _database.then((database) => database.delete(_tableName,
        where: "$_colId = ?", whereArgs: [shoppingList.id]));
  }

  ShoppingList _fromObject(dynamic object) {
    var id = object[_colId];
    var created = object[_colCreated];
    var name = object[_colName];

    return ShoppingList.withId(id, name, DateTime.parse(created));
  }

  Map<String, dynamic> _toMap(ShoppingList shoppingList) {
    var mapResult = Map<String, dynamic>();
    mapResult[_colName] = shoppingList.name;
    mapResult[_colCreated] = shoppingList.created.toString();
    if (shoppingList.id != null) {
      mapResult[_colId] = shoppingList.id;
    }

    return mapResult;
  }

  Future<ShoppingList> getById(int id) async {
    var rawShoppingList = await _database.then((database) => database.rawQuery(
        "SELECT * FROM $_tableName WHERE id = $id ORDER BY $_colCreated ASC"));

    if (rawShoppingList.length == 0) {
      throw ArgumentError("Id:$id does not exists!");
    }

    if (rawShoppingList.length > 1) {
      throw Exception("There is more items with same id:$id");
    }

    return _fromObject(rawShoppingList[0]);
  }

  static createTable(Database db) async {
    var createTableQuery =
        "CREATE TABLE $_tableName($_colId INTEGER PRIMARY KEY,"
        "$_colName TEXT,"
        "$_colCreated TEXT)";

    await db.execute(createTableQuery);
  }
}
