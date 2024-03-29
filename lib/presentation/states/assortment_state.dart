import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_app_slb/data/repository/assortment_repository.dart';
import 'package:mobile_app_slb/domain/usecases/assortment_usecase.dart';
import 'package:mobile_app_slb/domain/usecases/availability_usecase.dart';
import 'package:mobile_app_slb/domain/usecases/productinfo_usecase.dart';

final getAssortmentProvider =
    FutureProvider.family<AssortmentUseCase, Map<String, dynamic>>(
        (ref, filters) async {
  final data = await AssortmentRepository().getAssortment(filters);
  return data;
});

final getFiltersProvider = FutureProvider((ref) async {
  final filtersData = await AssortmentRepository().getFiltersData();
  return filtersData;
});

final getAvailabilityProvider =
    ChangeNotifierProvider((ref) => GetAvailabilityNotifier());

class GetAvailabilityNotifier extends ChangeNotifier {
  bool isSearching = false;

  Future<AvailabilityUseCase> getAvailability(int productId) async {
    final data = AssortmentRepository().getAvailability(productId);
    return data;
  }

  void changeSearchingState() {
    isSearching = !isSearching;
    notifyListeners();
  }
}

final getProductInfoProvider =
    FutureProvider.family<ProductInfoUseCase, int>((ref, productId) async {
  final data = await AssortmentRepository().getProductInfo(productId);
  return data;
});
