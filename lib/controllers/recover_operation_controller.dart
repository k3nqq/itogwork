import 'dart:developer';
import 'dart:io';

import 'package:conduit/conduit.dart';
import 'package:dart_application_1/model/finance_operation.dart';
import 'package:dart_application_1/model/response_model.dart';

import '../model/user.dart';
import '../utils/app_utils.dart';

class RecoverOperationController extends ResourceController {
  final ManagedContext managedContext;

  RecoverOperationController(this.managedContext);

  @Operation.get()
  Future<Response> getDeletedOperations(
      @Bind.header(HttpHeaders.authorizationHeader) String header) async {
    final id = AppUtils.getIdFromHeader(header);

    final query = Query<User>(managedContext)
      ..where((x) => x.id).equalTo(id)
      ..join(
        set: (x) => x.financialOperations,
      );
    final user = await query.fetchOne();

    final deletedOperations = user!.financialOperations!
        .where((element) => element.deleted == true)
        .toList();
    if (deletedOperations.isEmpty) {
      return Response.ok(ModelResponse(message: "Нет удаленных данных"));
    }

    return Response.ok(deletedOperations);
  }

  @Operation.put("operationId")
  Future<Response> recover(@Bind.path('operationId') int operationId) async {
    final query = Query<FinanceOperation>(managedContext)
      ..where((x) => x.id).equalTo(operationId);
    final operation = await query.fetchOne();

    if (operation == null) {
      return Response.badRequest(
          body: ModelResponse(
              message: "Не удалось найти операцию с id = $operationId"));
    }

    query..values.deleted = false;
    query.updateOne();

    return Response.ok(ModelResponse(message: "Данные успешно восстановлены"));
  }
}
