import 'package:shopping_list/model/shopping_item_m.dart';
import 'package:shopping_list/model/shopping_list_m.dart';

class ShoppingListCsvImport {
  static const String whiteSpace = " ";

  ShoppingList generate(
      String shoppingListName, String shoppingListItems, String charSeparator) {
    if (shoppingListName == null) {
      throw ArgumentError("shoppingListName argument is null");
    }

    var shoppingListNotEmpty =
        shoppingListName != null && shoppingListName.isNotEmpty;

    var newShoppingList = ShoppingList(shoppingListName, DateTime.now());
    if (shoppingListNotEmpty) {
      shoppingListItems.split(charSeparator).forEach((shoppingItemName) {
        var formatedShoppintItemName =
            _removeWhitespaceBeforeAndAfter(shoppingItemName);
        var shoppingItem =
            ShoppingItem(formatedShoppintItemName, false, newShoppingList.id);
        newShoppingList.items.add(shoppingItem);
      });
    }

    return newShoppingList;
  }

  String _removeWhitespaceBeforeAndAfter(String value) {
    return value.trimLeft().trimRight();
  }
}
