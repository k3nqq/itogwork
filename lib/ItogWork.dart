import 'dart:io';
import 'package:conduit/conduit.dart';
import 'package:dart_application_1/controllers/controllerv1.dart';
import 'package:dart_application_1/controllers/auth.dart';
import 'package:dart_application_1/controllers/token_controller.dart';
import 'package:dart_application_1/controllers/user_contrl.dart';
import 'package:dart_application_1/controllers/filter.dart';
import 'package:dart_application_1/controllers/operations.dart';
import 'package:dart_application_1/controllers/pagination.dart';
import 'package:dart_application_1/controllers/recover_controller.dart';
import 'package:dart_application_1/controllers/search_controller.dart';
import 'package:dart_application_1/controllers/user_contrl.dart';
import 'entity/finance_operation_category_entity.dart';
import 'model/user_model.dart';
import 'model/itog_work.dart';
import 'model/operation_model.dart';
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
    ..route('token/[:ref]').link(
      () => Auth(managedContext),
    )
    ..route('user').link(() => Controllerv1(managedContext))
    ..route('filter/')
        .link(TokenController.new)!
        .link(() => user_contrl(managedContext))
    ..route('operations/[:operationId]')
        .link(TokenController.new)!
        .link(() => Operations(managedContext))
    ..route('search/')
        .link(TokenController.new)!
        .link(() => SearchController(managedContext))
    ..route('actions/')
        .link(TokenController.new)!
        .link(TokenController.new)!
        .link(() => Filter(managedContext))
    ..route('deleted/[:operationId]')
        .link(TokenController.new)!
        .link(() => RecoverController(managedContext))
    ..route('paginate/')
        .link(TokenController.new)!
        .link(() => Pagination(managedContext));

  PersistentStore _initDatabase() {
    final host = Platform.environment['DB_HOST'] ?? 'localhost';
    final port = int.parse(Platform.environment['DB_PORT'] ?? '32768');
    final databaseName = Platform.environment['DB_NAME'] ?? 'itogwork';
    final user = Platform.environment['DB_USER'] ?? 'postgres';
    final pass = Platform.environment['DB_PASS'] ?? 'postgrespw';
    return PostgreSQLPersistentStore(user, pass, host, port, databaseName);
  }
}
