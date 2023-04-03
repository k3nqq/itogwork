import 'package:conduit/conduit.dart';
import 'package:dart_application_1/model/action_model.dart';
import 'package:dart_application_1/model/itog_work.dart';

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
  String? refToken;
  @Column(omitByDefault: true)
  String? hashPassword;
  @Column(omitByDefault: true)
  String? salt;
  ManagedSet<ItogWork>? itogOperations;
  ManagedSet<Action>? actions;
}
