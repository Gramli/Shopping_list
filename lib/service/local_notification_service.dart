import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import 'package:shopping_list/model/shopping_list_m.dart';
import 'package:flutter/cupertino.dart';
import 'package:shopping_list/ui/shopping_list_items_ui.dart';

class LocalNotificationService {
  BuildContext _context;
  FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin;

  LocalNotificationService(this._context) {
    _init();
  }

  Future<void> _init() async {
    _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
// initialise the plugin. app_icon needs to be a added as a drawable resource to the Android head project
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
    if (payload != null) {}
    await Navigator.push(
      _context,
      MaterialPageRoute<void>(
          builder: (context) => _shoppingListItemsUI(payload)),
    );
  }

  Future _onDidReceiveLocalNotification(
      int id, String title, String body, String payload) async {
    // display a dialog with the notification details, tap ok to go to another page
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
                MaterialPageRoute(
                  builder: (context) => _shoppingListItemsUI(payload),
                ),
              );
            },
          )
        ],
      ),
    );
  }

  Future<void> showNotification(ShoppingList shoppingList) {
    var itemsBuffer = new StringBuffer();

    for (var shoppingListItem in shoppingList.items) {
      itemsBuffer.writeln(shoppingListItem.name);
    }

    var platformSpecificNotificationDetail =
        _createPlatformSpecificNotificationDetails();

    return _flutterLocalNotificationsPlugin.show(
        shoppingList.id,
        shoppingList.name,
        itemsBuffer.toString(),
        platformSpecificNotificationDetail);
  }

  NotificationDetails _createPlatformSpecificNotificationDetails() {
    throw UnimplementedError();
  }

  ShoppingListItemsUI _shoppingListItemsUI(String payload) {
    throw UnimplementedError();
  }
}
