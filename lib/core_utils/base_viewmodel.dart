import 'dart:async';

import 'package:cl_components/utils/shared_manager.util.dart';
import 'package:cl_components/models/pageaction.model.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

class CLBaseViewModel extends BaseViewModel {
  late BuildContext viewContext;
  late VMType viewModelType;
  dynamic extraParams;
  bool isEdit = false;

  CLBaseViewModel({required this.viewContext, required this.viewModelType, this.extraParams});

  Future initialize({List<PageAction>? pageActions}) async {}

  void logout() async {
    setBusy(true);
    await deleteAllData();
    setBusy(false);
  }

  Future deleteAllData() async {
    SharedManager.setBool('authenticated', false);
  }
}

enum VMType { list, create, detail, edit, other }
