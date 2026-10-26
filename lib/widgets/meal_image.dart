import 'package:flutter/material.dart';

/// Widget reusable untuk menampilkan gambar dari network dengan error handling.
/// Menampilkan placeholder jika gambar gagal dimuat.
class MealImage extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;

  const MealImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final image = Image.network(
      imageUrl,
      width: width,
      height: height,
      fit: fit,
      // Loading placeholder
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return SizedBox(
          width: width,
          height: height,
          child: const Center(
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        );
      },
      // Error builder: tampilkan ikon jika gambar gagal dimuat
      errorBuilder: (context, error, stackTrace) {
        return Container(
          width: width,
          height: height,
          color: const Color(0xFFE8E0D6),
          child: const Center(
            child: Icon(
              Icons.broken_image_rounded,
              color: Color(0xFFA09080),
              size: 40,
            ),
          ),
        );
      },
    );

    if (borderRadius != null) {
      return ClipRRect(borderRadius: borderRadius!, child: image);
    }
    return image;
  }
}
