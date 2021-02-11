import 'package:flutter/material.dart';
import 'package:shopping_list/model/shopping_item_m.dart';
import 'package:shopping_list/model/shopping_list_m.dart';
import 'package:shopping_list/data_provider/shopping_list_dp.dart';
import 'package:shopping_list/data_provider/shopping_item_dp.dart';
import 'package:shopping_list/ui/text_control.dart';

class ShoppingListItemsUI extends StatefulWidget {
  final ShoppingList _shoppingList;
  final ShoppingListDataProvider _shoppingListDataProvider;
  final ShoppingItemDataProvider _shoppingItemDataProvider;

  ShoppingListItemsUI(this._shoppingList, this._shoppingListDataProvider,
      this._shoppingItemDataProvider);

  @override
  State<StatefulWidget> createState() => ShoppingListItemsState(
      _shoppingList, _shoppingListDataProvider, _shoppingItemDataProvider);
}

class ShoppingListItemsState extends State<ShoppingListItemsUI> {
  final ShoppingList _shoppingList;
  final ShoppingListDataProvider _shoppingListDataProvider;
  final ShoppingItemDataProvider _shoppingItemDataProvider;

  final _shoppingListNameController =
      TextControl(TextEditingController(), FocusNode());
  final _shoppingListItemsControllers = new Map<String, TextControl>();

  ShoppingListItemsState(this._shoppingList, this._shoppingListDataProvider,
      this._shoppingItemDataProvider);

  void dispose() {
    _shoppingListItemsControllers.forEach((key, value) {
      value.dispose();
    });
    _shoppingListNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _shoppingListNameController.nameEditingController.text = _shoppingList.name;
    if (_shoppingList.isEmpty) {
      _shoppingListNameController.nameFocusNode.requestFocus();
    }

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: TextField(
          controller: _shoppingListNameController.nameEditingController,
          onChanged: (value) => {_shoppingList.name = value},
          focusNode: _shoppingListNameController.nameFocusNode,
          onEditingComplete: () =>
              _shoppingListNameController.nameFocusNode.unfocus(),
        ),
        actions: [
          ElevatedButton(
            child: Icon(
              Icons.arrow_back_ios,
              size: 22,
            ),
            onPressed: _saveAndNavigateBack,
          )
        ],
      ),
      body: _createItemsListView(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _shoppingListNameController.nameFocusNode.unfocus();
          var newShoppingItem = ShoppingItem("", false, _shoppingList.id);
          setState(() {
            _shoppingList.items.insert(0, newShoppingItem);
          });

          var shoppingItemKey = _generateShoppingItemKey(newShoppingItem);
          WidgetsBinding.instance.addPostFrameCallback((_) {
            FocusScope.of(context).requestFocus(
                _shoppingListItemsControllers[shoppingItemKey].nameFocusNode);
          });
        },
        child: Icon(Icons.add),
        tooltip: "Add new shopping list item.",
      ),
    );
  }

  void _saveAndNavigateBack() {
    if (_shoppingList.isEmpty) {
      Navigator.pop(context, false);
      return;
    }

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
        var shoppingItemKey = _generateShoppingItemKey(shoppingListItem);
        _addNewShoppingItemControl(shoppingListItem, shoppingItemKey);

        return Dismissible(
            key: Key(shoppingItemKey),
            onDismissed: (direction) {
              setState(() {
                _shoppingItemDataProvider.delete(shoppingListItem.id);
                _shoppingList.items.remove(shoppingListItem);
              });
              Scaffold.of(context).showSnackBar(SnackBar(
                  content: Text("${shoppingListItem.name} dismissed"),
                  duration: Duration(seconds: 1)));
            },
            background: Container(color: Colors.blueGrey[100]),
            child: CheckboxListTile(
                title: TextField(
                  controller: _shoppingListItemsControllers[shoppingItemKey]
                      .nameEditingController,
                  focusNode: _shoppingListItemsControllers[shoppingItemKey]
                      .nameFocusNode,
                  onChanged: (value) => {shoppingListItem.name = value},
                  onEditingComplete: () =>
                      _shoppingListItemsControllers[shoppingItemKey]
                          .nameFocusNode
                          .unfocus(),
                ),
                controlAffinity: ListTileControlAffinity.trailing,
                value: _shoppingList.items[index].checked,
                onChanged: (value) {
                  setState(() {
                    shoppingListItem.checked = value;
                  });
                },
                //activeColor: Colors.teal[50],
                checkColor: Colors.blueGrey[200]));
      },
    );
  }

  void _addNewShoppingItemControl(
      ShoppingItem shoppingItem, String shoppingItemKey) {
    var shoppingItemController = _createShoppingItemControl(shoppingItem);
    _shoppingListItemsControllers[shoppingItemKey] = shoppingItemController;
  }

  TextControl _createShoppingItemControl(ShoppingItem shoppingItem) {
    return TextControl(
        TextEditingController(text: shoppingItem.name), FocusNode());
  }

  String _generateShoppingItemKey(ShoppingItem shoppingItem) {
    return "${shoppingItem.id}${shoppingItem.name}${shoppingItem.hashCode}";
  }
}
