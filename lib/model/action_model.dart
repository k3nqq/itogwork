import 'package:conduit/conduit.dart';
import 'package:dart_application_1/model/user.dart';

class Action extends ManagedObject<_Action> implements _Action {}

//@Table(name: 'actions')
class _Action {
  @primaryKey
  int? id;
  @Column(unique: false)
  String? title;
  @Relate(#actions, isRequired: true, onDelete: DeleteRule.cascade)
  User? user;
}
