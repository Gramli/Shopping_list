class ShoppingItem {
  int _id;
  int shoppingListId;
  String name;
  bool checked;

  int get id => _id;

  ShoppingItem(this.name, this.checked, this.shoppingListId);
  ShoppingItem.withId(this._id, this.name, this.shoppingListId, this.checked);
}
