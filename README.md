# L'Essence Recipes

Aplikasi resep makanan premium berbasis Flutter yang menggunakan **TheMealDB API** sebagai sumber data. Didesain dengan tema restoran premium berwarna coklat-krem-hitam.

## Deskripsi

L'Essence Recipes adalah aplikasi mobile yang memungkinkan pengguna menjelajahi berbagai resep makanan dari seluruh dunia. Aplikasi ini menampilkan kategori makanan, detail resep lengkap dengan bahan dan takaran, serta fitur pencarian resep berdasarkan nama.

## Fitur Utama

- **Halaman Utama (Home):** Menampilkan banner "Menu Pilihan" berupa resep acak (random meal) dan grid kategori makanan.
- **Daftar Resep per Kategori:** Grid kartu resep berdasarkan kategori yang dipilih.
- **Detail Resep:** Menampilkan gambar hero, kategori, asal negara, daftar bahan beserta takaran, dan instruksi memasak.
- **Pencarian Resep:** Fitur pencarian berdasarkan nama resep menggunakan TextField.
- **Error Handling:** Setiap pengambilan data menggunakan FutureBuilder dengan 3 kondisi (loading, error + tombol "Coba Lagi", dan success termasuk penanganan hasil kosong).

## Package yang Digunakan

| Package | Kegunaan |
|---|---|
| `http` | HTTP client untuk request ke TheMealDB API |
| `google_fonts` | Font Poppins untuk tampilan premium |

## Struktur Proyek

```
lib/
├── main.dart                 # Entry point & tema aplikasi
├── models/
│   ├── category.dart         # Model kategori
│   ├── meal_summary.dart     # Model ringkasan meal
│   └── meal_detail.dart      # Model detail meal + Ingredient
├── services/
│   └── meal_service.dart     # Service class untuk TheMealDB API
├── pages/
│   ├── home_page.dart        # Halaman utama
│   ├── category_meals_page.dart  # Daftar resep per kategori
│   ├── meal_detail_page.dart # Detail resep
│   └── search_page.dart      # Pencarian resep
└── widgets/
    ├── meal_image.dart       # Widget gambar dengan error handling
    ├── meal_card.dart        # Kartu resep reusable
    └── error_state.dart      # Widget state error reusable
```

## API Endpoints

- `categories.php` — Daftar semua kategori
- `filter.php?c=` — Daftar meal berdasarkan kategori
- `search.php?s=` — Pencarian meal berdasarkan nama
- `lookup.php?i=` — Detail lengkap satu meal
- `random.php` — Satu meal acak

## Langkah Menjalankan

1. Pastikan Flutter SDK sudah terinstall (versi 3.13+).
2. Clone atau buka proyek ini.
3. Install dependencies:
   ```bash
   flutter pub get
   ```
4. Jalankan di emulator Android atau perangkat fisik:
   ```bash
   flutter run
   ```
5. (Opsional) Untuk memverifikasi kode bebas warning:
   ```bash
   flutter analyze
   ```

## Catatan

- Aplikasi membutuhkan koneksi internet untuk mengambil data dari TheMealDB API.
- Tidak menggunakan state management tambahan (cukup `setState` + `FutureBuilder`).
