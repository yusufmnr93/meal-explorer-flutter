import 'package:flutter/material.dart';
import '../models/meal_summary.dart';
import '../services/meal_service.dart';
import '../widgets/meal_card.dart';
import '../widgets/error_state.dart';
import 'meal_detail_page.dart';

/// Halaman pencarian resep.
/// User memasukkan kata kunci di TextField, lalu hasil dicari via API.
class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final MealService _service = MealService();
  final TextEditingController _searchController = TextEditingController();

  /// Future untuk hasil pencarian; null berarti belum pernah cari
  Future<List<MealSummary>>? _searchFuture;

  /// Simpan query terakhir agar bisa retry
  String _lastQuery = '';

  void _performSearch() {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;

    setState(() {
      _lastQuery = query;
      _searchFuture = _service.searchMeals(query);
    });
  }

  void _retrySearch() {
    if (_lastQuery.isEmpty) return;
    setState(() {
      _searchFuture = _service.searchMeals(_lastQuery);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cari Resep'),
      ),
      body: Column(
        children: [
          // === SEARCH BAR ===
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              controller: _searchController,
              textInputAction: TextInputAction.search,
              onSubmitted: (_) => _performSearch(),
              decoration: InputDecoration(
                hintText: 'Cari resep, misalnya "chicken"...',
                hintStyle: const TextStyle(
                  color: Color(0xFFAAAAAA),
                  fontSize: 14,
                ),
                prefixIcon: const Icon(
                  Icons.search_rounded,
                  color: Color(0xFFC96A1B),
                ),
                suffixIcon: IconButton(
                  icon: const Icon(
                    Icons.send_rounded,
                    color: Color(0xFFC96A1B),
                  ),
                  onPressed: _performSearch,
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: Color(0xFFE8E0D6)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: Color(0xFFE8E0D6)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(
                    color: Color(0xFFC96A1B),
                    width: 2,
                  ),
                ),
              ),
            ),
          ),

          // === HASIL PENCARIAN ===
          Expanded(
            child: _searchFuture == null
                // State awal: belum melakukan pencarian
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.search_rounded,
                          size: 80,
                          color: const Color(0xFFC96A1B).withValues(alpha: 0.25),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Ketik nama resep untuk mulai mencari',
                          style: TextStyle(
                            color: Color(0xFFAAAAAA),
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  )
                // FutureBuilder: hasil pencarian dengan 3 kondisi
                : FutureBuilder<List<MealSummary>>(
                    future: _searchFuture,
                    builder: (context, snapshot) {
                      // Kondisi 1: Loading
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }

                      // Kondisi 2: Error
                      if (snapshot.hasError) {
                        return ErrorState(
                          message:
                              'Gagal mencari resep:\n${snapshot.error}',
                          onRetry: _retrySearch,
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
                              Text(
                                'Tidak ada hasil untuk "$_lastQuery"',
                                style: const TextStyle(
                                  color: Color(0xFF888888),
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      return Padding(
                        padding: const EdgeInsets.all(16),
                        child: GridView.builder(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
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
                                    builder: (_) =>
                                        MealDetailPage(mealId: meal.id),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
