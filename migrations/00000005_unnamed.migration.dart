import 'dart:async';
import 'package:conduit_core/conduit_core.dart';   

class Migration5 extends Migration { 
  @override
  Future upgrade() async {
   		database.createTable(SchemaTable("_FinanceOperation", [SchemaColumn("id", ManagedPropertyType.bigInteger, isPrimaryKey: true, autoincrement: true, isIndexed: false, isNullable: false, isUnique: false),SchemaColumn("number", ManagedPropertyType.string, isPrimaryKey: false, autoincrement: false, isIndexed: true, isNullable: false, isUnique: true),SchemaColumn("name", ManagedPropertyType.string, isPrimaryKey: false, autoincrement: false, isIndexed: true, isNullable: false, isUnique: false),SchemaColumn("description", ManagedPropertyType.string, isPrimaryKey: false, autoincrement: false, isIndexed: true, isNullable: false, isUnique: false),SchemaColumn("executionDate", ManagedPropertyType.datetime, isPrimaryKey: false, autoincrement: false, isIndexed: true, isNullable: false, isUnique: false),SchemaColumn("totalSum", ManagedPropertyType.doublePrecision, isPrimaryKey: false, autoincrement: false, isIndexed: true, isNullable: false, isUnique: false),SchemaColumn("deleted", ManagedPropertyType.boolean, isPrimaryKey: false, autoincrement: false, defaultValue: "false", isIndexed: false, isNullable: false, isUnique: false)]));
		database.createTable(SchemaTable("_OperationCategory", [SchemaColumn("id", ManagedPropertyType.bigInteger, isPrimaryKey: true, autoincrement: true, isIndexed: false, isNullable: false, isUnique: false),SchemaColumn("name", ManagedPropertyType.string, isPrimaryKey: false, autoincrement: false, isIndexed: true, isNullable: false, isUnique: true)]));
		database.addColumn("_FinanceOperation", SchemaColumn.relationship("user", ManagedPropertyType.bigInteger, relatedTableName: "_User", relatedColumnName: "id", rule: DeleteRule.cascade, isNullable: false, isUnique: false));
		database.addColumn("_FinanceOperation", SchemaColumn.relationship("financeOperationCategory", ManagedPropertyType.bigInteger, relatedTableName: "_OperationCategory", relatedColumnName: "id", rule: DeleteRule.cascade, isNullable: false, isUnique: false));
		database.deleteTable("finance_operation");
		database.deleteTable("operation_category");
		database.deleteTable("actions");
		database.alterColumn("_Action", "user", (c) {c.isNullable = false;c.deleteRule = DeleteRule.cascade;});
  }
  
  @override
  Future downgrade() async {}
  
  @override
  Future seed() async {}
}
    