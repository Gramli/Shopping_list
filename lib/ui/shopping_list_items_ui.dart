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
  State<StatefulWidget> createState() => _ShoppingListItemsState(
      _shoppingList, _shoppingListDataProvider, _shoppingItemDataProvider);
}

class _ShoppingListItemsState extends State<ShoppingListItemsUI> {
  final ShoppingList _shoppingList;
  final ShoppingListDataProvider _shoppingListDataProvider;
  final ShoppingItemDataProvider _shoppingItemDataProvider;

  final _shoppingListNameController =
      TextControl(TextEditingController(), FocusNode());
  final _shoppingListItemsControllers = new Map<String, TextControl>();

  _ShoppingListItemsState(this._shoppingList, this._shoppingListDataProvider,
      this._shoppingItemDataProvider);

  @override
  void dispose() {
    _shoppingListItemsControllers.forEach((key, value) {
      value.dispose();
    });
    _shoppingListNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _shoppingList.items.sort((a, b) => a.checked ? 1 : -1);
    _shoppingListNameController.nameEditingController.text = _shoppingList.name;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: TextField(
          keyboardType: TextInputType.text,
          style: TextStyle(
              color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
          controller: _shoppingListNameController.nameEditingController,
          onChanged: (value) => {_shoppingList.name = value},
          focusNode: _shoppingListNameController.nameFocusNode,
        ),
        actions: [
          ElevatedButton(
            child: Icon(
              Icons.arrow_back_ios,
              size: 22,
            ),
            onPressed: _saveAndNavigateToShoppingListBack,
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

          WidgetsBinding.instance.addPostFrameCallback((_) {
            var shoppingItemKey = _generateShoppingItemKey(newShoppingItem);
            FocusScope.of(context).requestFocus(
                _shoppingListItemsControllers[shoppingItemKey].nameFocusNode);
          });
        },
        child: Icon(Icons.add),
        tooltip: "Add new shopping list item.",
      ),
    );
  }

  Future _saveAndNavigateToShoppingListBack() async {
    if (_shoppingList.isEmpty) {
      Navigator.pop(context, false);
      return;
    }

    if (_shoppingList.id == null) {
      await _shoppingListDataProvider.insertWithItems(_shoppingList);
    } else {
      await _shoppingListDataProvider.updateWithItems(_shoppingList);
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
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                    fillColor: _getColorByCheckedField(shoppingListItem),
                    filled: true),
                controller: _shoppingListItemsControllers[shoppingItemKey]
                    .nameEditingController,
                focusNode: _shoppingListItemsControllers[shoppingItemKey]
                    .nameFocusNode,
                onChanged: (value) => {shoppingListItem.name = value},
              ),
              controlAffinity: ListTileControlAffinity.trailing,
              value: _shoppingList.items[index].checked,
              onChanged: (value) {
                setState(() {
                  shoppingListItem.checked = value;
                });
              },
            ));
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

  Color _getColorByCheckedField(ShoppingItem shoppingItem) {
    if (!shoppingItem.checked) {
      return Colors.transparent;
    }

    return Colors.blue[100];
  }
}
