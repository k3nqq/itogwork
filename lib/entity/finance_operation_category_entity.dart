
enum FinanceOperationCategoryEnum {
  credit(id: 1, name: "Кредит"),
  mortgage(id: 2, name: "Ипотека"),
  transfer(id: 3, name: "Перевод");

  const FinanceOperationCategoryEnum({
    required this.id,
    required this.name,
  });

  final String name;
  final int id;
}