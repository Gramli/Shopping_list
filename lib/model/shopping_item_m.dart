class ShoppingItem {
  int _id;
  int _shoppingListId;
  String name;
  bool checked;

  int get id => _id;
  int get shoppingListId => _shoppingListId;

  ShoppingItem(this.name, this.checked, this._shoppingListId);
  ShoppingItem.withId(this._id, this.name, this._shoppingListId, this.checked);
}
