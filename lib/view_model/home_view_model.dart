import 'package:either_dart/either.dart';
import 'package:firebase_auths/common/consts.dart';
import 'package:firebase_auths/model/product_data_model.dart';
import 'package:firebase_auths/repository/home_repository.dart';
import 'package:flutter/material.dart';

import '../data/network/http_request.dart';

class HomeViewModel extends ChangeNotifier {
  LoadState loadState = LoadState.loaded;

  HomeRepository homeRepository = HomeRepository();
  ProductDataModel? productDataModel;

  Map<String, CategoryDishes?> cartList = {};

  Future<void> getHomeData() async {
    updateLoadState(LoadState.loading);
    Either<Exceptions, ProductDataModel?> res =
        await homeRepository.getHomeData();
    if (res.isLeft) {
      if (res.left == Exceptions.socketErr) {
        updateLoadState(LoadState.noInternet);
        return;
      }
      updateLoadState(LoadState.loaded);
    } else {
      productDataModel = res.right;
      updateLoadState(LoadState.loaded);
    }
  }

  void updateLoadState(LoadState state) {
    loadState = state;
    notifyListeners();
  }

  void addToCartList(
      {required String id, required CategoryDishes? categoryDishes}) {
    if (cartList.containsKey(id)) {
      CategoryDishes? dishes = cartList[id];
      cartList[id] =
          categoryDishes?.copyWith(quantity: ((dishes?.quantity ?? 0) + 1));
      notifyListeners();
    } else {
      cartList[id] = categoryDishes;
      notifyListeners();
    }
  }

  void removeFromCartList(
      {required String id, required CategoryDishes? categoryDishes}) {
    if (cartList.containsKey(id)) {
      CategoryDishes? dishes = cartList[id];
      cartList[id] = categoryDishes?.copyWith(
          quantity:
              (dishes?.quantity ?? 0) > 1 ? (dishes?.quantity ?? 0) - 1 : 0);
      notifyListeners();
    }
  }
}
