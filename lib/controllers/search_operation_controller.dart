import 'dart:developer';
import 'dart:io';

import 'package:conduit/conduit.dart';
import 'package:dart_application_1/model/finance_operation.dart';
import 'package:dart_application_1/model/response_model.dart';

import '../model/user.dart';
import '../utils/app_utils.dart';

class SearchOperationController extends ResourceController {
  final ManagedContext managedContext;

  SearchOperationController(this.managedContext);

  @Operation.get()
  Future<Response> searchOperation(@Bind.query('name') String name) async {
    try {
      var query = Query<FinanceOperation>(managedContext)
        ..where((x) => x.name).contains(name, caseSensitive: false)
        ..join(
          object: (x) => x.user,
        )
        ..join(object: (x) => x.financeOperationCategory);

      List<FinanceOperation> operations = await query.fetch();

      if (operations.isEmpty) {
        return Response.ok(ModelResponse(message: "Ничего не найдено"));
      }

      for (var operation in operations) {
        operation.user!
            .removePropertiesFromBackingMap(['accessToken', 'refreshToken']);
      }

      return Response.ok(operations);
    } catch (e) {
      return Response.badRequest(
          body: ModelResponse(message: "Не удалось найти данные"));
    }
  }
}
