import 'dart:io';
import 'package:conduit/conduit.dart';
import 'package:dart_application_1/model/response_model.dart';
import 'package:dart_application_1/model/user_model.dart';
import 'package:jaguar_jwt/jaguar_jwt.dart';

import '../utils/app_utils.dart';

class Auth extends ResourceController {
  Auth(this.managedContext);

  final ManagedContext managedContext;

  @Operation.post()
  Future<Response> signIn(@Bind.body() User user) async {
    if (user.password == null || user.username == null) {
      return Response.badRequest(
        body: ModelResponse(
          message: 'Обязательный поля не были заполнены',
        ),
      );
    }
    try {
      final qFindUser = Query<User>(managedContext)
        ..where((el) => el.username).equalTo(user.username)
        ..returningProperties((el) => [
              el.id,
              el.salt,
              el.hashPassword,
            ]);
      final findUser = await qFindUser.fetchOne();
      if (findUser == null) {
        throw QueryException.input(
            'Проверьте корректность введных вами данных, данная учетная запись не найдена',
            []);
      }
      final requestHashPassword = generatePasswordHash(
        user.password ?? '',
        findUser.salt ?? '',
      );
      if (requestHashPassword == findUser.hashPassword) {
        _updateTokens(findUser.id ?? -1, managedContext);
        final newUser =
            await managedContext.fetchObjectWithID<User>(findUser.id);
        return Response.ok(
          ModelResponse(
            data: newUser!.backing.contents,
          ),
        );
      } else {
        throw QueryException.input('Неверный пароль', []);
      }
    } on QueryException catch (e) {
      return Response.serverError(body: ModelResponse(message: e.message));
    }
  }

  @Operation.put()
  Future<Response> signUp(@Bind.body() User user) async {
    if (user.password == null || user.username == null) {
      return Response.badRequest(
        body: ModelResponse(
          message: 'Поля username и password обязательны',
        ),
      );
    }

    final salt = generateRandomSalt();
    final hashPassword = generatePasswordHash(user.password!, salt);

    try {
      late final int id;

      await managedContext.transaction((transaction) async {
        final qCreateUser = Query<User>(transaction)
          ..values.username = user.username
          ..values.email = user.email
          ..values.salt = salt
          ..values.hashPassword = hashPassword;

        final createdUser = await qCreateUser.insert();
        id = createdUser.id!;

        _updateTokens(id, transaction);
      });

      final userData = await managedContext.fetchObjectWithID<User>(id);

      return Response.ok(ModelResponse(
          data: userData!.backing.contents,
          message: 'Пользователь успешно зарегистрировался'));
    } on QueryException catch (e) {
      return Response.serverError(body: ModelResponse(message: e.message));
    }
  }

  void _updateTokens(int id, ManagedContext managedContext) async {
    final Map<String, String> tokens = _getTokens(id);

    final qUpdateTokens = Query<User>(managedContext)
      ..where((element) => element.id).equalTo(id)
      ..values.accessToken = tokens['access']
      ..values.refToken = tokens['refresh'];

    await qUpdateTokens.updateOne();
  }

  @Operation.post('ref')
  Future<Response> refreshToken(@Bind.path('ref') String refreshToken) async {
    try {
      final id = AppUtils.getIdFromToken(refreshToken);

      final user = await managedContext.fetchObjectWithID<User>(id);

      if (user!.refToken != refreshToken) {
        Response.unauthorized(body: 'Токен не валидный');
      }

      _updateTokens(id, managedContext);
      return Response.ok(ModelResponse(
          data: user.backing.contents, message: 'Токен успешно обновлен'));
    } on QueryException catch (e) {
      return Response.serverError(body: ModelResponse(message: e.message));
    }
  }

  Map<String, String> _getTokens(id) {
    final key = Platform.environment['SECRET_KEY'] ?? 'SECRET_KEY';

    final accessClaimSet =
        JwtClaim(maxAge: const Duration(hours: 1), otherClaims: {'id': id});
    final refreshClaimSet = JwtClaim(otherClaims: {'id': id});

    final tokens = <String, String>{};
    tokens['access'] = issueJwtHS256(accessClaimSet, key);
    tokens['refresh'] = issueJwtHS256(refreshClaimSet, key);

    return tokens;
  }
}
