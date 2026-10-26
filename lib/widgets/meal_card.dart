import 'package:flutter/material.dart';
import '../models/meal_summary.dart';
import '../widgets/meal_image.dart';

/// Kartu resep yang menampilkan gambar dan nama meal.
/// Dipakai di halaman daftar resep per kategori dan hasil pencarian.
class MealCard extends StatelessWidget {
  final MealSummary meal;
  final VoidCallback onTap;

  const MealCard({
    super.key,
    required this.meal,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Gambar meal
            Expanded(
              child: MealImage(
                imageUrl: meal.thumb,
                fit: BoxFit.cover,
              ),
            ),
            // Nama meal
            Padding(
              padding: const EdgeInsets.all(10),
              child: Text(
                meal.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1C1C1C),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
