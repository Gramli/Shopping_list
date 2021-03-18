import 'package:flutter/material.dart';
import 'package:shopping_list/data_provider/shopping_item_dp.dart';
import 'package:shopping_list/service/MessageEventArgs.dart';
import 'package:shopping_list/ui/shopping_lists_ui.dart';
import 'package:shopping_list/data_provider/shopping_list_dp.dart';
import 'package:shopping_list/data_provider/shopping_db_dp.dart';
import 'package:sqflite/sqflite.dart';
import 'package:shopping_list/service/push_notification_service.dart';
import 'package:shopping_list/service/local_notification_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final _shoppingDbDataProvider = ShoppingDbDataProvider();
  final _pushNotificationService = PushNotificationService();

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Shopping list',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(_shoppingDbDataProvider.db, _pushNotificationService),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final Future<Database> _database;
  final PushNotificationService _pushNotificationService;

  MyHomePage(this._database, this._pushNotificationService);
  @override
  _MyHomePageState createState() =>
      _MyHomePageState(_database, _pushNotificationService);
}

class _MyHomePageState extends State<MyHomePage> {
  final Future<Database> _database;
  final PushNotificationService _pushNotificationService;
  LocalNotificationService _localNotificationService;

  _MyHomePageState(this._database, this._pushNotificationService);
  @override
  Widget build(BuildContext context) {
    // ignore: unnecessary_statements
    _pushNotificationService.onMessageEvent +
        (args) => _showOnMessageDialog(args, context);

    var shoppingItemDataProvider = ShoppingItemDataProvider(_database);
    var shoppingListDataProvider =
        ShoppingListDataProvider(_database, shoppingItemDataProvider);

    _localNotificationService = LocalNotificationService(
        context, shoppingItemDataProvider, shoppingListDataProvider);

    return ShoppingListUI(shoppingListDataProvider, shoppingItemDataProvider,
        _localNotificationService);
  }

  Future<void> _showOnMessageDialog(
      MessageEventArgs eventArgs, BuildContext context) async {
    return showDialog<void>(
        barrierDismissible: false,
        context: context,
        builder: (_) => AlertDialog(
              title: Text(eventArgs.title),
              content: Text(eventArgs.message),
              actions: <Widget>[
                FlatButton(
                  child: Text('Ok!'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                )
              ],
            ));
  }
}
