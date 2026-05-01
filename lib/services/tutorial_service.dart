import 'package:supabase_flutter/supabase_flutter.dart';

// ============================================================
// MODELS
// ============================================================

class Tutorial {
  final int id;
  final String title;
  final String slug;
  final String? description;
  final String? category;
  final String? thumbnail;
  final bool isPublished;
  final int order;

  Tutorial({
    required this.id,
    required this.title,
    required this.slug,
    this.description,
    this.category,
    this.thumbnail,
    required this.isPublished,
    required this.order,
  });

  factory Tutorial.fromJson(Map<String, dynamic> json) => Tutorial(
    id: json['id'],
    title: json['title'],
    slug: json['slug'],
    description: json['description'],
    category: json['category'],
    thumbnail: json['thumbnail'],
    isPublished: json['is_published'] ?? false,
    order: json['order'] ?? 0,
  );
}

class TutorialStep {
  final int id;
  final int tutorialId;
  final int stepNumber;
  final String title;
  final String? description;
  final String? imagePath;
  final String? arabicText;
  final String? transliteration;

  TutorialStep({
    required this.id,
    required this.tutorialId,
    required this.stepNumber,
    required this.title,
    this.description,
    this.imagePath,
    this.arabicText,
    this.transliteration,
  });

  factory TutorialStep.fromJson(Map<String, dynamic> json) => TutorialStep(
    id: json['id'],
    tutorialId: json['tutorial_id'],
    stepNumber: json['step_number'],
    title: json['title'],
    description: json['description'],
    imagePath: json['image_path'],
    arabicText: json['arabic_text'],
    transliteration: json['transliteration'],
  );
}

// ============================================================
// SERVICE
// ============================================================

class TutorialService {
  late final SupabaseClient _supabase;

  TutorialService() {
    _supabase = Supabase.instance.client;
  }

  // Ambil semua tutorial yang published, dikelompokkan by category
  Future<List<Tutorial>> getTutorials({String? category}) async {
    var query = _supabase.from('tutorials').select().eq('is_published', true);

    if (category != null) {
      query = query.eq('category', category);
    }

    final response = await query.order('order', ascending: true);
    return (response as List).map((e) => Tutorial.fromJson(e)).toList();
  }

  // Ambil satu tutorial by slug
  Future<Tutorial?> getTutorialBySlug(String slug) async {
    final response = await _supabase
        .from('tutorials')
        .select()
        .eq('slug', slug)
        .eq('is_published', true)
        .maybeSingle();

    if (response == null) return null;
    return Tutorial.fromJson(response);
  }

  // Ambil semua steps dari satu tutorial
  Future<List<TutorialStep>> getSteps(int tutorialId) async {
    final response = await _supabase
        .from('tutorial_steps')
        .select()
        .eq('tutorial_id', tutorialId)
        .order('step_number', ascending: true);

    return (response as List).map((e) => TutorialStep.fromJson(e)).toList();
  }

  // Ambil tutorial beserta semua steps-nya sekaligus
  Future<Map<String, dynamic>> getTutorialWithSteps(int tutorialId) async {
    final tutorialRes = await _supabase
        .from('tutorials')
        .select()
        .eq('id', tutorialId)
        .eq('is_published', true)
        .single();

    final stepsRes = await _supabase
        .from('tutorial_steps')
        .select()
        .eq('tutorial_id', tutorialId)
        .order('step_number', ascending: true);

    return {
      'tutorial': Tutorial.fromJson(tutorialRes),
      'steps': (stepsRes as List).map((e) => TutorialStep.fromJson(e)).toList(),
    };
  }
}
