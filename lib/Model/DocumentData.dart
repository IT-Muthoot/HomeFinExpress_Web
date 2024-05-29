import 'package:flutter/cupertino.dart';

class Document {
  final String title;
  final String key;
  bool isChecked;
  TextEditingController queryController;

  Document({
    required this.title,
    required this.key,
    this.isChecked = false,
    required this.queryController,
  });
}
