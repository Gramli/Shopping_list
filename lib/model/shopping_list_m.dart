import 'package:shopping_list/model/shopping_item_m.dart';

class ShoppingList {
  int _id;
  String name;
  DateTime _created;
  List<ShoppingItem> _items;

  int get id => _id;
  DateTime get created => _created;
  List<ShoppingItem> get items {
    if (_items == null) {
      _items = List<ShoppingItem>();
    }
    return _items;
  }

  ShoppingList(this.name, this._created);
  ShoppingList.withId(this._id, this.name, this._created);
}
