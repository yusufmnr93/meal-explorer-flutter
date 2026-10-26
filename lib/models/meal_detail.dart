/// Model detail lengkap sebuah meal.
/// Menggabungkan strIngredient1-20 dan strMeasure1-20 menjadi `List<Ingredient>`.
class Ingredient {
  final String name;
  final String measure;

  Ingredient({required this.name, required this.measure});
}

class MealDetail {
  final String id;
  final String name;
  final String category;
  final String area;
  final String instructions;
  final String thumb;
  final String? youtube;
  final List<Ingredient> ingredients;

  MealDetail({
    required this.id,
    required this.name,
    required this.category,
    required this.area,
    required this.instructions,
    required this.thumb,
    this.youtube,
    required this.ingredients,
  });

  /// Parsing JSON menjadi objek MealDetail.
  /// Proses khusus: menggabungkan strIngredient1-20 dan strMeasure1-20
  /// menjadi satu `List<Ingredient>`. Hanya ingredient yang tidak kosong yang dimasukkan.
  factory MealDetail.fromJson(Map<String, dynamic> json) {
    // Gabungkan pasangan ingredient dan measure (1 sampai 20)
    final List<Ingredient> ingredientList = [];
    for (int i = 1; i <= 20; i++) {
      final ingredientName = json['strIngredient$i'];
      final measureValue = json['strMeasure$i'];

      // Hanya tambahkan jika ingredient tidak null dan tidak kosong
      if (ingredientName != null &&
          ingredientName.toString().trim().isNotEmpty) {
        ingredientList.add(
          Ingredient(
            name: ingredientName.toString().trim(),
            measure: (measureValue ?? '').toString().trim(),
          ),
        );
      }
    }

    return MealDetail(
      id: json['idMeal'] ?? '',
      name: json['strMeal'] ?? '',
      category: json['strCategory'] ?? '',
      area: json['strArea'] ?? '',
      instructions: json['strInstructions'] ?? '',
      thumb: json['strMealThumb'] ?? '',
      youtube: json['strYoutube'],
      ingredients: ingredientList,
    );
  }
}
