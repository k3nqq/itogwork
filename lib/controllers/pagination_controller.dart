import 'dart:async';
import 'dart:developer';
import 'dart:ffi';
import 'package:quiver/iterables.dart';
import 'package:conduit/conduit.dart';
import 'package:dart_application_1/model/finance_operation.dart';

class PaginationController extends ResourceController {
  final ManagedContext managedContext;

  PaginationController(this.managedContext);

  @Operation.get()
  Future<Response> paginate(
      @Bind.query('page') int page, @Bind.query('limit') int limit) async {
    final query = Query<FinanceOperation>(managedContext)
      ..join(
        object: (x) => x.user,
      )
      ..join(
        object: (x) => x.financeOperationCategory,
      );

    final operations = await query.fetch();

    final pages = partition(operations, limit);

    return Response.ok({
      "meta": {
        "currentPage": page,
        "nextPage": pages.length == page || pages.isEmpty ? null : page + 1,
        "previousPage": page == 1 ? null : page - 1
      },
      "data": _toJSON(pages.elementAt(page - 1)),
    });
  }

  List _toJSON(List<FinanceOperation> operations) {
    final array = [];
    for (var operation in operations) {
      array.add({
        "id": operation.id,
        "name": operation.name,
        "number": operation.number,
        "description": operation.description,
        "date": operation.executionDate.toString(),
        "totalSum": operation.totalSum,
        "user": {
          "id": operation.user!.id,
          "username": operation.user!.username,
          "email": operation.user!.email,
        },
        "financeCategory": {
          "id": operation.financeOperationCategory!.id,
          "name": operation.financeOperationCategory!.name,
        }
      });
    }

    return array;
  }
}
