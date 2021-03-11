import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import 'package:shopping_list/model/shopping_list_m.dart';
import 'package:flutter/cupertino.dart';
import 'package:shopping_list/ui/shopping_list_items_ui.dart';
import 'package:shopping_list/data_provider/shopping_list_dp.dart';
import 'package:shopping_list/data_provider/shopping_item_dp.dart';

class LocalNotificationService {
  final BuildContext _context;
  final ShoppingListDataProvider _shoppingListDataProvider;
  final ShoppingItemDataProvider _shoppingItemDataProvider;
  FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin;

  LocalNotificationService(this._context, this._shoppingItemDataProvider,
      this._shoppingListDataProvider) {
    _init();
  }

  Future<void> _init() async {
    _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
// initialise the plugin. app_icon needs to be a added as a drawable resource to the Android head project
//TODO IMPLEMENT ICON
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('app_icon');
    final IOSInitializationSettings initializationSettingsIOS =
        IOSInitializationSettings(
            onDidReceiveLocalNotification: _onDidReceiveLocalNotification);
    final MacOSInitializationSettings initializationSettingsMacOS =
        MacOSInitializationSettings();
    final InitializationSettings initializationSettings =
        InitializationSettings(
            android: initializationSettingsAndroid,
            iOS: initializationSettingsIOS,
            macOS: initializationSettingsMacOS);
    await _flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: _selectNotification);
  }

  Future _selectNotification(String payload) async {
    var shoppingListItemUI = await _createShoppingListItemsUI(payload);

    if (payload != null) {}
    await Navigator.push(
      _context,
      MaterialPageRoute<void>(builder: (context) => shoppingListItemUI),
    );
  }

  Future _onDidReceiveLocalNotification(
      int id, String title, String body, String payload) async {
    // display a dialog with the notification details, tap ok to go to another page

    var shoppingListItemUI = await _createShoppingListItemsUI(payload);
    showDialog(
      context: _context,
      builder: (BuildContext context) => CupertinoAlertDialog(
        title: Text(title),
        content: Text(body),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            child: Text('Ok'),
            onPressed: () async {
              Navigator.of(context, rootNavigator: true).pop();
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => shoppingListItemUI),
              );
            },
          )
        ],
      ),
    );
  }

  Future<void> showNotification(ShoppingList shoppingList) {
    var itemsBuffer = _createShoppingListItemsBuffer(shoppingList);

    var platformSpecificNotificationDetail =
        _createPlatformSpecificNotificationDetails();

    return _flutterLocalNotificationsPlugin.show(
        shoppingList.id,
        shoppingList.name,
        itemsBuffer.toString(),
        platformSpecificNotificationDetail,
        payload: shoppingList.id.toString());
  }

  StringBuffer _createShoppingListItemsBuffer(ShoppingList shoppingList) {
    var itemsBuffer = new StringBuffer();

    for (var shoppingListItem in shoppingList.items) {
      itemsBuffer.writeln(shoppingListItem.name);
    }

    return itemsBuffer;
  }

  NotificationDetails _createPlatformSpecificNotificationDetails() {
    return NotificationDetails(
        android: _createAndroidNotificationDetail(),
        iOS: _createIOSNotificationDetail());
  }

  Future<ShoppingListItemsUI> _createShoppingListItemsUI(String payload) async {
    var shoppingListId = int.parse(payload);
    var shoppingList = await _shoppingListDataProvider.getById(shoppingListId);
    return ShoppingListItemsUI(
        shoppingList, _shoppingListDataProvider, _shoppingItemDataProvider);
  }

  AndroidNotificationDetails _createAndroidNotificationDetail() {
    return AndroidNotificationDetails(
        'your channel id', 'your channel name', 'your channel description',
        importance: Importance.max, priority: Priority.high, showWhen: false);
  }

  IOSNotificationDetails _createIOSNotificationDetail() {
    return IOSNotificationDetails();
  }
}
