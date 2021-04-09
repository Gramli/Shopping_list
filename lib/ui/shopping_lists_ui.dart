import 'package:flutter/material.dart';
import 'package:shopping_list/model/shopping_list_m.dart';
import 'package:shopping_list/ui/shopping_list_items_ui.dart';
import 'package:shopping_list/data_provider/shopping_list_dp.dart';
import "package:shopping_list/data_provider/shopping_item_dp.dart";
import 'package:intl/intl.dart';
import 'package:shopping_list/ui/shopping_list_fast_create_ui.dart';
import 'package:shopping_list/service/local_notification_service.dart';
import 'package:shopping_list/ui/shopping_list_pop_args.dart';

class ShoppingListUI extends StatefulWidget {
  final ShoppingListDataProvider _shoppingListDataProvider;
  final ShoppingItemDataProvider _shoppingItemDataProvider;
  final LocalNotificationService _localNotificationService;
  ShoppingListUI(this._shoppingListDataProvider, this._shoppingItemDataProvider,
      this._localNotificationService);

  @override
  State<StatefulWidget> createState() => _ShoppingListState(
      _shoppingListDataProvider,
      _shoppingItemDataProvider,
      _localNotificationService);
}

class _ShoppingListState extends State<ShoppingListUI> {
  //TODO DAN ADD CONSTRUCTOR WITH ID
  List<ShoppingList> _shoppingLists;
  final ShoppingListDataProvider _shoppingListDataProvider;
  final ShoppingItemDataProvider _shoppingItemDataProvider;
  final LocalNotificationService _localNotificationService;
  final dateTimeFormater = DateFormat("yyyy-MM-dd");

  _ShoppingListState(this._shoppingListDataProvider,
      this._shoppingItemDataProvider, this._localNotificationService);

  @override
  Widget build(BuildContext context) {
    if (_shoppingLists == null) {
      _shoppingLists = List<ShoppingList>();
      _loadData();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Shopping List"),
      ),
      body: _createShoppingListListView(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _navigateToListItemsImport();
        },
        child: Icon(Icons.add),
        tooltip: "Add new shopping list.",
      ),
    );
  }

  ListView _createShoppingListListView() {
    return ListView.builder(
        itemCount: _shoppingLists.length,
        itemBuilder: (context, index) {
          var shoppingList = _shoppingLists[index];
          return Dismissible(
              key: Key("${shoppingList.id}_${shoppingList.name}"),
              onDismissed: (direction) {
                setState(() {
                  _shoppingListDataProvider.deleteWithItems(shoppingList);
                  _shoppingLists.remove(shoppingList);
                });
                Scaffold.of(context).showSnackBar(SnackBar(
                  content: Text("${shoppingList.name} dismissed"),
                  duration: Duration(seconds: 1),
                ));
              },
              background: Container(color: Colors.grey[300]),
              child: Card(
                  elevation: 2.0,
                  child: ListTile(
                      leading: Icon(
                        Icons.shopping_bag_outlined,
                        size: 50,
                        color: Colors.blue,
                      ),
                      tileColor: _getColorByCheckedItems(shoppingList),
                      title: Text(
                        shoppingList.name,
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle:
                          Text(dateTimeFormater.format(shoppingList.created)),
                      trailing: Wrap(
                        children: [
                          Switch(
                            value: shoppingList.notification,
                            onChanged: (value) {
                              setState(() {
                                shoppingList.notification = value;
                                _showOrCancelNotification(value, shoppingList);
                              });
                            },
                          ),
                          Text(
                            _getCheckedCountFormat(shoppingList),
                            style: TextStyle(
                                fontWeight: FontWeight.w600, fontSize: 16),
                          )
                        ],
                      ),
                      onTap: () =>
                          _navigateToShoppingListItems(shoppingList))));
        });
  }

  void _loadData() {
    _shoppingListDataProvider.fetchWithItems().then((value) {
      setState(() {
        value.sort((a, b) => b.created.compareTo(a.created));
        _shoppingLists = value;
      });
    });
  }

  void _navigateToShoppingListItems(ShoppingList shoppingList) async {
    var result = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ShoppingListItemsUI(shoppingList,
                _shoppingListDataProvider, _shoppingItemDataProvider)));

    var shoppingListPopArgs = result as ShoppingListPopArgs;
    if (shoppingListPopArgs.shoppingListItemAdded) {
      _loadData();
    }

    if (shoppingListPopArgs.shoppinListChanged) {
      _showOrCancelNotification(shoppingListPopArgs.shoppingList.notification,
          shoppingListPopArgs.shoppingList);
    }
  }

  void _navigateToListItemsImport() async {
    var result = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                ShoppingListFastCreateUI(_shoppingListDataProvider)));

    if (result) {
      _loadData();
    }
  }

  String _getCheckedCountFormat(ShoppingList shoppingList) {
    var checkedItemsCount = shoppingList.getCheckedItems();
    return "$checkedItemsCount/${shoppingList.items.length}";
  }

  Color _getColorByCheckedItems(ShoppingList shoppingList) {
    var checkedItemsCount = shoppingList.getCheckedItems();
    if (checkedItemsCount < shoppingList.items.length) {
      return Colors.white;
    }

    return Colors.blue[100];
  }

  void _showOrCancelNotification(bool show, ShoppingList shoppingList) {
    shoppingList.notification = show && !shoppingList.allItemsChecked;
    _localNotificationService.cancelNotification(shoppingList.id);

    if (shoppingList.notification) {
      _localNotificationService.showNotification(shoppingList);
    }
  }
}
