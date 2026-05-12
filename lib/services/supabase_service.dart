import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  final supabase = Supabase.instance.client;

  // Ambil semua produk
  Future<List<Map<String, dynamic>>> getProducts() async {
    final response = await supabase.from('products').select();

    return response;
  }

  // Tambah produk
  Future<void> addProduct(
    String menuName,
    int price,
    String description,
    String? notes,
    String images,
  ) async {
    await supabase.from('products').insert({'name': menuName, 'price': price});
  }

  // Hapus produk
  Future<void> deleteProduct(String id) async {
    await supabase.from('products').delete().eq('id', id);
  }
}
