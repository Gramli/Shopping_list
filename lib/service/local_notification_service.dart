import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import 'package:shopping_list/data_generator/shopping_list_csv_import_dg.dart';
import 'package:shopping_list/model/shopping_list_m.dart';
import 'package:flutter/cupertino.dart';
import 'package:shopping_list/ui/shopping_list_items_ui.dart';
import 'package:shopping_list/data_provider/shopping_list_dp.dart';
import 'package:shopping_list/data_provider/shopping_item_dp.dart';

class LocalNotificationService {
  final BuildContext _context;
  final ShoppingListDataProvider _shoppingListDataProvider;
  final ShoppingItemDataProvider _shoppingItemDataProvider;
  final ShoppingListCsvImport _shoppingListCsvImport;
  FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin;

  final _channelId = "68c72fb0-3b4d-47b4-9f16-8bd97c938580";
  final _channelName = "ShoppingListLocalNotifications";
  final _channelDescription =
      "Shopping List application local notifications channel";

  LocalNotificationService(this._context, this._shoppingItemDataProvider,
      this._shoppingListDataProvider, this._shoppingListCsvImport) {
    _init();
  }

  Future<void> _init() async {
    _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
// initialise the plugin. app_icon needs to be a added as a drawable resource to the Android head project
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
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
    var shoppingListItemUI = await _createShoppingListItemsUI(payload);
    Navigator.of(_context, rootNavigator: true).pop();
    await Navigator.push(
      _context,
      MaterialPageRoute(builder: (context) => shoppingListItemUI),
    );
  }

  Future<void> showNotification(ShoppingList shoppingList) {
    var itemsBuffer =
        _shoppingListCsvImport.createShoppingListItemsBuffer(shoppingList);

    var platformSpecificNotificationDetail =
        _createPlatformSpecificNotificationDetails();

    return _flutterLocalNotificationsPlugin.show(
        shoppingList.id,
        shoppingList.name,
        itemsBuffer.toString(),
        platformSpecificNotificationDetail,
        payload: shoppingList.id.toString());
  }

  Future<void> cancelNotification(int shoppingListId) {
    return _flutterLocalNotificationsPlugin.cancel(shoppingListId);
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
        _channelId, _channelName, _channelDescription,
        importance: Importance.max, priority: Priority.high, showWhen: false);
  }

  IOSNotificationDetails _createIOSNotificationDetail() {
    return IOSNotificationDetails();
  }
}
