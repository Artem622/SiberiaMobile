import 'package:mobile_app_slb/data/models/cart_model.dart';
import 'package:mobile_app_slb/data/models/shop_model.dart';

import 'package:mobile_app_slb/domain/usecases/outcome_usecase.dart';
import 'package:mobile_app_slb/domain/usecases/shops_usecase.dart';

import '../../domain/repository/transfer_repository_impl.dart';
import '../data_sources/local_data.dart';
import '../data_sources/remote_data.dart';
import '../models/error_model.dart';

class TransferRepository extends TransferRepositoryImpl {
  final RemoteData remoteData = RemoteData();
  final LocalData localData = LocalData();

  @override
  Future<OutcomeUseCase> createTransfer(List<CartModel> products, int storeId) async {
    final authData = await localData.getAuthData();
    if (authData != null) {
      final data =
      await remoteData.createTransfer(authData.token, products, storeId);

      if (data is bool) {
        return OutcomeUseCase();
      }
      if ((data as ErrorModel).type != "auth error") {
        await remoteData.bugReport(authData.token,
            "Endpoint: transaction/transfer, Code: ${data
                .statusCode}, description: ${data.statusText}");
      }
      return OutcomeUseCase(errorModel: data);
    }
    return OutcomeUseCase(
        errorModel: ErrorModel("auth error", 401, "Unauthorized"));
  }

  @override
  Future<ShopsUseCase> getAddresses(String name) async {
    final authData = await localData.getAuthData();
    if (authData != null) {
      final data =
      await remoteData.getAddresses(authData.token, name);

      if (data is List<ShopModel>) {
        return ShopsUseCase(shopModels: data);
      }
      if ((data as ErrorModel).type != "auth error") {
        await remoteData.bugReport(authData.token,
            "Endpoint: stock/all, Code: ${data
                .statusCode}, description: ${data.statusText}");
      }
      return ShopsUseCase(errorModel: data);
    }
    return ShopsUseCase(
        errorModel: ErrorModel("auth error", 401, "Unauthorized"));
  }

  @override
  Future<ShopsUseCase> selectAddress(int transactionId, int stockId) async {
    final authData = await localData.getAuthData();
    if (authData != null) {
      final data =
          await remoteData.selectAddress(authData.token, transactionId, stockId);

      if (data is bool) {
        if(data) {
          return ShopsUseCase();
        } else {
          return ShopsUseCase(
              errorModel: ErrorModel("auth error", 401, "Unauthorized"));
        }
      }
      if ((data as ErrorModel).type != "auth error") {
        await remoteData.bugReport(authData.token,
            "Endpoint: /transaction/transfer/$transactionId/4/$stockId, Code: ${data
                .statusCode}, description: ${data.statusText}");
      }
      return ShopsUseCase(errorModel: data);
    }
    return ShopsUseCase(
        errorModel: ErrorModel("auth error", 401, "Unauthorized"));
  }

  @override
  Future<ShopsUseCase> completeTransferAssembly(int transactionId, int stockId) async {
    final authData = await localData.getAuthData();
    if (authData != null) {
      final data =
          await remoteData.completeTransferAssembly(authData.token, transactionId, stockId);

      if (data is bool) {
        return ShopsUseCase();
      }
      if ((data as ErrorModel).type != "auth error") {
        await remoteData.bugReport(authData.token,
            "Endpoint: /transaction/transfer/$transactionId/4/$stockId, Code: ${data
                .statusCode}, description: ${data.statusText}");
      }
      return ShopsUseCase(errorModel: data);
    }
    return ShopsUseCase(
        errorModel: ErrorModel("auth error", 401, "Unauthorized"));
  }

  @override
  Future<ShopsUseCase> getTransfer(int transactionId, List<int> objects, String type) async {
    final authData = await localData.getAuthData();
    if (authData != null) {
      final data =
      await remoteData.getTransfer(authData.token, transactionId, objects, type);

      if (data is bool) {
        return ShopsUseCase();
      }
      if ((data as ErrorModel).type != "auth error") {
        if(type == "all") {
          await remoteData.bugReport(authData.token,
              "Endpoint: /transaction/transfer/$transactionId/6, Code: ${data
                  .statusCode}, description: ${data.statusText}");
        } else if(type == "missing") {
          await remoteData.bugReport(authData.token,
              "Endpoint: /transaction/transfer/$transactionId/7, Code: ${data
                  .statusCode}, description: ${data.statusText}");
        } else {
          await remoteData.bugReport(authData.token,
              "Endpoint: /transaction/transfer/$transactionId/partial, Code: ${data
                  .statusCode}, description: ${data.statusText}");
        }
      }
      return ShopsUseCase(errorModel: data);
    }
    return ShopsUseCase(
        errorModel: ErrorModel("auth error", 401, "Unauthorized"));
  }
}