import 'package:mobile_app_slb/data/data_sources/local_data.dart';
import 'package:mobile_app_slb/data/data_sources/remote_data.dart';
import 'package:mobile_app_slb/data/models/auth_model.dart';
import 'package:mobile_app_slb/data/models/stock_model.dart';
import 'package:mobile_app_slb/domain/repository/auth_repository_impl.dart';
import 'package:mobile_app_slb/domain/usecases/auth_usecase.dart';
import 'package:mobile_app_slb/domain/usecases/stock_usecase.dart';

import '../models/error_model.dart';

class AuthRepository extends AuthRepositoryImpl {
  final RemoteData remoteData = RemoteData();
  final LocalData localData = LocalData();

  @override
  Future<AuthUseCase> loginUser(String qrToken) async {
    final data = await remoteData.loginUser(qrToken);

    if (data is AuthModel) {
      localData.saveAuthData(data);
      return AuthUseCase(authModel: data);
    } else {
      return AuthUseCase(errorModel: data);
    }
  }

  @override
  Future<AuthUseCase> getAuthData() async {
    final data = await localData.getAuthData();
    return AuthUseCase(authModel: data);
  }

  @override
  Future<bool> deleteAuthData() async {
    final data = await localData.deleteAuthData();
    return data;
  }

  @override
  Future<StockUseCase> getStock() async {
    final authData = await localData.getAuthData();
    if (authData != null) {
      final data = await remoteData.getStock(authData.token);

      if (data is StockModel) {
        return StockUseCase(stockModel: data);
      }
      if ((data as ErrorModel).type != "auth error") {
        await remoteData.bugReport(authData.token,
            "Endpoint: auth/mobile/current-stock, Code: ${data
                .statusCode}, description: ${data.statusText}");
      }
      return StockUseCase(errorModel: data);
    }
    return StockUseCase(
        errorModel: ErrorModel("auth error", 401, "Unauthorized"));
  }
}
