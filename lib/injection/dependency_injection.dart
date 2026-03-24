import 'package:get_it/get_it.dart';
import 'package:flutter_application_ai/repositories/interface/login_repository.dart';
import 'package:flutter_application_ai/repositories/login_repository_impl.dart';
import 'package:flutter_application_ai/service/login_service.dart';
import 'package:flutter_application_ai/page/login/bloc/login_bloc.dart';
import 'package:flutter_application_ai/page/home/bloc/home_bloc.dart';
import 'package:flutter_application_ai/data/remote/dio_client.dart';
import 'package:flutter_application_ai/repositories/interface/form_section_design_repository.dart';
import 'package:flutter_application_ai/repositories/form_section_design_repository_impl.dart';
import 'package:flutter_application_ai/service/form_section_design_service.dart';
import 'package:flutter_application_ai/page/form_design/form_section_design/bloc/form_section_design_bloc.dart';
import 'package:flutter_application_ai/service/main_service.dart';
import 'package:flutter_application_ai/page/main/bloc/main_bloc.dart';
import 'package:flutter_application_ai/data/local/local_storage.dart';
import 'package:flutter_application_ai/data/local/local_storage_factory.dart';
import 'package:flutter_application_ai/data/tempData/temp_data_storage.dart';
import 'package:flutter_application_ai/data/tempData/temp_data_storage_factory.dart';

import 'package:flutter_application_ai/repositories/interface/form_repository.dart';
import 'package:flutter_application_ai/repositories/form_repository_impl.dart';
import 'package:flutter_application_ai/service/form_create_service.dart';
import 'package:flutter_application_ai/page/form_design/form_create/bloc/form_create_bloc.dart';
import 'package:flutter_application_ai/service/form_manage_service.dart';
import 'package:flutter_application_ai/page/form_design/form_manage/bloc/form_manage_bloc.dart';
import 'package:flutter_application_ai/repositories/interface/section_repository.dart';
import 'package:flutter_application_ai/repositories/section_repository_impl.dart';
import 'package:flutter_application_ai/service/form_design_service.dart';
import 'package:flutter_application_ai/page/form_design/form_design_config/bloc/form_design_bloc.dart';
import 'package:flutter_application_ai/repositories/interface/form_browse_repository.dart';
import 'package:flutter_application_ai/repositories/form_browse_repository_impl.dart';
import 'package:flutter_application_ai/service/form_browse_service.dart';
import 'package:flutter_application_ai/page/form_design/form_browse/bloc/form_browse_bloc.dart';
import 'package:flutter_application_ai/repositories/interface/org_design_repository.dart';
import 'package:flutter_application_ai/repositories/org_design_repository_impl.dart';
import 'package:flutter_application_ai/service/org_design_service.dart';
import 'package:flutter_application_ai/page/org_design/org_manager/bloc/org_manager_bloc.dart';
import 'package:flutter_application_ai/page/org_design/org_design_config/bloc/org_design_config_bloc.dart';
import 'package:flutter_application_ai/page/org_design/org_tree_design/bloc/org_tree_design_bloc.dart';

final sl = GetIt.instance;

Future<void> initDI() async {
  // 1. Data Sources
  sl.registerLazySingleton<DioClient>(() => DioClient(baseUrl: ''));

  final localStorage = createStorage();
  await localStorage.init();
  sl.registerSingleton<LocalStorage>(localStorage);

  final tempDataStorage = createTempDataStorage(localStorage);
  await tempDataStorage.init();
  sl.registerSingleton<TempDataStorage>(tempDataStorage);

  // final db = await DBInit().database;
  // sl.registerSingleton<Database>(db);

  // 2. Repository
  sl.registerFactory<LoginRepository>(
      () => LoginRepositoryImpl(sl<DioClient>()));
  sl.registerFactory<FormSectionDesignRepository>(
      () => FormSectionDesignRepositoryImpl(sl<LocalStorage>()));
  sl.registerFactory<FormRepository>(
      () => FormRepositoryImpl(sl<LocalStorage>()));
  sl.registerFactory<SectionRepository>(
      () => SectionRepositoryImpl(sl<LocalStorage>()));
  sl.registerFactory<FormBrowseRepository>(
      () => FormBrowseRepositoryImpl(sl<LocalStorage>()));
  sl.registerFactory<OrgDesignRepository>(() => OrgDesignRepositoryImpl(
        sl<LocalStorage>(),
        sl<TempDataStorage>(),
      ));

  // 3. Service
  sl.registerFactory<LoginService>(() => LoginService(sl<LoginRepository>()));
  sl.registerFactory<FormSectionDesignService>(() => FormSectionDesignService(
        sl<FormSectionDesignRepository>(),
        sl<SectionRepository>(),
      ));
  sl.registerFactory<FormCreateService>(
      () => FormCreateService(sl<FormRepository>()));
  sl.registerFactory<FormManageService>(
      () => FormManageService(sl<FormRepository>()));
  sl.registerFactory<FormDesignService>(
      () => FormDesignService(sl<SectionRepository>(), sl<FormRepository>()));
  sl.registerFactory<FormBrowseService>(
      () => FormBrowseService(sl<FormBrowseRepository>()));
  sl.registerFactory<OrgDesignService>(
      () => OrgDesignService(sl<OrgDesignRepository>()));
  sl.registerFactory<MainService>(() => MainService());

  // 4. Bloc
  sl.registerFactory<LoginBloc>(() => LoginBloc(sl<LoginService>()));
  sl.registerFactory<HomeBloc>(() => HomeBloc());
  sl.registerFactory<FormSectionDesignBloc>(
      () => FormSectionDesignBloc(sl<FormSectionDesignService>()));
  sl.registerFactory<FormCreateBloc>(
      () => FormCreateBloc(sl<FormCreateService>()));
  sl.registerFactory<FormManageBloc>(
      () => FormManageBloc(sl<FormManageService>()));
  sl.registerFactory<FormDesignBloc>(
      () => FormDesignBloc(sl<FormDesignService>()));
  sl.registerFactory<FormBrowseBloc>(
      () => FormBrowseBloc(sl<FormBrowseService>()));
  sl.registerFactory<OrgManagerBloc>(
      () => OrgManagerBloc(sl<OrgDesignService>()));
  sl.registerFactory<OrgDesignConfigBloc>(
      () => OrgDesignConfigBloc(sl<OrgDesignService>()));
  sl.registerFactory<OrgTreeDesignBloc>(
      () => OrgTreeDesignBloc(sl<OrgDesignService>()));
  sl.registerFactory<MainBloc>(() => MainBloc(sl<MainService>()));
}
