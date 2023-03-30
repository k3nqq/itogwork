import 'dart:io';

import 'package:conduit/conduit.dart';
import 'package:dart_application_1/model/action_model.dart';
import 'package:dart_application_1/model/finance_operation.dart';
import 'package:dart_application_1/model/response_model.dart';

import '../model/user.dart';
import '../utils/app_utils.dart';

class OperationController extends ResourceController {
  final ManagedContext managedContext;

  OperationController(this.managedContext);

  void _createAction(String title, User user) async {
    final qCreateAction = Query<Action>(managedContext)
      ..values.user = user
      ..values.title = title;
    qCreateAction.insert();
  }

  @Operation.post()
  Future<Response> addOperation(
      @Bind.header(HttpHeaders.authorizationHeader) String header,
      @Bind.body() FinanceOperation financeOperation) async {
    try {
      final id = AppUtils.getIdFromHeader(header);

      final qFindUser = Query<User>(managedContext)
        ..where((x) => x.id).equalTo(id)
        ..returningProperties((x) => [x.salt, x.hashPassword]);

      final fUser = await qFindUser.fetchOne();

      final qCreateOperation = Query<FinanceOperation>(managedContext)
        ..values.name = financeOperation.name
        ..values.description = financeOperation.description
        ..values.executionDate = DateTime.now()
        ..values.number = financeOperation.number
        ..values.totalSum = financeOperation.totalSum
        ..values.financeOperationCategory!.id =
            financeOperation.financeOperationCategory!.id
        ..values.user = fUser;

      qCreateOperation.insert();

      final user = await managedContext.fetchObjectWithID<User>(id);
      _createAction(
          "Пользователь '${user!.username}' создал новую операцию '${financeOperation.name}'",
          user);

      return Response.ok(ModelResponse(message: "Операция создана"));
    } on QueryException catch (e) {
      return Response.badRequest(
          body: ModelResponse(
              message: "Не удалось добавить данные", error: e.message));
    }
  }

  @Operation.put('operationId')
  Future<Response> updateOperation(
      @Bind.header(HttpHeaders.authorizationHeader) String header,
      @Bind.body() FinanceOperation financeOperation,
      @Bind.path('operationId') int operationId) async {
    try {
      final id = AppUtils.getIdFromHeader(header);

      final qFindUser = Query<User>(managedContext)
        ..where((x) => x.id).equalTo(id)
        ..returningProperties((x) => [x.salt, x.hashPassword]);

      final fUser = await qFindUser.fetchOne();
      final oldOperation =
          await managedContext.fetchObjectWithID<FinanceOperation>(operationId);

      final qUpdateOperation = Query<FinanceOperation>(managedContext)
        ..where((x) => x.id).equalTo(operationId)
        ..values.name = financeOperation.name
        ..values.description = financeOperation.description
        ..values.executionDate = DateTime.now()
        ..values.number = financeOperation.number
        ..values.totalSum = financeOperation.totalSum
        ..values.financeOperationCategory!.id =
            financeOperation.financeOperationCategory!.id
        ..values.user!.id = fUser!.id;

      qUpdateOperation.updateOne();

      final user = await managedContext.fetchObjectWithID<User>(id);
      _createAction(
          "Пользователь '${user!.username}' изменил операцию '${oldOperation!.name}'",
          user);

      return Response.ok(ModelResponse(message: "Операция изменена"));
    } catch (e) {
      return Response.badRequest(
          body: ModelResponse(message: "Не удалось обновить данные"));
    }
  }

  @Operation.delete('operationId')
  Future<Response> deleteOperation(
      @Bind.header(HttpHeaders.authorizationHeader) String header,
      @Bind.path('operationId') int operationId) async {
    try {
      final id = AppUtils.getIdFromHeader(header);
      final operation =
          await managedContext.fetchObjectWithID<FinanceOperation>(operationId);
      var query = Query<FinanceOperation>(managedContext)
        ..where((x) => x.id).equalTo(operationId);

      //await query.delete();
      query..values.deleted = true;
      query.updateOne();

      final user = await managedContext.fetchObjectWithID<User>(id);
      _createAction(
          "Пользователь '${user!.username}' удалил операцию '${operation!.name}'",
          user);
      return Response.ok(ModelResponse(message: "Операция удалена"));
    } catch (e) {
      return Response.badRequest(
          body: ModelResponse(message: "Не удалось удалить данные"));
    }
  }

  @Operation.get()
  Future<Response> getAllOperations(@Bind.header(HttpHeaders.authorizationHeader) String header,) async {
    try {
      final id = AppUtils.getIdFromHeader(header);
      final user = await managedContext.fetchObjectWithID<User>(id);

      var query = Query<FinanceOperation>(managedContext)
        ..join(
          object: (x) => x.user,
        )
        ..join(
          object: (x) => x.financeOperationCategory,
        )..where((x) => x.user!.id).equalTo(id);

      List<FinanceOperation> operations = await query.fetch();

      for (var operation in operations) {
        operation.user!
            .removePropertiesFromBackingMap(['accessToken', 'refreshToken']);
      }

      return Response.ok(operations);
    } catch (e) {
      return Response.badRequest(
          body: ModelResponse(message: "Не удалось получить данные"));
    }
  }

  @Operation.get("operationId")
  Future<Response> getOperationById(
      @Bind.path('operationId') int operationId) async {
    try {
      var query = Query<FinanceOperation>(managedContext)
        ..join(object: (x) => x.user)
        ..join(
          object: (x) => x.financeOperationCategory,
        )
        ..where((x) => x.id).equalTo(operationId);

      final operation = await query.fetchOne();

      if (operation == null) {
        return Response.badRequest(
            body: ModelResponse(message: "Операция с таким ID не найдена"));
      }

      operation.user!
          .removePropertiesFromBackingMap(['refreshToken', 'accessToken']);
      return Response.ok(operation);
    } catch (e) {
      return Response.badRequest(
          body: ModelResponse(message: "Не удалось получить данные"));
    }
  }
}
