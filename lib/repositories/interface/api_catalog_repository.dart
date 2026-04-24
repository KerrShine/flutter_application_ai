import 'package:flutter_application_ai/model/api_definition.dart';
import 'package:flutter_application_ai/unit/base/result.dart';

abstract class ApiCatalogRepository {
  Future<Result<List<ApiDefinition>>> loadApiList();
  Future<Result<List<ApiDefinition>>> loadDropdownApiList();
}
