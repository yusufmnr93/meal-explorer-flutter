import 'package:flutter/material.dart';
import '../models/meal_summary.dart';
import '../services/meal_service.dart';
import '../widgets/meal_card.dart';
import '../widgets/error_state.dart';
import 'meal_detail_page.dart';

/// Halaman daftar resep per kategori.
/// Menampilkan grid kartu meal berdasarkan kategori yang dipilih.
class CategoryMealsPage extends StatefulWidget {
  final String categoryName;

  const CategoryMealsPage({super.key, required this.categoryName});

  @override
  State<CategoryMealsPage> createState() => _CategoryMealsPageState();
}

class _CategoryMealsPageState extends State<CategoryMealsPage> {
  final MealService _service = MealService();
  late Future<List<MealSummary>> _mealsFuture;

  @override
  void initState() {
    super.initState();
    _mealsFuture = _service.getMealsByCategory(widget.categoryName);
  }

  /// Refresh daftar meal saat tombol coba lagi ditekan
  void _refresh() {
    setState(() {
      _mealsFuture = _service.getMealsByCategory(widget.categoryName);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.categoryName),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        // FutureBuilder: menampilkan daftar meal dengan 3 kondisi
        child: FutureBuilder<List<MealSummary>>(
          future: _mealsFuture,
          builder: (context, snapshot) {
            // Kondisi 1: Loading
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            // Kondisi 2: Error
            if (snapshot.hasError) {
              return ErrorState(
                message: 'Gagal memuat resep:\n${snapshot.error}',
                onRetry: _refresh,
              );
            }

            // Kondisi 3: Success - tangani juga hasil kosong
            final meals = snapshot.data!;
            if (meals.isEmpty) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.no_meals_rounded,
                      size: 64,
                      color: Color(0xFFBBBBBB),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Tidak ada resep dalam kategori ini.',
                      style: TextStyle(color: Color(0xFF888888), fontSize: 15),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _refresh,
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text('Coba Lagi'),
                    ),
                  ],
                ),
              );
            }

            return GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.78,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
              ),
              itemCount: meals.length,
              itemBuilder: (context, index) {
                final meal = meals[index];
                return MealCard(
                  meal: meal,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => MealDetailPage(mealId: meal.id),
                      ),
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}
