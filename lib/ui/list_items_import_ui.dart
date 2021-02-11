import 'package:flutter/material.dart';

class ListItemsImportUI extends StatefulWidget {
  ListItemsImportUI();

  @override
  State<StatefulWidget> createState() => _ListItemsImportState();
}

class _ListItemsImportState extends State<ListItemsImportUI> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Fast Create"),
        actions: [
          ElevatedButton(
            child: Icon(
              Icons.arrow_back_ios,
              size: 22,
            ),
            onPressed: _navigateBack,
          )
        ],
      ),
      body: ,
    );
  }

  void _navigateBack() {}
}
