import 'package:flutter/material.dart';
import 'package:shopping_list/data_generator/shopping_list_csv_import_dg.dart';
import 'package:shopping_list/model/shopping_list_m.dart';
import 'package:shopping_list/data_provider/shopping_list_dp.dart';

class ShoppingListFastCreateUI extends StatefulWidget {
  final ShoppingListDataProvider _shoppingListDataProvider;
  ShoppingListFastCreateUI(this._shoppingListDataProvider);

  @override
  State<StatefulWidget> createState() =>
      ShoppingListFastCreateState(_shoppingListDataProvider);
}

class ShoppingListFastCreateState extends State<ShoppingListFastCreateUI> {
  String _shoppingListName;
  String _shoppingListItems;
  final ShoppingListDataProvider _shoppingListDataProvider;
  final ShoppingListCsvImport _shoppingListCsvImport = ShoppingListCsvImport();
  final TextEditingController _shoppingListNameCtrl = TextEditingController();
  final TextEditingController _shoppingListItemsCtrl = TextEditingController();

  ShoppingListFastCreateState(this._shoppingListDataProvider);

  @override
  void dispose() {
    _shoppingListNameCtrl.dispose();
    _shoppingListItemsCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text("Fast Create"),
        actions: [
          ElevatedButton(
            child: Icon(
              Icons.cancel,
              size: 22,
            ),
            onPressed: _cancelAndNavigateBack,
          )
        ],
      ),
      body: Column(
        children: [
          Padding(
              padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
              child: TextField(
                autofocus: true,
                controller: _shoppingListItemsCtrl,
                onChanged: (value) => {_shoppingListName = value},
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Shooping List Name.',
                ),
              )),
          Padding(
              padding: EdgeInsets.only(bottom: 15.0),
              child: TextField(
                keyboardType: TextInputType.multiline,
                maxLines: null,
                controller: _shoppingListNameCtrl,
                onChanged: (value) => {_shoppingListItems = value},
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Write shooping list items separated by comma.',
                ),
              )),
          Row(children: [
            Expanded(
                child: ElevatedButton(
                    child: Icon(
                      Icons.check_sharp,
                      size: 24,
                    ),
                    onPressed: _submitAndNavigateBack))
          ]),
        ],
      ),
    );
  }

  void _cancelAndNavigateBack() {
    Navigator.pop(context, false);
  }

  void _submitAndNavigateBack() async {
    var shoppingListNotEmpty =
        _shoppingListName != null && _shoppingListName.isNotEmpty;
    var itemsNotEmpty =
        _shoppingListItems != null && _shoppingListItems.isNotEmpty;

    if (!shoppingListNotEmpty && !itemsNotEmpty) {
      _cancelAndNavigateBack();
      return;
    }

    var shoppingList = _generateShoppingListItem();
    await _insertShoppingListToDb(shoppingList);
    Navigator.pop(context, true);
  }

  Future _insertShoppingListToDb(ShoppingList shoppingList) async {
    await _shoppingListDataProvider.insertWithItems(shoppingList);
  }

  ShoppingList _generateShoppingListItem() {
    return _shoppingListCsvImport.generate(
        _shoppingListName, _shoppingListItems, ',');
  }
}
