import 'dart:io';

import 'package:conduit/conduit.dart';
import 'package:dart_application_1/model/response_model.dart';

import '../model/user.dart';
import '../utils/app_utils.dart';

class ActionController extends ResourceController {
  final ManagedContext managedContext;

  ActionController(this.managedContext);

  @Operation.get()
  Future<Response> getCurrentUserActions(
      @Bind.header(HttpHeaders.authorizationHeader) String header) async {
    try {
      final id = AppUtils.getIdFromHeader(header);

      final query = Query<User>(managedContext)
        ..where((x) => x.id).equalTo(id)
        ..join(
          set: (x) => x.actions,
        );
      final user = await query.fetchOne();

      return Response.ok(user!.actions);
    } catch (e) {
      return Response.serverError(
          body: ModelResponse(message: "Не удалось получить историю действия"));
    }
  }
}
