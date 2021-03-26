import 'package:shopping_list/model/shopping_list_m.dart';

class ShoppingListPopArgs {
  bool shoppingListItemAdded;
  bool shoppinListChanged;
  ShoppingList shoppingList;

  ShoppingListPopArgs(this.shoppingListItemAdded);
  ShoppingListPopArgs.withShoppingList(
      this.shoppingListItemAdded, this.shoppinListChanged, this.shoppingList);
}
