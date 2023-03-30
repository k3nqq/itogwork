import 'package:conduit/conduit.dart';
import 'package:dart_application_1/model/finance_operation.dart';

class OperationCategory extends ManagedObject<_OperationCategory>
    implements _OperationCategory {}

//@Table(name: "operation_category")
class _OperationCategory {
  @primaryKey
  int? id;
  @Column(unique: true, indexed: true)
  String? name;
  ManagedSet<FinanceOperation>? financialOperations;
}
