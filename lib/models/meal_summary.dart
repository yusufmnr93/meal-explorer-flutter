/// Model ringkasan meal (dipakai di daftar kategori dan hasil pencarian).
class MealSummary {
  final String id;
  final String name;
  final String thumb;

  MealSummary({
    required this.id,
    required this.name,
    required this.thumb,
  });

  /// Parsing JSON menjadi objek MealSummary.
  /// Field: idMeal, strMeal, strMealThumb.
  factory MealSummary.fromJson(Map<String, dynamic> json) {
    return MealSummary(
      id: json['idMeal'] ?? '',
      name: json['strMeal'] ?? '',
      thumb: json['strMealThumb'] ?? '',
    );
  }
}
