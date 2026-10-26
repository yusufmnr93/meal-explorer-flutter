import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/category.dart';
import '../models/meal_summary.dart';
import '../models/meal_detail.dart';

/// Service class untuk berkomunikasi dengan TheMealDB API.
/// Semua method melakukan HTTP GET, memakai timeout, dan memeriksa statusCode == 200.
class MealService {
  static const String _host = 'www.themealdb.com';
  static const String _basePath = '/api/json/v1/1';
  static const Duration _timeout = Duration(seconds: 15);

  final http.Client _client;

  /// [client] bisa diganti (mis. MockClient) saat pengujian.
  MealService({http.Client? client}) : _client = client ?? http.Client();

  /// Membuat URI dengan query parameter yang otomatis di-encode
  /// (aman untuk spasi dan karakter khusus).
  Uri _uri(String endpoint, [Map<String, String>? query]) {
    return Uri.https(_host, '$_basePath/$endpoint', query);
  }

  /// Melakukan GET, memberi batas waktu, dan memeriksa status HTTP.
  Future<Map<String, dynamic>> _get(
    String endpoint,
    String errorMessage, [
    Map<String, String>? query,
  ]) async {
    final response =
        await _client.get(_uri(endpoint, query)).timeout(_timeout);

    // Cek status HTTP; lempar exception jika bukan 200
    if (response.statusCode != 200) {
      throw Exception('$errorMessage Status: ${response.statusCode}');
    }
    return json.decode(response.body) as Map<String, dynamic>;
  }

  /// Mengambil semua kategori dari endpoint categories.php
  Future<List<Category>> getCategories() async {
    final data = await _get('categories.php', 'Gagal memuat kategori.');
    final List categories = data['categories'] ?? [];
    return categories.map((e) => Category.fromJson(e)).toList();
  }

  /// Mengambil daftar meal berdasarkan kategori dari endpoint filter.php?c=
  Future<List<MealSummary>> getMealsByCategory(String category) async {
    final data = await _get(
        'filter.php', 'Gagal memuat resep.', {'c': category});
    final List meals = data['meals'] ?? [];
    return meals.map((e) => MealSummary.fromJson(e)).toList();
  }

  /// Mencari meal berdasarkan nama dari endpoint search.php?s=
  Future<List<MealSummary>> searchMeals(String query) async {
    final data =
        await _get('search.php', 'Gagal mencari resep.', {'s': query});
    // API mengembalikan null jika tidak ada hasil
    final List? meals = data['meals'];
    if (meals == null) return [];
    return meals.map((e) => MealSummary.fromJson(e)).toList();
  }

  /// Mengambil detail lengkap meal dari endpoint lookup.php?i=
  Future<MealDetail> getMealDetail(String id) async {
    final data = await _get(
        'lookup.php', 'Gagal memuat detail resep.', {'i': id});
    final List? meals = data['meals'];
    if (meals == null || meals.isEmpty) {
      throw Exception('Resep tidak ditemukan.');
    }
    return MealDetail.fromJson(meals[0]);
  }

  /// Mengambil satu meal acak dari endpoint random.php
  Future<MealDetail> getRandomMeal() async {
    final data = await _get('random.php', 'Gagal memuat resep acak.');
    final List? meals = data['meals'];
    if (meals == null || meals.isEmpty) {
      throw Exception('Tidak ada resep acak yang tersedia.');
    }
    return MealDetail.fromJson(meals[0]);
  }
}
