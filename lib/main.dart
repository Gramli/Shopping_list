import 'package:flutter/material.dart';
import 'package:shopping_list/data_provider/shopping_item_dp.dart';
import 'package:shopping_list/ui/shopping_lists_ui.dart';
import 'package:shopping_list/data_provider/shopping_list_dp.dart';
import 'package:shopping_list/data_provider/shopping_db_dp.dart';
import 'package:sqflite/sqflite.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final _shoppingDbDataProvider = ShoppingDbDataProvider();
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Shopping list',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(_shoppingDbDataProvider.db),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final Future<Database> _database;

  MyHomePage(this._database);
  @override
  _MyHomePageState createState() => _MyHomePageState(_database);
}

class _MyHomePageState extends State<MyHomePage> {
  final Future<Database> _database;
  _MyHomePageState(this._database);
  @override
  Widget build(BuildContext context) {
    var shoppingItemDataProvider = ShoppingItemDataProvider(_database);
    var shoppingListDataProvider =
        ShoppingListDataProvider(_database, shoppingItemDataProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text("Shopping List"),
      ),
      body: ShoppingListUI(shoppingListDataProvider, shoppingItemDataProvider),
    );
  }
}
