import 'package:conduit/conduit.dart';
import 'package:dart_application_1/model/operation_category.dart';
import 'package:dart_application_1/model/user_model.dart';

class ItogWork extends ManagedObject<_ItogWork> implements _ItogWork {}

//@Table(name: "itog_work")
class _ItogWork {
  @primaryKey
  int? id;
  @Column(unique: true, indexed: true)
  String? number;
  @Column(unique: false, indexed: true)
  String? name;
  @Column(unique: false, indexed: true)
  String? description;
  @Column(unique: false, indexed: true)
  DateTime? executionDate;
  @Column(unique: false, indexed: true)
  double? totalSum;
  @Relate(#financialOperations, isRequired: true, onDelete: DeleteRule.cascade)
  User? user;
  @Relate(#financialOperations, isRequired: true, onDelete: DeleteRule.cascade)
  OperationCategory? ItogWorkCategory;
  @Column(defaultValue: 'false')
  bool? deleted;
}
