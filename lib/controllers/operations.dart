import 'dart:io';
import 'package:dart_application_1/model/itog_work.dart';
import 'package:dart_application_1/model/response_model.dart';
import 'package:conduit/conduit.dart';
import 'package:dart_application_1/model/action_model.dart';
import '../model/user_model.dart';
import '../utils/app_utils.dart';

class Operations extends ResourceController {
  final ManagedContext managedContext;

  Operations(this.managedContext);

  void _createAction(String title, User user) async {
    final qCreateAction = Query<Action>(managedContext)
      ..values.user = user
      ..values.title = title;
    qCreateAction.insert();
  }

  @Operation.post()
  Future<Response> addOperation(
      @Bind.header(HttpHeaders.authorizationHeader) String header,
      @Bind.body() ItogWork itogWork) async {
    try {
      final id = AppUtils.getIdFromHeader(header);

      final qFindUser = Query<User>(managedContext)
        ..where((x) => x.id).equalTo(id)
        ..returningProperties((x) => [x.salt, x.hashPassword]);

      final fUser = await qFindUser.fetchOne();

      final qCreateOperation = Query<ItogWork>(managedContext)
        ..values.name = itogWork.name
        ..values.description = itogWork.description
        ..values.executionDate = DateTime.now()
        ..values.number = itogWork.number
        ..values.totalSum = itogWork.totalSum
        ..values.ItogWorkCategory!.id = itogWork.ItogWorkCategory!.id
        ..values.user = fUser;

      qCreateOperation.insert();

      final user = await managedContext.fetchObjectWithID<User>(id);
      _createAction(
          "Пользователь '${user!.username}' создал новую операцию '${itogWork.name}'",
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
      @Bind.body() ItogWork itogWork,
      @Bind.path('operationId') int operationId) async {
    try {
      final id = AppUtils.getIdFromHeader(header);

      final qFindUser = Query<User>(managedContext)
        ..where((x) => x.id).equalTo(id)
        ..returningProperties((x) => [x.salt, x.hashPassword]);

      final fUser = await qFindUser.fetchOne();
      final oldOperation =
          await managedContext.fetchObjectWithID<ItogWork>(operationId);

      final qUpdateOperation = Query<ItogWork>(managedContext)
        ..where((x) => x.id).equalTo(operationId)
        ..values.name = itogWork.name
        ..values.description = itogWork.description
        ..values.executionDate = DateTime.now()
        ..values.number = itogWork.number
        ..values.totalSum = itogWork.totalSum
        ..values.ItogWorkCategory!.id = itogWork.ItogWorkCategory!.id
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
          await managedContext.fetchObjectWithID<ItogWork>(operationId);
      var query = Query<ItogWork>(managedContext)
        ..where((x) => x.id).equalTo(operationId);

      //await query.delete();
      query..values.deleted = false;
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
  Future<Response> getAllOperations(
    @Bind.header(HttpHeaders.authorizationHeader) String header,
  ) async {
    try {
      final id = AppUtils.getIdFromHeader(header);
      final user = await managedContext.fetchObjectWithID<User>(id);

      var query = Query<ItogWork>(managedContext)
        ..join(
          object: (x) => x.user,
        );

      List<ItogWork> operations = await query.fetch();

      for (var operation in operations) {
        operation.user!
            .removePropertiesFromBackingMap(['accessToken', 'refToken']);
      }

      return Response.ok(operations);
    } catch (e) {
      return Response.badRequest(
          body: ModelResponse(message: "Не удалось получить информацию"));
    }
  }

  @Operation.get("operationId")
  Future<Response> getOperationById(
      @Bind.path('operationId') int operationId) async {
    try {
      var query = Query<ItogWork>(managedContext)
        ..join(object: (x) => x.user)
        ..where((x) => x.id).equalTo(operationId);

      final operation = await query.fetchOne();

      if (operation == null) {
        return Response.badRequest(
            body: ModelResponse(message: "Номер данной операции не найден"));
      }

      operation.user!
          .removePropertiesFromBackingMap(['refToken', 'accessToken']);
      return Response.ok(operation);
    } catch (e) {
      return Response.badRequest(
          body: ModelResponse(message: "Не удалось получить данные"));
    }
  }
}
