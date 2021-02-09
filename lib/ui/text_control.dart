import 'package:flutter/material.dart';

class TextControl {
  TextEditingController nameEditingController;
  FocusNode nameFocusNode;

  TextControl(this.nameEditingController, this.nameFocusNode);

  void dispose() {
    nameEditingController.dispose();
    nameFocusNode.dispose();
  }
}
