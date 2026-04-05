import 'dart:async';

import 'package:cl_components/utils/providers/navigation.util.provider.dart';
import 'package:cl_components/utils/shared_manager.util.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stacked/stacked.dart';

import 'package:cl_components/constants/strings.constant.dart';
import 'package:cl_components/utils/models/pageaction.model.dart';

class CLBaseViewModel extends BaseViewModel {
  late BuildContext viewContext;
  late VMType viewModelType;
  dynamic extraParams;
  bool isEdit = false;

  CLBaseViewModel({required this.viewContext, required this.viewModelType, this.extraParams});

  Future initialize({List<PageAction>? pageActions}) async {
    //await updateUserData();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setPageActions(pageActions: pageActions ?? []);
    });
  }

  void setPageActions({List<PageAction> pageActions = const []}) {
    final navigationState = Provider.of<NavigationState>(viewContext, listen: false);
    navigationState.setPageActions(pageActions);
  }

  void logout() async {
    setBusy(true);
    await deleteAllData();
    setBusy(false);
  }

  Future deleteAllData() async {
    //await AppDatabase.deleteCurrentUser();
    SharedManager.setBool(Strings.authenticated, false);
  }
}

enum VMType { list, create, detail, edit, other }
