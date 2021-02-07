import 'package:flutter/material.dart';
import 'package:shopping_list/model/shopping_list_m.dart';
import 'package:shopping_list/ui/shopping_list_items_ui.dart';
import 'package:shopping_list/data_provider/shopping_list_dp.dart';

class ShoppingListUI extends StatefulWidget {
  final ShoppingListDataProvider _shoppingListDataProvider;
  ShoppingListUI(this._shoppingListDataProvider);

  @override
  State<StatefulWidget> createState() =>
      ShoppingListState(_shoppingListDataProvider);
}

class ShoppingListState extends State<ShoppingListUI> {
  List<ShoppingList> _shoppingLists;
  ShoppingListDataProvider _shoppingListDataProvider;

  ShoppingListState(this._shoppingListDataProvider);

  @override
  Widget build(BuildContext context) {
    if (_shoppingLists == null) {
      _shoppingLists = List<ShoppingList>();
      _loadData();
    }

    return Scaffold(
      body: _createShoppingListListView(),
      floatingActionButton: FloatingActionButton(
        onPressed: () =>
            _navigateToShoppingListItems(ShoppingList("", DateTime.now())),
        child: Icon(Icons.add),
        tooltip: "Add new shopping list.",
      ),
    );
  }

  void _navigateToShoppingListItems(ShoppingList shoppingList) async {
    var result = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                ShoppingListItemsUI(shoppingList, _shoppingListDataProvider)));

    if (result) {}
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
                  _shoppingLists.remove(shoppingList);
                  _shoppingListDataProvider.deleteWithItems(shoppingList);
                });
                Scaffold.of(context).showSnackBar(
                    SnackBar(content: Text("${shoppingList.name} dismissed")));
              },
              background: Container(color: Colors.blueGrey[100]),
              child: Card(
                  color: Colors.white,
                  elevation: 2.0,
                  child: ListTile(
                      leading: Icon(
                        Icons.list,
                        size: 50,
                        color: Colors.blue,
                      ),
                      title: Text(shoppingList.name),
                      subtitle: Text(shoppingList.created.toString()),
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
}
