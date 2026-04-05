import 'dart:async';

import 'package:cl_components/utils/shared_manager.util.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import 'package:cl_components/constants/strings.constant.dart';

class CLBaseViewModel extends BaseViewModel {
  late BuildContext viewContext;
  late VMType viewModelType;
  dynamic extraParams;
  bool isEdit = false;

  CLBaseViewModel({required this.viewContext, required this.viewModelType, this.extraParams});

  Future initialize() async {}

  void logout() async {
    setBusy(true);
    await deleteAllData();
    setBusy(false);
  }

  Future deleteAllData() async {
    SharedManager.setBool(Strings.authenticated, false);
  }
}

enum VMType { list, create, detail, edit, other }
