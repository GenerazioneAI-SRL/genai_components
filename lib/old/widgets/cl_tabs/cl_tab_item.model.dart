import 'package:flutter/material.dart';

class CLTabItem {
  String tabName;
  Widget tabContent;
  IconData? icon;

  CLTabItem({required this.tabName, required this.tabContent, this.icon});
}