import 'package:conduit/conduit.dart';
import 'package:dart_application_1/model/itog_work.dart';
import 'package:dart_application_1/model/response_model.dart';

class Filter extends ResourceController {
  final ManagedContext managedContext;

  Filter(this.managedContext);

  @Operation.get()
  Future<Response> filterOperationsByCategory(
      @Bind.query('filterByCategory') int categoryId) async {
    try {
      final query = Query<ItogWork>(managedContext);

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
