import 'package:conduit/conduit.dart';
import 'package:dart_application_1/model/operation_category.dart';
import 'package:dart_application_1/model/user.dart';

class FinanceOperation extends ManagedObject<_FinanceOperation>
    implements _FinanceOperation {}

//@Table(name: "finance_operation")
class _FinanceOperation {
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
  OperationCategory? financeOperationCategory;
  @Column(defaultValue: 'false')
  bool? deleted;
}
