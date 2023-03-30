import 'package:conduit/conduit.dart';
import 'package:dart_application_1/model/action_model.dart';
import 'package:dart_application_1/model/finance_operation.dart';

class User extends ManagedObject<_User> implements _User {}

class _User {
  @primaryKey
  int? id;
  @Column(unique: true, indexed: true)
  String? username;
  @Column(unique: true, indexed: true)
  String? email;
  @Serialize(input: true, output: false)
  String? password;
  @Column(nullable: true)
  String? accessToken;
  @Column(nullable: true)
  String? refreshToken;
  @Column(omitByDefault: true)
  String? hashPassword;
  @Column(omitByDefault: true)
  String? salt;
  ManagedSet<FinanceOperation>? financialOperations;
  ManagedSet<Action>? actions;
}
