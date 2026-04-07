import 'package:flutter_application_ai/model/org_design_config_model.dart';
import 'package:flutter_application_ai/unit/base/result.dart';

abstract class OrgDesignRepository {
  Future<Result<OrgDesignConfigModel>> loadConfig();
  Future<Result<bool>> saveConfig(OrgDesignConfigModel config);
  Future<Result<bool>> deleteConfig();
  Future<Result<OrgDesignConfigModel?>> loadTreeDesignFile();
  Future<Result<bool>> saveTreeDesignFile(OrgDesignConfigModel config);
  Future<Result<bool>> deleteTreeDesignFile();
}
