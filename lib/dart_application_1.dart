import 'dart:io';
import 'package:conduit/conduit.dart';
import 'package:dart_application_1/controllers/action_controller.dart';
import 'package:dart_application_1/controllers/app_auth_controller.dart';
import 'package:dart_application_1/controllers/app_token_controller.dart';
import 'package:dart_application_1/controllers/app_user_controller.dart';
import 'package:dart_application_1/controllers/filter_controller.dart';
import 'package:dart_application_1/controllers/operation_controller.dart';
import 'package:dart_application_1/controllers/pagination_controller.dart';
import 'package:dart_application_1/controllers/recover_operation_controller.dart';
import 'package:dart_application_1/controllers/search_operation_controller.dart';
import 'entity/finance_operation_category_entity.dart';
import 'model/user.dart';
import 'model/finance_operation.dart';
import 'model/operation_category.dart';
import 'package:dart_application_1/model/action_model.dart';

class AppService extends ApplicationChannel {
  late final ManagedContext managedContext;

  @override
  Future prepare() {
    final persistentStore = _initDatabase();

    managedContext = ManagedContext(
        ManagedDataModel.fromCurrentMirrorSystem(), persistentStore);
    return super.prepare();
  }

  @override
  Controller get entryPoint => Router()
    ..route('token/[:refresh]').link(
      () => AppAuthController(managedContext),
    )
    ..route('user')
        .link(AppTokenController.new)!
        .link(() => AppUserController(managedContext))
    ..route('operations/[:operationId]')
        .link(AppTokenController.new)!
        .link(() => OperationController(managedContext))
    ..route('operation-search/')
        .link(AppTokenController.new)!
        .link(() => SearchOperationController(managedContext))
    ..route('operation-paginate/')
        .link(AppTokenController.new)!
        .link(() => PaginationController(managedContext))
    ..route('actions/')
        .link(AppTokenController.new)!
        .link(() => ActionController(managedContext))
    ..route('filter-operations/')
        .link(AppTokenController.new)!
        .link(() => FilterController(managedContext))
    ..route('deleted-operations/[:operationId]')
        .link(AppTokenController.new)!
        .link(() => RecoverOperationController(managedContext));

  PersistentStore _initDatabase() {
    final username = Platform.environment['DB_USERNAME'] ?? 'postgres';
    final password = Platform.environment['DB_PASSWORD'] ?? 'postgrespw';
    final host = Platform.environment['DB_HOST'] ?? 'localhost';
    final port = int.parse(Platform.environment['DB_PORT'] ?? '32768');
    final databaseName = Platform.environment['DB_NAME'] ?? 'finances';
    return PostgreSQLPersistentStore(
        username, password, host, port, databaseName);
  }
}
