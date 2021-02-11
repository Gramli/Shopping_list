import 'package:flutter/material.dart';
import 'package:shopping_list/model/shopping_list_m.dart';
import 'package:shopping_list/ui/shopping_list_items_ui.dart';
import 'package:shopping_list/data_provider/shopping_list_dp.dart';
import "package:shopping_list/data_provider/shopping_item_dp.dart";
import 'package:intl/intl.dart';

class ShoppingListUI extends StatefulWidget {
  final ShoppingListDataProvider _shoppingListDataProvider;
  final ShoppingItemDataProvider _shoppingItemDataProvider;
  ShoppingListUI(
      this._shoppingListDataProvider, this._shoppingItemDataProvider);

  @override
  State<StatefulWidget> createState() =>
      _ShoppingListState(_shoppingListDataProvider, _shoppingItemDataProvider);
}

class _ShoppingListState extends State<ShoppingListUI> {
  List<ShoppingList> _shoppingLists;
  ShoppingListDataProvider _shoppingListDataProvider;
  final ShoppingItemDataProvider _shoppingItemDataProvider;
  final dateTimeFormater = DateFormat("yyyy-MM-dd");

  _ShoppingListState(
      this._shoppingListDataProvider, this._shoppingItemDataProvider);

  @override
  Widget build(BuildContext context) {
    if (_shoppingLists == null) {
      _shoppingLists = List<ShoppingList>();
      _loadData();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Shopping List"),
        actions: [
          ElevatedButton(
            child: Icon(
              Icons.download_sharp,
              size: 22,
            ),
            onPressed: () => {},
          )
        ],
      ),
      body: _createShoppingListListView(),
      floatingActionButton: FloatingActionButton(
        onPressed: () =>
            _navigateToShoppingListItems(ShoppingList("", DateTime.now())),
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
                  //color: _getBackGroundColor(shoppingList),
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
}
