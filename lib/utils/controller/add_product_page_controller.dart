import 'package:flutter/material.dart';

import '../models/all_product_page_model.dart';

class AllProductPageController extends ChangeNotifier {
  bool isShimmer = false;
  AllProductPageModel addProductPageModel = AllProductPageModel(
    title: "",
    qty: 0,
    department: "DAIRY & FROZEN",
    description: "",
    price: 0,
  );

  void changeShimmer() {
    isShimmer = true;
    notifyListeners();
  }

  void addProduct({required String val}) {
    addProductPageModel.department = val;
    notifyListeners();
  }

  void getTitle({required String val}) {
    addProductPageModel.title = val;
    notifyListeners();
  }

  void getDescription({required String val}) {
    addProductPageModel.description = val;
    notifyListeners();
  }

  void getQty({required int val}) {
    addProductPageModel.qty = val;
    notifyListeners();
  }

  void getPrice({required int val}) {
    addProductPageModel.price = val;
    notifyListeners();
  }
}
