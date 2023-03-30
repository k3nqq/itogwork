import 'dart:async';
import 'dart:io';

import 'package:conduit/conduit.dart';
import 'package:dart_application_1/model/response_model.dart';
import 'package:dart_application_1/utils/app_utils.dart';

import '../model/user.dart';

class AppUserController extends ResourceController {
  AppUserController(this.managedContext);

  final ManagedContext managedContext;

  @Operation.get()
  Future<Response> getProfile(
      @Bind.header(HttpHeaders.authorizationHeader) String header) async {
    try {
      final id = AppUtils.getIdFromHeader(header);

      final user = await managedContext.fetchObjectWithID<User>(id);

      user!.removePropertiesFromBackingMap(['refreshToken', 'accessToken']);

      return Response.ok(ModelResponse(
          data: user.backing.contents, message: 'Профиль успешно получен'));
    } catch (e) {
      return Response.serverError(
          body: ModelResponse(message: 'Не удалось получить профиль'));
    }
  }

  @Operation.post()
  Future<Response> updateProfile(
      @Bind.header(HttpHeaders.authorizationHeader) String header,
      @Bind.body() User user) async {
    try {
      final id = AppUtils.getIdFromHeader(header);

      var fUser = await managedContext.fetchObjectWithID<User>(id);

      final qUpdateUser = Query<User>(managedContext)
        ..where((x) => x.id).equalTo(id)
        ..values.username = user.username ?? fUser!.username
        ..values.email = user.email ?? fUser!.email;

      await qUpdateUser.updateOne();

      fUser = await managedContext.fetchObjectWithID<User>(id);

      fUser!.removePropertiesFromBackingMap(['refreshToken', 'accessToken']);
      return Response.ok(ModelResponse(
          data: fUser.backing.contents, message: 'Данные успешно обновлены'));
    } catch (e) {
      return Response.serverError(
          body: ModelResponse(message: 'Не удалось обновить профиль'));
    }
  }

  @Operation.put()
  Future<Response> updatePassword(
    @Bind.header(HttpHeaders.authorizationHeader) String header,
    @Bind.query('newPassword') String newPassword,
    @Bind.query('oldPassword') String oldPassword,
  ) async {
    try {
      final id = AppUtils.getIdFromHeader(header);

      final qFindUser = Query<User>(managedContext)
        ..where((x) => x.id).equalTo(id)
        ..returningProperties((x) => [x.salt, x.hashPassword]);

      final fUser = await qFindUser.fetchOne();

      final oldHashPassword =
          generatePasswordHash(oldPassword, fUser!.salt ?? "");

      if (oldHashPassword != fUser.hashPassword) {
        return Response.badRequest(
            body: ModelResponse(message: "Не верный старый пароль"));
      }

      final newHashPassword =
          generatePasswordHash(newPassword, fUser.salt ?? "");

      final qUpdateUser = Query<User>(managedContext)
        ..where((x) => x.id).equalTo(id)
        ..values.hashPassword = newHashPassword;

      await qUpdateUser.updateOne();

      return Response.ok(ModelResponse(message: "Пароль успешно обновлен"));
    } catch (e) {
      return Response.serverError(
          body: ModelResponse(message: 'Не удалось обновить профиль'));
    }
  }
}
