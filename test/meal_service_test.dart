// Pengujian unit untuk model dan service (tanpa koneksi internet,
// memakai MockClient dari package:http/testing.dart).

import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:meal_explorer/models/meal_detail.dart';
import 'package:meal_explorer/services/meal_service.dart';

Map<String, dynamic> _mealJson() => {
      'idMeal': '52772',
      'strMeal': 'Teriyaki Chicken Casserole',
      'strCategory': 'Chicken',
      'strArea': 'Japanese',
      'strInstructions': 'Preheat oven.',
      'strMealThumb': 'https://example.com/a.jpg',
      'strYoutube': 'https://youtube.com/x',
      'strIngredient1': 'soy sauce',
      'strMeasure1': '3/4 cup',
      'strIngredient2': 'water',
      'strMeasure2': '1/2 cup',
      'strIngredient3': '',
      'strMeasure3': ' ',
      'strIngredient4': null,
      'strMeasure4': null,
    };

http.Response _json(Object body, [int status = 200]) => http.Response(
      jsonEncode(body),
      status,
      headers: {'content-type': 'application/json; charset=utf-8'},
    );

void main() {
  group('MealDetail.fromJson', () {
    test('menggabungkan bahan dan takaran, mengabaikan yang kosong', () {
      final meal = MealDetail.fromJson(_mealJson());
      expect(meal.name, 'Teriyaki Chicken Casserole');
      expect(meal.ingredients.length, 2);
      expect(meal.ingredients.first.name, 'soy sauce');
      expect(meal.ingredients.first.measure, '3/4 cup');
    });
  });

  group('MealService', () {
    test('getCategories mengembalikan daftar kategori (status 200)', () async {
      final service = MealService(
        client: MockClient((_) async => _json({
              'categories': [
                {
                  'idCategory': '1',
                  'strCategory': 'Beef',
                  'strCategoryThumb': 'b.png',
                  'strCategoryDescription': 'Daging sapi',
                }
              ]
            })),
      );
      final result = await service.getCategories();
      expect(result.single.name, 'Beef');
    });

    test('searchMeals mengembalikan list kosong jika meals null', () async {
      final service = MealService(
        client: MockClient((_) async => _json({'meals': null})),
      );
      expect(await service.searchMeals('zzzz'), isEmpty);
    });

    test('searchMeals meng-encode query yang mengandung spasi', () async {
      Uri? captured;
      final service = MealService(
        client: MockClient((req) async {
          captured = req.url;
          return _json({'meals': null});
        }),
      );
      await service.searchMeals('chicken curry');
      expect(captured!.queryParameters['s'], 'chicken curry');
      expect(captured!.toString(), contains('s=chicken+curry'));
    });

    test('melempar Exception jika status bukan 200', () async {
      final service = MealService(
        client: MockClient((_) async => http.Response('error', 500)),
      );
      expect(service.getCategories(), throwsException);
    });

    test('getMealDetail melempar Exception jika resep tidak ditemukan',
        () async {
      final service = MealService(
        client: MockClient((_) async => _json({'meals': null})),
      );
      expect(service.getMealDetail('0'), throwsException);
    });
  });
}
