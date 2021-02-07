import 'package:flutter/material.dart';
import 'package:shopping_list/model/shopping_item_m.dart';
import 'package:shopping_list/model/shopping_list_m.dart';
import 'package:shopping_list/data_provider/shopping_list_dp.dart';
import 'package:shopping_list/data_provider/shopping_item_dp.dart';

class ShoppingListItemsUI extends StatefulWidget {
  final ShoppingList _shoppingList;
  final ShoppingListDataProvider _shoppingListDataProvider;
  ShoppingListItemsUI(this._shoppingList, this._shoppingListDataProvider);

  @override
  State<StatefulWidget> createState() =>
      ShoppingListItemsState(_shoppingList, _shoppingListDataProvider);
}

class ShoppingListItemsState extends State<ShoppingListItemsUI> {
  ShoppingList _shoppingList;
  ShoppingListDataProvider _shoppingListDataProvider;
  ShoppingItemDataProvider _shoppingItemDataProvider;

  var _shoppingListNameController = TextEditingController();
  var _shoppingListItemsNamesControllers =
      new Map<String, TextEditingController>();

  ShoppingListItemsState(this._shoppingList, this._shoppingListDataProvider);

  void dispose() {
    _shoppingListItemsNamesControllers.forEach((key, value) {
      value.dispose();
    });

    _shoppingListNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _shoppingListNameController.text = _shoppingList.name;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: TextField(
          controller: _shoppingListNameController,
          onChanged: (value) => {_shoppingList.name = value},
        ),
        actions: [
          OutlinedButton(
            child: Text("Submit"),
            onPressed: _saveAndNavigateBack,
          )
        ],
      ),
      body: _createItemsListView(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            _shoppingList.items
                .insert(0, ShoppingItem("", false, _shoppingList.id));
          });
        },
        child: Icon(Icons.add),
        tooltip: "Add new shopping list item.",
      ),
    );
  }

  void _saveAndNavigateBack() {
    if (_shoppingList.id == null) {
      _shoppingListDataProvider.insertWithItems(_shoppingList);
    } else {
      _shoppingListDataProvider.updateWithItems(_shoppingList);
    }
    Navigator.pop(context, true);
  }

  ListView _createItemsListView() {
    return ListView.builder(
      itemCount: _shoppingList.items.length,
      itemBuilder: (context, index) {
        var shoppingListItem = _shoppingList.items[index];
        var shoppingListItemKey = _createShoppingListItemKey(shoppingListItem);
        var shoppingListItemController =
            TextEditingController(text: shoppingListItem.name);
        _shoppingListItemsNamesControllers[shoppingListItemKey] =
            shoppingListItemController;

        return Dismissible(
            key: Key(shoppingListItemKey),
            onDismissed: (direction) {
              setState(() {
                _shoppingList.items.remove(shoppingListItem);
                _shoppingItemDataProvider.delete(shoppingListItem.id);
              });
              Scaffold.of(context).showSnackBar(SnackBar(
                  content: Text("${shoppingListItem.name} dismissed")));
            },
            background: Container(color: Colors.blueGrey[100]),
            child: CheckboxListTile(
              title: TextField(
                controller: shoppingListItemController,
                onChanged: (value) => {shoppingListItem.name = value},
              ),
              controlAffinity: ListTileControlAffinity.trailing,
              value: _shoppingList.items[index].checked,
              onChanged: (value) {
                setState(() {
                  shoppingListItem.checked = value;
                });
              },
              //activeColor: Colors.teal[50],
              //checkColor: Colors.teal[900],
            ));
      },
    );
  }

  String _createShoppingListItemKey(ShoppingItem shoppingListItem) {
    return "${shoppingListItem.id}_${shoppingListItem.name}";
  }
}
