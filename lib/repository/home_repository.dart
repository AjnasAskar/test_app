import 'dart:convert';

import 'package:either_dart/either.dart';
import 'package:firebase_auths/data/network/http_request.dart';

import '../model/product_data_model.dart';

class HomeRepository {
  Future<Either<Exceptions, ProductDataModel?>> getHomeData() async {
    ProductDataModel? productDataModel;

    try {
      Either<Exceptions, String> res =
          await HttpReq.getRequest('5dfccffc310000efc8d2c1ad');
      if (res.isRight) {
        List dataList = (jsonDecode(res.right) ?? []) as List;
        if (dataList.isNotEmpty) {
          productDataModel = ProductDataModel.fromJson(dataList.first);
        }
        return Right(productDataModel);
      } else {
        return Left(res.left);
      }
    } catch (_) {
      return const Left(Exceptions.err);
    }
  }
}
