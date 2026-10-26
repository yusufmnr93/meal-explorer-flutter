import 'package:flutter/material.dart';
import '../models/meal_detail.dart';
import '../services/meal_service.dart';
import '../widgets/meal_image.dart';
import '../widgets/error_state.dart';

/// Halaman detail resep: menampilkan gambar, kategori, asal,
/// daftar bahan+takaran, dan instruksi memasak.
class MealDetailPage extends StatefulWidget {
  final String mealId;

  const MealDetailPage({super.key, required this.mealId});

  @override
  State<MealDetailPage> createState() => _MealDetailPageState();
}

class _MealDetailPageState extends State<MealDetailPage> {
  final MealService _service = MealService();
  late Future<MealDetail> _detailFuture;

  @override
  void initState() {
    super.initState();
    _detailFuture = _service.getMealDetail(widget.mealId);
  }

  /// Refresh detail saat tombol coba lagi ditekan
  void _refresh() {
    setState(() {
      _detailFuture = _service.getMealDetail(widget.mealId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<MealDetail>(
        future: _detailFuture,
        builder: (context, snapshot) {
          // Kondisi 1: Loading
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // Kondisi 2: Error
          if (snapshot.hasError) {
            return Scaffold(
              appBar: AppBar(title: const Text('Detail Resep')),
              body: ErrorState(
                message: 'Gagal memuat detail resep:\n${snapshot.error}',
                onRetry: _refresh,
              ),
            );
          }

          // Kondisi 3: Success
          final meal = snapshot.data!;
          return _buildContent(meal);
        },
      ),
    );
  }

  /// Tampilan detail lengkap meal
  Widget _buildContent(MealDetail meal) {
    return CustomScrollView(
      slivers: [
        // === GAMBAR HEADER dengan SliverAppBar ===
        SliverAppBar(
          expandedHeight: 300,
          pinned: true,
          backgroundColor: const Color(0xFF1C1C1C),
          iconTheme: const IconThemeData(color: Colors.white),
          flexibleSpace: FlexibleSpaceBar(
            background: Stack(
              fit: StackFit.expand,
              children: [
                MealImage(imageUrl: meal.thumb, fit: BoxFit.cover),
                // Gradient overlay
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.6),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // === KONTEN DETAIL ===
        SliverToBoxAdapter(
          child: Transform.translate(
            offset: const Offset(0, -24),
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFFFBF8F3),
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 28, 20, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Nama resep
                    Text(
                      meal.name,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1C1C1C),
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Badge: kategori dan asal
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildBadge(
                          Icons.category_rounded,
                          meal.category,
                        ),
                        _buildBadge(
                          Icons.public_rounded,
                          meal.area,
                        ),
                      ],
                    ),

                    const SizedBox(height: 28),

                    // === BAHAN DAN TAKARAN ===
                    _buildSectionTitle('Bahan & Takaran'),
                    const SizedBox(height: 12),
                    _buildIngredientsTable(meal.ingredients),

                    const SizedBox(height: 28),

                    // === INSTRUKSI ===
                    _buildSectionTitle('Cara Memasak'),
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        meal.instructions,
                        style: const TextStyle(
                          fontSize: 14,
                          height: 1.7,
                          color: Color(0xFF333333),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Widget badge untuk kategori/asal
  Widget _buildBadge(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3E8),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFC96A1B).withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: const Color(0xFFC96A1B)),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFFC96A1B),
            ),
          ),
        ],
      ),
    );
  }

  /// Widget judul section
  Widget _buildSectionTitle(String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            color: const Color(0xFFC96A1B),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1C1C1C),
          ),
        ),
      ],
    );
  }

  /// Tabel bahan dan takaran
  Widget _buildIngredientsTable(List<Ingredient> ingredients) {
    if (ingredients.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Text(
          'Tidak ada data bahan.',
          style: TextStyle(color: Color(0xFF888888)),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: List.generate(ingredients.length, (index) {
          final ingredient = ingredients[index];
          final isLast = index == ingredients.length - 1;
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              border: isLast
                  ? null
                  : const Border(
                      bottom: BorderSide(
                        color: Color(0xFFF0EBE4),
                        width: 1,
                      ),
                    ),
            ),
            child: Row(
              children: [
                // Nomor urut
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF3E8),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFC96A1B),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Nama bahan
                Expanded(
                  child: Text(
                    ingredient.name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF1C1C1C),
                    ),
                  ),
                ),
                // Takaran
                Text(
                  ingredient.measure,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF888888),
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}
