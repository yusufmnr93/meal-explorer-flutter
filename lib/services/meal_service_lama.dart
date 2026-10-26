import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/category.dart';
import '../models/meal_summary.dart';
import '../models/meal_detail.dart';

/// Service class untuk berkomunikasi dengan TheMealDB API.
/// Semua method melakukan HTTP GET dan memeriksa statusCode == 200.
class MealService {
  static const String _baseUrl =
      'https://www.themealdb.com/api/json/v1/1';

  /// Mengambil semua kategori dari endpoint categories.php
  Future<List<Category>> getCategories() async {
    final response = await http.get(Uri.parse('$_baseUrl/categories.php'));

    // Cek status HTTP; lempar exception jika bukan 200
    if (response.statusCode != 200) {
      throw Exception('Gagal memuat kategori. Status: ${response.statusCode}');
    }

    final data = json.decode(response.body);
    final List categories = data['categories'] ?? [];
    return categories.map((json) => Category.fromJson(json)).toList();
  }

  /// Mengambil daftar meal berdasarkan kategori dari endpoint filter.php?c=
  Future<List<MealSummary>> getMealsByCategory(String category) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/filter.php?c=$category'),
    );

    if (response.statusCode != 200) {
      throw Exception('Gagal memuat resep. Status: ${response.statusCode}');
    }

    final data = json.decode(response.body);
    final List meals = data['meals'] ?? [];
    return meals.map((json) => MealSummary.fromJson(json)).toList();
  }

  /// Mencari meal berdasarkan nama dari endpoint search.php?s=
  Future<List<MealSummary>> searchMeals(String query) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/search.php?s=$query'),
    );

    if (response.statusCode != 200) {
      throw Exception('Gagal mencari resep. Status: ${response.statusCode}');
    }

    final data = json.decode(response.body);
    final List? meals = data['meals'];

    // API mengembalikan null jika tidak ada hasil
    if (meals == null) return [];
    return meals.map((json) => MealSummary.fromJson(json)).toList();
  }

  /// Mengambil detail lengkap meal dari endpoint lookup.php?i=
  Future<MealDetail> getMealDetail(String id) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/lookup.php?i=$id'),
    );

    if (response.statusCode != 200) {
      throw Exception(
          'Gagal memuat detail resep. Status: ${response.statusCode}');
    }

    final data = json.decode(response.body);
    final List? meals = data['meals'];

    if (meals == null || meals.isEmpty) {
      throw Exception('Resep tidak ditemukan.');
    }

    return MealDetail.fromJson(meals[0]);
  }

  /// Mengambil satu meal acak dari endpoint random.php
  Future<MealDetail> getRandomMeal() async {
    final response = await http.get(Uri.parse('$_baseUrl/random.php'));

    if (response.statusCode != 200) {
      throw Exception(
          'Gagal memuat resep acak. Status: ${response.statusCode}');
    }

    final data = json.decode(response.body);
    final List? meals = data['meals'];

    if (meals == null || meals.isEmpty) {
      throw Exception('Tidak ada resep acak yang tersedia.');
    }

    return MealDetail.fromJson(meals[0]);
  }
}
