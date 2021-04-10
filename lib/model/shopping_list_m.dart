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
      _items = <ShoppingItem>[];
    }
    return _items;
  }

  bool notification = false;

  bool get isEmpty {
    return _id == null && (name == "" || name == null) && (items.length == 0);
  }

  bool get allItemsChecked {
    return getCheckedItems() == items.length;
  }

  ShoppingList(this.name, this._created);
  ShoppingList.withId(this._id, this.name, this._created, this.notification);

  int getCheckedItems() {
    var checked = 0;
    items.forEach((item) {
      if (item.checked) {
        checked++;
      }
    });
    return checked;
  }
}
