// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;
import 'package:lely_assignment/feature/activity/data/datasources/activity_datasources.dart'
    as _i866;
import 'package:lely_assignment/feature/activity/data/datasources/robot_activity_local_datasource.dart'
    as _i307;
import 'package:lely_assignment/feature/activity/data/repositories/mock_robot_activity_repository.dart'
    as _i834;
import 'package:lely_assignment/feature/activity/domain/repositories/robot_activity_repository.dart'
    as _i1057;
import 'package:lely_assignment/feature/activity/presentation/cubit/activity_cubit.dart'
    as _i455;
import 'package:lely_assignment/feature/authentication/data/repositories/mock_authentication_repository.dart'
    as _i880;
import 'package:lely_assignment/feature/authentication/domain/repositories/authentication_repository.dart'
    as _i217;
import 'package:lely_assignment/feature/authentication/domain/validators/username_validator.dart'
    as _i638;
import 'package:lely_assignment/feature/authentication/presentation/cubit/authentication_cubit.dart'
    as _i303;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    gh.lazySingleton<_i638.UsernameValidator>(
      () => const _i638.UsernameValidator(),
    );
    gh.lazySingleton<_i217.AuthenticationRepository>(
      () => _i880.MockAuthenticationRepository(),
    );
    gh.lazySingleton<_i307.RobotActivityLocalDataSource>(
      () => const _i866.AssetRobotActivityDataSource(),
    );
    gh.lazySingleton<_i1057.RobotActivityRepository>(
      () => _i834.MockRobotActivityRepository(
        gh<_i307.RobotActivityLocalDataSource>(),
      ),
    );
    gh.factory<_i303.AuthenticationCubit>(
      () => _i303.AuthenticationCubit(
        gh<_i217.AuthenticationRepository>(),
        gh<_i638.UsernameValidator>(),
      ),
    );
    gh.factory<_i455.ActivityCubit>(
      () => _i455.ActivityCubit(gh<_i1057.RobotActivityRepository>()),
    );
    return this;
  }
}
