import 'package:conduit/conduit.dart';
import 'package:dart_application_1/model/finance_operation.dart';
import 'package:dart_application_1/model/response_model.dart';

class FilterController extends ResourceController {
  final ManagedContext managedContext;

  FilterController(this.managedContext);

  @Operation.get()
  Future<Response> filterOperationsByCategory(
      @Bind.query('filterByCategory') int categoryId) async {
    try {
      final query = Query<FinanceOperation>(managedContext)
        ..join(
          object: (x) => x.financeOperationCategory,
        )
        ..where((x) => x.financeOperationCategory!.id).equalTo(categoryId);

      final operations = await query.fetch();
      if (operations.isEmpty) {
        return Response.ok(ModelResponse(message: "Ничего не найдено"));
      }

      return Response.ok(operations);
    } catch (e) {
      return Response.serverError(
          body: ModelResponse(message: "Не удалось отфильтровать данные"));
    }
  }
}
