import 'dart:async';
import 'package:conduit_core/conduit_core.dart';
import 'package:dart_application_1/entity/finance_operation_category_entity.dart';
import 'package:dart_application_1/model/user.dart';

class Migration1 extends Migration {
  @override
  Future upgrade() async {
    database.createTable(SchemaTable("_User", [
      SchemaColumn("id", ManagedPropertyType.bigInteger,
          isPrimaryKey: true,
          autoincrement: true,
          isIndexed: false,
          isNullable: false,
          isUnique: false),
      SchemaColumn("username", ManagedPropertyType.string,
          isPrimaryKey: false,
          autoincrement: false,
          isIndexed: true,
          isNullable: false,
          isUnique: true),
      SchemaColumn("email", ManagedPropertyType.string,
          isPrimaryKey: false,
          autoincrement: false,
          isIndexed: true,
          isNullable: false,
          isUnique: true),
      SchemaColumn("accessToken", ManagedPropertyType.string,
          isPrimaryKey: false,
          autoincrement: false,
          isIndexed: false,
          isNullable: true,
          isUnique: false),
      SchemaColumn("refreshToken", ManagedPropertyType.string,
          isPrimaryKey: false,
          autoincrement: false,
          isIndexed: false,
          isNullable: true,
          isUnique: false),
      SchemaColumn("hashPassword", ManagedPropertyType.string,
          isPrimaryKey: false,
          autoincrement: false,
          isIndexed: false,
          isNullable: false,
          isUnique: false),
      SchemaColumn("salt", ManagedPropertyType.string,
          isPrimaryKey: false,
          autoincrement: false,
          isIndexed: false,
          isNullable: false,
          isUnique: false)
    ]));
    database.createTable(SchemaTable("finance_operation", [
      SchemaColumn("id", ManagedPropertyType.bigInteger,
          isPrimaryKey: true,
          autoincrement: true,
          isIndexed: false,
          isNullable: false,
          isUnique: false),
      SchemaColumn("number", ManagedPropertyType.string,
          isPrimaryKey: false,
          autoincrement: false,
          isIndexed: true,
          isNullable: false,
          isUnique: true),
      SchemaColumn("name", ManagedPropertyType.string,
          isPrimaryKey: false,
          autoincrement: false,
          isIndexed: true,
          isNullable: false,
          isUnique: false),
      SchemaColumn("description", ManagedPropertyType.string,
          isPrimaryKey: false,
          autoincrement: false,
          isIndexed: true,
          isNullable: false,
          isUnique: false),
      SchemaColumn("executionDate", ManagedPropertyType.datetime,
          isPrimaryKey: false,
          autoincrement: false,
          isIndexed: true,
          isNullable: false,
          isUnique: false),
      SchemaColumn("totalSum", ManagedPropertyType.doublePrecision,
          isPrimaryKey: false,
          autoincrement: false,
          isIndexed: true,
          isNullable: false,
          isUnique: false)
    ]));
    database.createTable(SchemaTable("operation_category", [
      SchemaColumn("id", ManagedPropertyType.bigInteger,
          isPrimaryKey: true,
          autoincrement: true,
          isIndexed: false,
          isNullable: false,
          isUnique: false),
      SchemaColumn("name", ManagedPropertyType.string,
          isPrimaryKey: false,
          autoincrement: false,
          isIndexed: true,
          isNullable: false,
          isUnique: true)
    ]));
    database.addColumn(
        "finance_operation",
        SchemaColumn.relationship("user", ManagedPropertyType.bigInteger,
            relatedTableName: "_User",
            relatedColumnName: "id",
            rule: DeleteRule.nullify,
            isNullable: true,
            isUnique: false));
    database.addColumn(
        "finance_operation",
        SchemaColumn.relationship(
            "financeOperationCategory", ManagedPropertyType.bigInteger,
            relatedTableName: "operation_category",
            relatedColumnName: "id",
            rule: DeleteRule.nullify,
            isNullable: true,
            isUnique: false));
  }

  @override
  Future downgrade() async {}

  @override
  Future seed() async {
   /* await store!.executeQuery(
        "INSERT IN operation_category ", {"id": 1, "name": "Кредит"}, 10);
    await store!.executeQuery(
        "INSERT IN operation_category ", {"id": 2, "name": "Ипотека"}, 10);
    await store!.executeQuery(
        "INSERT IN operation_category ", {"id": 3, "name": "Перевод"}, 10);*/
  }
}
