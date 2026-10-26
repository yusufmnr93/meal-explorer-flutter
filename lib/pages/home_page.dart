import 'package:flutter/material.dart';
import '../models/category.dart';
import '../models/meal_detail.dart';
import '../services/meal_service.dart';
import '../widgets/meal_image.dart';
import '../widgets/error_state.dart';
import 'category_meals_page.dart';
import 'meal_detail_page.dart';
import 'search_page.dart';

/// Halaman utama: menampilkan banner "Menu Pilihan" (random meal)
/// dan grid kategori.
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final MealService _service = MealService();
  late Future<MealDetail> _randomMealFuture;
  late Future<List<Category>> _categoriesFuture;

  @override
  void initState() {
    super.initState();
    _randomMealFuture = _service.getRandomMeal();
    _categoriesFuture = _service.getCategories();
  }

  /// Refresh random meal saat tombol refresh ditekan
  void _refreshRandom() {
    setState(() {
      _randomMealFuture = _service.getRandomMeal();
    });
  }

  /// Refresh kategori saat tombol coba lagi ditekan
  void _refreshCategories() {
    setState(() {
      _categoriesFuture = _service.getCategories();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar dengan judul aplikasi dan tombol pencarian
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFFC96A1B),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.restaurant_menu_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            const Text("L'Essence Recipes"),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search_rounded),
            tooltip: 'Cari Resep',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SearchPage()),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // === BANNER: Menu Pilihan (Random Meal) ===
            _buildRandomBanner(),
            const SizedBox(height: 24),

            // === HEADER: Kategori ===
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Container(
                    width: 4,
                    height: 22,
                    decoration: BoxDecoration(
                      color: const Color(0xFFC96A1B),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Kategori',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1C1C1C),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // === GRID: Kategori ===
            _buildCategoriesGrid(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  /// Widget banner untuk menampilkan random meal.
  /// FutureBuilder dengan 3 kondisi: loading, error, success.
  Widget _buildRandomBanner() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.auto_awesome, color: Color(0xFFC96A1B), size: 20),
              const SizedBox(width: 6),
              const Text(
                'Menu Pilihan',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1C1C1C),
                ),
              ),
              const Spacer(),
              // Tombol refresh random meal
              IconButton(
                icon: const Icon(Icons.refresh_rounded, size: 22),
                color: const Color(0xFFC96A1B),
                tooltip: 'Acak lagi',
                onPressed: _refreshRandom,
              ),
            ],
          ),
          const SizedBox(height: 8),

          // FutureBuilder: menampilkan random meal dengan 3 kondisi
          FutureBuilder<MealDetail>(
            future: _randomMealFuture,
            builder: (context, snapshot) {
              // Kondisi 1: Loading
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Center(child: CircularProgressIndicator()),
                );
              }

              // Kondisi 2: Error
              if (snapshot.hasError) {
                return Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: ErrorState(
                    message: 'Gagal memuat menu pilihan:\n${snapshot.error}',
                    onRetry: _refreshRandom,
                  ),
                );
              }

              // Kondisi 3: Success
              final meal = snapshot.data!;
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => MealDetailPage(mealId: meal.id),
                    ),
                  );
                },
                child: Container(
                  height: 200,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Gambar meal
                      MealImage(imageUrl: meal.thumb, fit: BoxFit.cover),
                      // Gradient overlay
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.75),
                            ],
                          ),
                        ),
                      ),
                      // Info teks di bawah
                      Positioned(
                        left: 16,
                        right: 16,
                        bottom: 16,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Badge kategori
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFC96A1B),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                meal.category,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const SizedBox(height: 6),
                            // Nama meal
                            Text(
                              meal.name,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                height: 1.2,
                              ),
                            ),
                            const SizedBox(height: 2),
                            // Asal
                            Row(
                              children: [
                                const Icon(
                                  Icons.public_rounded,
                                  color: Colors.white70,
                                  size: 14,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  meal.area,
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  /// Widget grid untuk menampilkan kategori.
  /// FutureBuilder dengan 3 kondisi: loading, error, success.
  Widget _buildCategoriesGrid() {
    return FutureBuilder<List<Category>>(
      future: _categoriesFuture,
      builder: (context, snapshot) {
        // Kondisi 1: Loading
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            height: 200,
            child: Center(child: CircularProgressIndicator()),
          );
        }

        // Kondisi 2: Error
        if (snapshot.hasError) {
          return ErrorState(
            message: 'Gagal memuat kategori:\n${snapshot.error}',
            onRetry: _refreshCategories,
          );
        }

        // Kondisi 3: Success - tangani juga hasil kosong
        final categories = snapshot.data!;
        if (categories.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: Text(
                'Tidak ada kategori tersedia.',
                style: TextStyle(color: Color(0xFF888888)),
              ),
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 0.85,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final cat = categories[index];
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CategoryMealsPage(
                        categoryName: cat.name,
                      ),
                    ),
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Gambar kategori (bulat)
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFFFFF3E8),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFC96A1B).withValues(alpha: 0.15),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: ClipOval(
                          child: MealImage(
                            imageUrl: cat.thumb,
                            width: 60,
                            height: 60,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Nama kategori
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Text(
                          cat.name,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1C1C1C),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
