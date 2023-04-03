import 'package:conduit/conduit.dart';
import 'package:dart_application_1/model/response_model.dart';
import 'package:dart_application_1/utils/app_utils.dart';
import 'dart:async';
import 'dart:io';
import '../model/user.dart';

class user_contrl extends ResourceController {
  user_contrl(this.managedContext);

  final ManagedContext managedContext;

  @Operation.get()
  Future<Response> getProfile(
      @Bind.header(HttpHeaders.authorizationHeader) String header) async {
    try {
      final id = AppUtils.getIdFromHeader(header);

      final user = await managedContext.fetchObjectWithID<User>(id);

      user!.removePropertiesFromBackingMap(['refToken', 'accessToken']);

      return Response.ok(ModelResponse(
          data: user.backing.contents, message: 'Профиль успешно изменен'));
    } catch (e) {
      return Response.serverError(
          body: ModelResponse(message: 'Невозможно получить информцию'));
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
          data: fUser.backing.contents, message: 'Информация обновлена'));
    } catch (e) {
      return Response.serverError(
          body: ModelResponse(message: 'Не удалось обновить данные профиля'));
    }
  }

  @Operation.put()
  Future<Response> updatePassword(
    @Bind.header(HttpHeaders.authorizationHeader) String header,
    @Bind.query('newPass') String newPassword,
    @Bind.query('oldPass') String oldPassword,
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
