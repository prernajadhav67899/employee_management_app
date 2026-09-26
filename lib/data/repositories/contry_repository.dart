import 'package:employee_management_app/constants/api_constant.dart';
import '../../services/api_client.dart';
import '../models/country_model.dart';

abstract class CountryRepository {
  Future<List<Country>> getCountries();
}

class CountryRepositoryImpl implements CountryRepository {
  final ApiClient _api;
  CountryRepositoryImpl({required ApiClient api}) : _api = api;

  @override
  Future<List<Country>> getCountries() async {
    final data = await _api.get(ApiConstants.countries);
    if (data is! List) throw const ApiException('Unexpected list format.');
    return data.whereType<Map<String, dynamic>>().map(Country.fromJson).toList();
  }
}