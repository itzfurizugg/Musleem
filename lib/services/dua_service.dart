import 'package:supabase_flutter/supabase_flutter.dart';

class DuaCategory {
  final int id;
  final String name;
  final String slug;
  final String? icon;

  DuaCategory({
    required this.id,
    required this.name,
    required this.slug,
    this.icon,
  });

  factory DuaCategory.fromJson(Map<String, dynamic> json) => DuaCategory(
        id: json['id'],
        name: json['name'],
        slug: json['slug'],
        icon: json['icon'],
      );
}

class Dua {
  final int id;
  final int categoryId;
  final String title;
  final String arabicText;
  final String transliteration;
  final String translation;
  final String? source;
  final int order;

  Dua({
    required this.id,
    required this.categoryId,
    required this.title,
    required this.arabicText,
    required this.transliteration,
    required this.translation,
    this.source,
    required this.order,
  });

  factory Dua.fromJson(Map<String, dynamic> json) => Dua(
        id: json['id'],
        categoryId: json['dua_category_id'],
        title: json['title'],
        arabicText: json['arabic_text'],
        transliteration: json['transliteration'],
        translation: json['translation'],
        source: json['source'],
        order: json['order'] ?? 0,
      );
}

class DuaService {
  late final SupabaseClient _supabase;

  DuaService() {
    _supabase = Supabase.instance.client;
  }

  Future<List<DuaCategory>> getCategories() async {
    final response = await _supabase
        .from('dua_categories')
        .select()
        .order('name', ascending: true);

    return (response as List).map((e) => DuaCategory.fromJson(e)).toList();
  }

  Future<List<Dua>> getDuasByCategory(int categoryId) async {
    final response = await _supabase
        .from('duas')
        .select()
        .eq('dua_category_id', categoryId)
        .order('order', ascending: true);

    return (response as List).map((e) => Dua.fromJson(e)).toList();
  }
}