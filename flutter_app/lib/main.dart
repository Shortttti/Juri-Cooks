import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _ink = Color(0xFF35231E);
const _coffee = Color(0xFF54382D);
const _caramel = Color(0xFFC88261);
const _rose = Color(0xFFB76555);
const _sage = Color(0xFF7C896C);
const _paper = Color(0xFFF7F0E5);
const _cream = Color(0xFFFFFBF4);

void main() => runApp(const JuriCooksApp());

class JuriCooksApp extends StatelessWidget {
  const JuriCooksApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Juri Cooks',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: _paper,
        colorScheme: ColorScheme.fromSeed(seedColor: _sage, surface: _paper),
        fontFamily: 'Arial',
        appBarTheme: const AppBarTheme(backgroundColor: _ink, foregroundColor: _cream),
      ),
      home: const Directionality(textDirection: TextDirection.rtl, child: BakeryHome()),
    );
  }
}

class Ingredient {
  const Ingredient(this.metric, this.cups);
  final String metric;
  final String cups;
  Map<String, Object> toJson() => {'metric': metric, 'cups': cups};
  factory Ingredient.fromJson(Map<String, dynamic> json) =>
      Ingredient('${json['metric'] ?? ''}', '${json['cups'] ?? json['metric'] ?? ''}');
}

class Recipe {
  Recipe({
    required this.id,
    required this.title,
    required this.category,
    required this.description,
    required this.time,
    required this.servings,
    required this.emoji,
    required this.ingredients,
    required this.steps,
    this.favorite = false,
    this.rating = 0,
    this.bakeCount = 0,
    this.note = '',
  });
  final String id;
  final String title;
  final String category;
  final String description;
  final int time;
  final String servings;
  final String emoji;
  final List<Ingredient> ingredients;
  final List<String> steps;
  bool favorite;
  int rating;
  int bakeCount;
  String note;

  Map<String, Object> toJson() => {
        'id': id,
        'title': title,
        'category': category,
        'description': description,
        'time': time,
        'servings': servings,
        'emoji': emoji,
        'ingredients': ingredients.map((e) => e.toJson()).toList(),
        'steps': steps,
        'favorite': favorite,
        'rating': rating,
        'bakeCount': bakeCount,
        'note': note,
      };

  factory Recipe.fromJson(Map<String, dynamic> json) => Recipe(
        id: '${json['id']}',
        title: '${json['title']}',
        category: '${json['category'] ?? 'حلويات'}',
        description: '${json['description'] ?? ''}',
        time: (json['time'] as num?)?.toInt() ?? 30,
        servings: '${json['servings'] ?? 'على مزاجك'}',
        emoji: '${json['emoji'] ?? '🧁'}',
        ingredients: (json['ingredients'] as List? ?? const [])
            .map((e) => Ingredient.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList(),
        steps: List<String>.from(json['steps'] as List? ?? const []),
        favorite: json['favorite'] == true,
        rating: (json['rating'] as num?)?.toInt() ?? 0,
        bakeCount: (json['bakeCount'] as num?)?.toInt() ?? 0,
        note: '${json['note'] ?? ''}',
      );
}

List<Recipe> _starterRecipes() => [
      Recipe(
        id: 'cinnamon-rolls',
        title: 'سينامون رول طري',
        category: 'حلويات',
        description: 'لفائف قرفة دافئة بقلب طري وصوص جبن كريمي يذوب فوقها.',
        time: 125,
        servings: '9–10 حبات',
        emoji: '🥮',
        ingredients: const [
          Ingredient('500 جم دقيق أبيض', '4 أكواب دقيق (بالملعقة ثم يُسوّى)'),
          Ingredient('250 مل حليب دافئ', '1 كوب + 2 ملعقة صغيرة حليب دافئ'),
          Ingredient('7 جم خميرة فورية', '2¼ ملعقة صغيرة خميرة فورية'),
          Ingredient('70 جم سكر', '⅓ كوب + 1 ملعقة صغيرة سكر'),
          Ingredient('1 بيضة كبيرة', '1 بيضة كبيرة'),
          Ingredient('60 جم زبدة طرية', '¼ كوب + 1 ملعقة صغيرة زبدة طرية'),
          Ingredient('½ ملعقة صغيرة ملح', '½ ملعقة صغيرة ملح'),
          Ingredient('1 ملعقة صغيرة فانيليا', '1 ملعقة صغيرة فانيليا'),
          Ingredient('للحشوة: 80 جم زبدة طرية', 'للحشوة: ⅓ كوب + 1 ملعقة صغيرة زبدة طرية'),
          Ingredient('120 جم سكر بني', '½ كوب + 2 ملعقة صغيرة سكر بني معبأ'),
          Ingredient('1½–2 ملعقة كبيرة قرفة', '1½–2 ملعقة كبيرة قرفة'),
          Ingredient('للصوص: 100 جم جبن كريمي', 'للصوص: 7 ملاعق كبيرة جبن كريمي'),
          Ingredient('40 جم زبدة طرية', '2 ملعقة كبيرة + 2 ملعقة صغيرة زبدة طرية'),
          Ingredient('80–100 جم سكر بودرة', '⅔–¾ كوب + حتى 1 ملعقة كبيرة سكر بودرة'),
          Ingredient('فانيليا و1–2 ملعقة كبيرة حليب', 'فانيليا و1–2 ملعقة كبيرة حليب'),
          Ingredient('اختياري: 60 مل كريمة خفق دافئة', 'اختياري: ¼ كوب كريمة خفق دافئة'),
        ],
        steps: const [
          'اخلطي الحليب الدافئ مع الخميرة وقليل من السكر واتركيه 5 دقائق. أضيفي البيضة وباقي السكر والفانيليا.',
          'أضيفي الدقيق والملح واعجني 6–8 دقائق، ثم أضيفي الزبدة تدريجيًا حتى تصبح العجينة ناعمة ومطاطية.',
          'غطي العجينة واتركيها تختمر حتى يتضاعف حجمها، حوالي ساعة. افرديها ووزعي الزبدة والسكر البني والقرفة.',
          'لفي العجينة وقطعيها إلى 9 أو 10 قطع. رتبيها في الصينية واتركيها تختمر 30–45 دقيقة.',
          'اخبزيها على 175°م لمدة 20–25 دقيقة حتى يصبح لونها ذهبيًا خفيفًا.',
          'اخلطي مكونات الصوص ووزعيه على السينامون وهو دافئ.',
        ],
      ),
      Recipe(
        id: 'quick-sandwich-bread',
        title: 'خبز ساندويتش دائري سريع',
        category: 'فطور',
        description: 'خبز زبادي سريع على المقلاة؛ طري ودافئ، مناسب لساندويتش خفيف.',
        time: 25,
        servings: '6 حبات',
        emoji: '🥯',
        ingredients: const [
          Ingredient('250 جم دقيق (يعادل كوبين ممسوحين)', '2 كوب دقيق، يُملأ بالملعقة ويُسوّى'),
          Ingredient('245 جم زبادي', '1 كوب زبادي'),
          Ingredient('8 جم بيكنج باودر', '2 ملعقة صغيرة بيكنج باودر'),
          Ingredient('3 جم ملح', '½ ملعقة صغيرة ملح'),
          Ingredient('4 جم سكر', '1 ملعقة صغيرة سكر'),
          Ingredient('15 مل زيت (نحو 14 جم)', '1 ملعقة كبيرة زيت'),
          Ingredient('قليل من الزبدة للدهن (اختياري)', 'قليل من الزبدة للدهن (اختياري)'),
        ],
        steps: const [
          'اخلطي الدقيق والبيكنج باودر والملح والسكر. أضيفي الزبادي والزيت واعجني 2–3 دقائق.',
          'إذا كانت العجينة لاصقة جدًا، أضيفي رشة دقيق بسيطة. قسميها إلى 6 كرات.',
          'افردي كل كرة بشكل دائري بسماكة نحو 1 سم.',
          'سخني مقلاة على نار متوسطة، واطهي كل خبزة 2–3 دقائق لكل جهة.',
          'ادهنيها بلمسة زبدة وغطيها بفوطة نظيفة 5 دقائق لتبقى طرية.',
        ],
      ),
    ];

class BakeryHome extends StatefulWidget {
  const BakeryHome({super.key});
  @override
  State<BakeryHome> createState() => _BakeryHomeState();
}

class _BakeryHomeState extends State<BakeryHome> with TickerProviderStateMixin {
  final _scroll = ScrollController();
  final _recipesKey = GlobalKey();
  late final AnimationController _ambient = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 7),
  )..repeat(reverse: true);
  List<Recipe> _recipes = _starterRecipes();
  List<Recipe> _custom = [];
  final Set<String> _tray = {};
  final Set<String> _checked = {};
  String _category = 'الكل';
  String _query = '';
  bool _loading = true;
  bool _cups = false;
  int _tab = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString('juri.custom');
    if (saved != null) {
      try {
        _custom = (jsonDecode(saved) as List)
            .map((e) => Recipe.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList();
      } catch (_) {}
    }
    final favorites = prefs.getStringList('juri.favorites') ?? [];
    final baked = prefs.getStringList('juri.bakes') ?? [];
    final notes = prefs.getStringList('juri.notes') ?? [];
    _recipes = [..._starterRecipes(), ..._custom];
    for (final recipe in _recipes) {
      recipe.favorite = favorites.contains(recipe.id);
      recipe.bakeCount = baked.where((id) => id == recipe.id).length;
      final matchingNotes = notes.where((n) => n.startsWith('${recipe.id}::'));
      if (matchingNotes.isNotEmpty) {
        final note = matchingNotes.first;
        recipe.note = note.substring(recipe.id.length + 2);
      }
    }
    _tray
      ..clear()
      ..addAll(prefs.getStringList('juri.tray') ?? []);
    _checked
      ..clear()
      ..addAll(prefs.getStringList('juri.checked') ?? []);
    _cups = prefs.getBool('juri.cups') ?? false;
    if (mounted) setState(() => _loading = false);
  }

  Future<SharedPreferences> get _prefs => SharedPreferences.getInstance();

  Future<void> _save() async {
    final prefs = await _prefs;
    await prefs.setString('juri.custom', jsonEncode(_custom.map((e) => e.toJson()).toList()));
    await prefs.setStringList('juri.favorites', _recipes.where((r) => r.favorite).map((r) => r.id).toList());
    await prefs.setStringList('juri.tray', _tray.toList());
    await prefs.setStringList('juri.checked', _checked.toList());
    await prefs.setStringList('juri.bakes', [
      for (final r in _recipes)
        for (var i = 0; i < r.bakeCount; i++) r.id,
    ]);
    await prefs.setStringList('juri.notes', [for (final r in _recipes) if (r.note.isNotEmpty) '${r.id}::${r.note}']);
    await prefs.setBool('juri.cups', _cups);
  }

  List<Recipe> get _shown => _recipes.where((r) {
        final matchesCategory = _category == 'الكل' ||
            (_category == 'المفضلة' ? r.favorite : r.category == _category);
        final q = _query.trim().toLowerCase();
        final matchesQuery = q.isEmpty ||
            '${r.title} ${r.description} ${r.category}'.toLowerCase().contains(q);
        return matchesCategory && matchesQuery;
      }).toList();

  void _toast(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text(message, textDirection: TextDirection.rtl),
        behavior: SnackBarBehavior.floating,
        backgroundColor: _coffee,
        duration: const Duration(seconds: 2),
      ));
  }

  void _toggleFavorite(Recipe recipe) {
    setState(() => recipe.favorite = !recipe.favorite);
    _save();
    _toast(recipe.favorite ? 'انضافت للمفضّلة ♡' : 'انشالت من المفضّلة');
  }

  void _toggleTray(Recipe recipe) {
    setState(() {
      if (!_tray.add(recipe.id)) {
        _tray.remove(recipe.id);
        _checked.removeWhere((key) => key.startsWith('${recipe.id}:'));
      }
    });
    _save();
    _toast(_tray.contains(recipe.id) ? 'انضافت لصينيتك ✨' : 'انشالت من الصينية');
  }

  Future<void> _openTray() async {
    setState(() => _tab = 0);
    final selected = _recipes.where((r) => _tray.contains(r.id)).toList();
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _TraySheet(
        recipes: selected,
        cups: _cups,
        checked: _checked,
        onUnitChange: (value) { setState(() => _cups = value); _save(); },
        onCheck: (key, value) {
          setState(() => value ? _checked.add(key) : _checked.remove(key));
          _save();
        },
        onRemove: (recipe) { _toggleTray(recipe); },
        onOpen: (recipe) => _openRecipe(recipe),
        onClear: () { setState(() { _tray.clear(); _checked.clear(); }); _save(); },
        onCopy: () {
          final lines = selected.expand((r) => [r.title, ...r.ingredients.map((i) => '☐ ${_cups ? i.cups : i.metric}')]).join('\n');
          Clipboard.setData(ClipboardData(text: lines));
          _toast('قائمة المقادير جاهزة للنسخ ♡');
        },
      ),
    );
  }

  Future<void> _openRecipe(Recipe recipe) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _RecipeSheet(
        recipe: recipe,
        cups: _cups,
        onUnitChange: (value) { setState(() => _cups = value); _save(); },
        onFavorite: () => _toggleFavorite(recipe),
        onTray: () => _toggleTray(recipe),
        onBaked: () {
          setState(() => recipe.bakeCount++);
          _save();
          Navigator.pop(context);
          _celebrate();
        },
        onCook: () => _openCookMode(recipe),
        onNoteChanged: _save,
      ),
    );
  }

  Future<void> _openCookMode(Recipe recipe) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _CookDialog(recipe: recipe),
    );
  }

  void _celebrate() {
    _toast('انختمت في سجل مخبوزاتك! ✦ بالعافية يا جوري');
  }

  void _surprise() {
    if (_recipes.isEmpty) return;
    final recipe = _recipes[math.Random().nextInt(_recipes.length)];
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: _cream,
        icon: Text(recipe.emoji, style: const TextStyle(fontSize: 54)),
        title: const Text('اختيار مخبز جوري ✨', textAlign: TextAlign.center),
        content: Text(recipe.title, textAlign: TextAlign.center),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('اختاري غيرها')),
          FilledButton(onPressed: () { Navigator.pop(context); _openRecipe(recipe); }, child: const Text('افتحيها')),
        ],
      ),
    );
  }

  Future<void> _addRecipe() async {
    final title = TextEditingController();
    final desc = TextEditingController();
    final ingredients = TextEditingController();
    final steps = TextEditingController();
    String category = 'حلويات';
    final ok = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialog) => AlertDialog(
          backgroundColor: _cream,
          title: const Text('وصفة جديدة ♡'),
          content: SizedBox(
            width: 440,
            child: SingleChildScrollView(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                _field(title, 'اسم الوصفة'),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: category,
                  decoration: const InputDecoration(labelText: 'التصنيف', border: OutlineInputBorder()),
                  items: const ['حلويات', 'مخبوزات', 'فطور', 'مشروبات', 'أخرى']
                      .map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                  onChanged: (v) => setDialog(() => category = v ?? category),
                ),
                const SizedBox(height: 10),
                _field(desc, 'وصف بسيط'),
                const SizedBox(height: 10),
                _field(ingredients, 'المقادير (كل مكوّن بسطر)', lines: 4),
                const SizedBox(height: 10),
                _field(steps, 'الطريقة (كل خطوة بسطر)', lines: 4),
              ]),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('إلغاء')),
            FilledButton(onPressed: () => Navigator.pop(dialogContext, true), child: const Text('احفظي الوصفة')),
          ],
        ),
      ),
    );
    if (ok == true && title.text.trim().isNotEmpty) {
      final ing = ingredients.text.split('\n').where((e) => e.trim().isNotEmpty).map((e) => Ingredient(e.trim(), e.trim())).toList();
      final method = steps.text.split('\n').where((e) => e.trim().isNotEmpty).toList();
      final recipe = Recipe(
        id: 'custom-${DateTime.now().millisecondsSinceEpoch}',
        title: title.text.trim(), category: category,
        description: desc.text.trim().isEmpty ? 'وصفة جديدة من دفتر جوري.' : desc.text.trim(),
        time: 30, servings: 'على مزاجك', emoji: '🧁',
        ingredients: ing, steps: method.isEmpty ? ['أضيفي خطوات وصفتك من تفاصيلها.'] : method,
      );
      setState(() { _custom.insert(0, recipe); _recipes.insert(0, recipe); _category = 'الكل'; });
      await _save();
      _toast('انحفظت وصفتك في الدفتر ♡');
    }
    title.dispose(); desc.dispose(); ingredients.dispose(); steps.dispose();
  }

  Widget _field(TextEditingController controller, String label, {int lines = 1}) => TextField(
        controller: controller,
        maxLines: lines,
        textDirection: TextDirection.rtl,
        decoration: InputDecoration(labelText: label, alignLabelWithHint: true, border: const OutlineInputBorder()),
      );

  void _goRecipes() {
    setState(() => _tab = 1);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ctx = _recipesKey.currentContext;
      if (ctx != null) Scrollable.ensureVisible(ctx, duration: const Duration(milliseconds: 650), curve: Curves.easeOutCubic);
    });
  }

  @override
  void dispose() {
    _scroll.dispose();
    _ambient.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final shown = _shown;
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: _loading
            ? const Center(child: CircularProgressIndicator(color: _sage))
            : CustomScrollView(
                controller: _scroll,
                slivers: [
                  SliverToBoxAdapter(child: _topBar()),
                  SliverToBoxAdapter(child: _hero()),
                  SliverToBoxAdapter(child: _welcome()),
                  SliverToBoxAdapter(key: _recipesKey, child: _sectionHeader()),
                  SliverToBoxAdapter(child: _search()),
                  SliverToBoxAdapter(child: _categories()),
                  if (shown.isEmpty)
                    const SliverFillRemaining(hasScrollBody: false, child: Center(child: Text('ما لقينا وصفة بهذا الاسم ☁')))
                  else
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(18, 8, 18, 120),
                      sliver: SliverList.separated(
                        itemCount: shown.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 14),
                        itemBuilder: (context, i) => _RecipeCard(
                          recipe: shown[i],
                          inTray: _tray.contains(shown[i].id),
                          onOpen: () => _openRecipe(shown[i]),
                          onFavorite: () => _toggleFavorite(shown[i]),
                          onTray: () => _toggleTray(shown[i]),
                          delay: i,
                        ),
                      ),
                    ),
                ],
              ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'add-recipe',
        backgroundColor: _rose,
        foregroundColor: Colors.white,
        onPressed: _addRecipe,
        icon: const Icon(Icons.add_rounded),
        label: const Text('وصفة جديدة'),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        backgroundColor: _cream,
        indicatorColor: const Color(0xFFEDE3D5),
        onDestinationSelected: (index) {
          if (index == 0) {
            setState(() => _tab = 0);
            _scroll.animateTo(0, duration: const Duration(milliseconds: 550), curve: Curves.easeOutCubic);
          } else if (index == 1) {
            _goRecipes();
          } else {
            _openTray();
          }
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.storefront_outlined), selectedIcon: Icon(Icons.storefront), label: 'المخبز'),
          NavigationDestination(icon: Icon(Icons.menu_book_outlined), selectedIcon: Icon(Icons.menu_book), label: 'الوصفات'),
          NavigationDestination(icon: Icon(Icons.shopping_basket_outlined), selectedIcon: Icon(Icons.shopping_basket), label: 'صينيتي'),
        ],
      ),
    );
  }

  Widget _topBar() => Padding(
        padding: const EdgeInsets.fromLTRB(18, 8, 18, 0),
        child: Row(children: [
          Container(
            height: 48, width: 48,
            decoration: BoxDecoration(color: _coffee, borderRadius: BorderRadius.circular(16)),
            child: const Center(child: Text('j✳', style: TextStyle(color: _cream, fontSize: 22, fontStyle: FontStyle.italic, fontWeight: FontWeight.w700))),
          ),
          const SizedBox(width: 10),
          const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Juri Cooks', style: TextStyle(color: _ink, fontSize: 20, fontWeight: FontWeight.w800)),
            Text("JURI'S LITTLE BAKERY", style: TextStyle(color: _sage, fontSize: 9, letterSpacing: 1.4, fontWeight: FontWeight.w700)),
          ])),
          IconButton.filledTonal(onPressed: _surprise, icon: const Icon(Icons.auto_awesome_rounded), tooltip: 'فاجئيني'),
          const SizedBox(width: 4),
          IconButton.filled(onPressed: _openTray, style: IconButton.styleFrom(backgroundColor: _ink, foregroundColor: _cream), icon: Badge(label: Text('${_tray.length}'), child: const Icon(Icons.shopping_basket_outlined)), tooltip: 'صينيتي'),
        ]),
      );

  Widget _hero() => Padding(
        padding: const EdgeInsets.fromLTRB(18, 17, 18, 8),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            gradient: const LinearGradient(begin: Alignment.topRight, end: Alignment.bottomLeft, colors: [_ink, Color(0xFF59382B), Color(0xFF2A1B18)]),
            boxShadow: [BoxShadow(color: _ink.withOpacity(.18), blurRadius: 25, offset: const Offset(0, 13))],
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 24, 22, 0),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(mainAxisSize: MainAxisSize.min, children: [
                  const Icon(Icons.auto_awesome, size: 15, color: Color(0xFFFFD78E)),
                  const SizedBox(width: 7),
                  Text("JURI'S LITTLE BAKERY  ·  أهلاً بك", style: TextStyle(color: Colors.white.withOpacity(.72), fontSize: 10, letterSpacing: .5)),
                ]),
                const SizedBox(height: 12),
                const Text('ريحة الخَبز\nتدلّك علينا.', textAlign: TextAlign.right,
                    style: TextStyle(color: _cream, fontSize: 32, height: 1.35, fontWeight: FontWeight.w800)),
                const SizedBox(height: 8),
                Text('افتحي الباب، خذي لك شيء دافئ من الفرن، واختاري وصفتك القادمة.',
                    style: TextStyle(color: Colors.white.withOpacity(.73), fontSize: 12, height: 1.8)),
              ]),
            ),
            AnimatedBuilder(
              animation: _ambient,
              builder: (context, _) => _BakeryScene(progress: _ambient.value),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
              child: Row(children: [
                _stat('${_recipes.length}', 'وصفات'),
                _stat('${_recipes.where((r) => r.favorite).length}', 'مفضّلة'),
                _stat('${_recipes.fold<int>(0, (n, r) => n + r.bakeCount)}', 'ختم خَبز ✦'),
              ]),
            ),
          ]),
        ),
      );

  Widget _stat(String number, String label) => Expanded(child: Column(children: [
    Text(number, style: const TextStyle(color: Color(0xFFFFD78E), fontSize: 18, fontWeight: FontWeight.w800)),
    const SizedBox(height: 2),
    Text(label, style: TextStyle(color: Colors.white.withOpacity(.7), fontSize: 10)),
  ]));

  Widget _welcome() => Padding(
        padding: const EdgeInsets.fromLTRB(18, 10, 18, 20),
        child: InkWell(
          onTap: _surprise,
          borderRadius: BorderRadius.circular(20),
          child: Ink(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: const Color(0xFFE7E9DC), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white)),
            child: Row(children: [
              Container(width: 42, height: 42, decoration: const BoxDecoration(color: Color(0xFFD5DDCA), shape: BoxShape.circle), child: const Icon(Icons.local_fire_department_rounded, color: _sage)),
              const SizedBox(width: 12),
              const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('ريحة القرفة طالعة من الفرن!', style: TextStyle(fontWeight: FontWeight.w800, color: _ink, fontSize: 13)),
                SizedBox(height: 4), Text('اضغطي هنا وخلي المخبز يختار لك.', style: TextStyle(fontSize: 10, color: _sage)),
              ])),
              const Icon(Icons.arrow_back_ios_new_rounded, size: 14, color: _sage),
            ]),
          ),
        ),
      );

  Widget _sectionHeader() => Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
        child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
          const Icon(Icons.waves_rounded, color: _rose, size: 17),
          const SizedBox(width: 7),
          const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text("FRESH FROM JURI'S OVEN", style: TextStyle(color: _sage, fontSize: 9, letterSpacing: 1.2, fontWeight: FontWeight.w800)),
            SizedBox(height: 4), Text('واجهة العرض اليوم', style: TextStyle(color: _ink, fontWeight: FontWeight.w800, fontSize: 23)),
          ])),
          Text('${_shown.length} وصفة', style: const TextStyle(color: _sage, fontSize: 11)),
        ]),
      );

  Widget _search() => Padding(
        padding: const EdgeInsets.fromLTRB(18, 10, 18, 4),
        child: TextField(
          textDirection: TextDirection.rtl,
          onChanged: (v) => setState(() => _query = v),
          decoration: InputDecoration(
            hintText: 'ابحثي عن وصفة...',
            prefixIcon: const Icon(Icons.search_rounded, color: _sage),
            filled: true, fillColor: _cream,
            contentPadding: const EdgeInsets.symmetric(vertical: 12),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none),
          ),
        ),
      );

  Widget _categories() {
    final cats = ['الكل', 'مخبوزات', 'فطور', 'حلويات', 'مفضلة', ..._recipes.map((r) => r.category).toSet()];
    final unique = cats.toSet().toList();
    return SizedBox(
      height: 52,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 5),
        scrollDirection: Axis.horizontal,
        itemCount: unique.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final cat = unique[i];
          final active = cat == _category;
          return ChoiceChip(
            label: Text(cat == 'مفضلة' ? '♡ المفضلة' : cat),
            selected: active,
            onSelected: (_) => setState(() => _category = cat),
            showCheckmark: false,
            selectedColor: _ink,
            backgroundColor: _cream,
            labelStyle: TextStyle(color: active ? _cream : _coffee, fontWeight: FontWeight.w600, fontSize: 11),
            side: BorderSide(color: active ? _ink : const Color(0xFFE8DDCF)),
            shape: const StadiumBorder(),
          );
        },
      ),
    );
  }
}

class _BakeryScene extends StatelessWidget {
  const _BakeryScene({required this.progress});
  final double progress;
  @override
  Widget build(BuildContext context) {
    final bob = math.sin(progress * math.pi * 2) * 5;
    return SizedBox(
      height: 235,
      child: Stack(clipBehavior: Clip.none, alignment: Alignment.center, children: [
        Positioned(top: 20, child: Container(width: 245, height: 170, decoration: BoxDecoration(color: const Color(0xFF4A3028), border: Border.all(color: const Color(0xFFB5855F), width: 5), borderRadius: const BorderRadius.vertical(top: Radius.circular(120)), boxShadow: const [BoxShadow(color: Color(0x88350F08), blurRadius: 14)]))),
        Positioned(top: 78, child: Container(width: 215, height: 77, decoration: BoxDecoration(color: const Color(0xFF281916), border: Border.all(color: const Color(0xFFAD8057), width: 4)), child: const Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [Icon(Icons.bakery_dining, color: Color(0xFFE5B372), size: 30), Icon(Icons.breakfast_dining, color: Color(0xFFF2CE9B), size: 30), Icon(Icons.cake_outlined, color: Color(0xFFDF9B7B), size: 30)]))),
        Positioned(top: 7, child: Container(width: 260, height: 28, decoration: BoxDecoration(color: const Color(0xFFE2BD8B), borderRadius: BorderRadius.circular(5), boxShadow: const [BoxShadow(color: Color(0x559D543E), blurRadius: 5)]))),
        Positioned(top: 35, child: Container(width: 122, padding: const EdgeInsets.symmetric(vertical: 7), decoration: BoxDecoration(color: const Color(0xFF30201B), border: Border.all(color: const Color(0xFFE4BE87))), child: const Column(children: [Text('Juri Cooks', style: TextStyle(color: Color(0xFFFFE1B2), fontSize: 16, fontStyle: FontStyle.italic, fontWeight: FontWeight.w700)), Text('FRESH FROM THE OVEN', style: TextStyle(color: Color(0xFFECCB9A), fontSize: 6, letterSpacing: 1.1))]))),
        Positioned(bottom: 17, child: Container(width: 295, height: 65, decoration: BoxDecoration(color: const Color(0xFF996447), border: Border.all(color: const Color(0xFFD3A16C), width: 4), borderRadius: BorderRadius.circular(7)), child: const Center(child: Text('BAKED WITH LOVE  ✳', style: TextStyle(color: Color(0xFFFFDEAC), fontSize: 10, letterSpacing: 1.5, fontWeight: FontWeight.w700))))),
        Positioned(bottom: 75 + bob, left: 52, child: const _Cloche(emoji: '🥐')),
        Positioned(bottom: 75 - bob, child: const _Cloche(emoji: '🧁')),
        Positioned(bottom: 75 + bob * .7, right: 52, child: const _Cloche(emoji: '🍪')),
        Positioned(top: 90 + bob, left: 58, child: const Icon(Icons.auto_awesome, color: Color(0xFFFFD889), size: 18)),
        Positioned(top: 119 - bob, right: 38, child: const Icon(Icons.star_rounded, color: Color(0xFFFFD889), size: 20)),
      ]),
    );
  }
}

class _Cloche extends StatelessWidget {
  const _Cloche({required this.emoji});
  final String emoji;
  @override
  Widget build(BuildContext context) => Container(
        width: 58, height: 54,
        decoration: BoxDecoration(color: Colors.white.withOpacity(.08), border: Border.all(color: const Color(0xFFEDD9BD).withOpacity(.65), width: 1.4), borderRadius: const BorderRadius.vertical(top: Radius.circular(40), bottom: Radius.circular(5))),
        alignment: Alignment.bottomCenter,
        padding: const EdgeInsets.only(bottom: 2),
        child: Text(emoji, style: const TextStyle(fontSize: 27)),
      );
}

class _RecipeCard extends StatefulWidget {
  const _RecipeCard({required this.recipe, required this.inTray, required this.onOpen, required this.onFavorite, required this.onTray, required this.delay});
  final Recipe recipe;
  final bool inTray;
  final VoidCallback onOpen;
  final VoidCallback onFavorite;
  final VoidCallback onTray;
  final int delay;
  @override
  State<_RecipeCard> createState() => _RecipeCardState();
}

class _RecipeCardState extends State<_RecipeCard> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(vsync: this, duration: const Duration(seconds: 4))..repeat();
  bool _pressed = false;
  @override
  void dispose() { _controller.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) {
    final r = widget.recipe;
    final tint = r.category == 'فطور' ? const Color(0xFFE2EBDD) : const Color(0xFFF1E2D3);
    return AnimatedScale(
      scale: _pressed ? .985 : 1,
      duration: const Duration(milliseconds: 180),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _pressed = true),
        onTapCancel: () => setState(() => _pressed = false),
        onTapUp: (_) => setState(() => _pressed = false),
        onTap: widget.onOpen,
        child: Container(
          decoration: BoxDecoration(color: _cream, borderRadius: BorderRadius.circular(24), border: Border.all(color: const Color(0xFFECE1D3)), boxShadow: const [BoxShadow(color: Color(0x10000000), blurRadius: 14, offset: Offset(0, 6))]),
          clipBehavior: Clip.antiAlias,
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            SizedBox(
              height: 155,
              child: Stack(alignment: Alignment.center, children: [
                Positioned.fill(child: DecoratedBox(decoration: BoxDecoration(gradient: LinearGradient(colors: [tint, tint.withOpacity(.72)])))),
                Container(width: 116, height: 116, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withOpacity(.5), boxShadow: const [BoxShadow(color: Color(0x183E2B20), blurRadius: 19, offset: Offset(0, 8))])),
                AnimatedBuilder(animation: _controller, builder: (_, __) => Transform.translate(offset: Offset(0, math.sin(_controller.value * 2 * math.pi) * 4), child: Text(r.emoji, style: const TextStyle(fontSize: 72)))),
                Positioned(top: 12, right: 13, child: _pill(r.category, color: Colors.white.withOpacity(.84), foreground: _coffee)),
                Positioned(top: 8, left: 8, child: IconButton.filledTonal(onPressed: widget.onFavorite, style: IconButton.styleFrom(backgroundColor: Colors.white.withOpacity(.86)), icon: Icon(r.favorite ? Icons.favorite_rounded : Icons.favorite_border_rounded, size: 18, color: r.favorite ? _rose : _coffee))),
                Positioned.fill(child: _CardShimmer(controller: _controller)),
              ]),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 13),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(r.title, style: const TextStyle(color: _ink, fontSize: 16, fontWeight: FontWeight.w800)),
                const SizedBox(height: 5),
                Text(r.description, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Color(0xFF8B7B70), fontSize: 11, height: 1.65)),
                const SizedBox(height: 12),
                Row(children: [
                  const Icon(Icons.schedule_rounded, size: 15, color: _sage),
                  const SizedBox(width: 4),
                  Text('${r.time} دقيقة · ${r.servings}', style: const TextStyle(fontSize: 10, color: _coffee)),
                  const Spacer(),
                  if (r.bakeCount > 0) const Icon(Icons.local_fire_department_rounded, size: 14, color: _caramel),
                  if (r.bakeCount > 0) Text(' ${r.bakeCount}', style: const TextStyle(fontSize: 10, color: _coffee)),
                ]),
                const SizedBox(height: 12),
                Row(children: [
                  Expanded(child: OutlinedButton.icon(onPressed: widget.onTray, icon: Icon(widget.inTray ? Icons.check_rounded : Icons.add_rounded, size: 17), label: Text(widget.inTray ? 'بالصينية' : 'أضيفي للصينية'), style: OutlinedButton.styleFrom(foregroundColor: widget.inTray ? _sage : _coffee, side: BorderSide(color: widget.inTray ? _sage : const Color(0xFFDCCBBB)), minimumSize: const Size(0, 42), textStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700)))),
                  const SizedBox(width: 9),
                  Expanded(child: FilledButton(onPressed: widget.onOpen, style: FilledButton.styleFrom(backgroundColor: _ink, foregroundColor: _cream, minimumSize: const Size(0, 42), textStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700)), child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [Text('افتحي الوصفة'), SizedBox(width: 5), Icon(Icons.arrow_back_rounded, size: 14)]))),
                ]),
              ]),
            ),
          ]),
        ),
      ),
    );
  }
  Widget _pill(String text, {required Color color, required Color foreground}) => Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(20)), child: Text(text, style: TextStyle(fontSize: 9, color: foreground, fontWeight: FontWeight.w700)));
}

class _CardShimmer extends StatelessWidget {
  const _CardShimmer({required this.controller});
  final AnimationController controller;
  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: controller,
        builder: (_, __) => FractionalTranslation(
          translation: Offset(controller.value * 2.6 - 1.3, 0),
          child: Container(width: 52, decoration: BoxDecoration(gradient: LinearGradient(colors: [Colors.transparent, Colors.white.withOpacity(.28), Colors.transparent]))),
        ),
      );
}

class _RecipeSheet extends StatefulWidget {
  const _RecipeSheet({required this.recipe, required this.cups, required this.onUnitChange, required this.onFavorite, required this.onTray, required this.onBaked, required this.onCook, required this.onNoteChanged});
  final Recipe recipe;
  final bool cups;
  final ValueChanged<bool> onUnitChange;
  final VoidCallback onFavorite;
  final VoidCallback onTray;
  final VoidCallback onBaked;
  final VoidCallback onCook;
  final VoidCallback onNoteChanged;
  @override
  State<_RecipeSheet> createState() => _RecipeSheetState();
}

class _RecipeSheetState extends State<_RecipeSheet> {
  late bool _cups = widget.cups;
  late final TextEditingController _noteController = TextEditingController(text: widget.recipe.note);
  @override
  void dispose() { _noteController.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) {
    final r = widget.recipe;
    return DraggableScrollableSheet(
      initialChildSize: .91, minChildSize: .55, maxChildSize: .96,
      builder: (context, controller) => Container(
        decoration: const BoxDecoration(color: _cream, borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
        child: ListView(controller: controller, padding: const EdgeInsets.fromLTRB(20, 12, 20, 35), children: [
          Center(child: Container(width: 42, height: 4, decoration: BoxDecoration(color: const Color(0xFFD6C8B7), borderRadius: BorderRadius.circular(5)))),
          const SizedBox(height: 20),
          Container(height: 152, decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFFF2E4D5), Color(0xFFE6EBDf)]), borderRadius: BorderRadius.circular(26)), child: Stack(alignment: Alignment.center, children: [Text(r.emoji, style: const TextStyle(fontSize: 88)), Positioned(top: 12, right: 12, child: IconButton.filled(onPressed: widget.onFavorite, style: IconButton.styleFrom(backgroundColor: Colors.white.withOpacity(.92), foregroundColor: r.favorite ? _rose : _coffee), icon: Icon(r.favorite ? Icons.favorite_rounded : Icons.favorite_border_rounded)))])),
          const SizedBox(height: 17),
          Text(r.category.toUpperCase(), style: const TextStyle(color: _sage, fontSize: 10, letterSpacing: 1.5, fontWeight: FontWeight.w800)),
          const SizedBox(height: 5),
          Text(r.title, style: const TextStyle(fontSize: 25, height: 1.35, fontWeight: FontWeight.w800, color: _ink)),
          const SizedBox(height: 7),
          Text(r.description, style: const TextStyle(color: Color(0xFF8B7B70), height: 1.8, fontSize: 12)),
          const SizedBox(height: 14),
          Row(children: [const Icon(Icons.schedule_rounded, size: 16, color: _sage), const SizedBox(width: 5), Text('${r.time} دقيقة', style: const TextStyle(fontSize: 11, color: _coffee)), const SizedBox(width: 16), const Icon(Icons.people_outline_rounded, size: 16, color: _sage), const SizedBox(width: 5), Text(r.servings, style: const TextStyle(fontSize: 11, color: _coffee))]),
          const SizedBox(height: 24),
          Row(children: [const Expanded(child: Text('المقادير', style: TextStyle(fontSize: 18, color: _ink, fontWeight: FontWeight.w800))), _UnitSwitch(cups: _cups, onChanged: (value) { setState(() => _cups = value); widget.onUnitChange(value); })]),
          const SizedBox(height: 6),
          const Text('الكوب المعياري 240 مل. الدقيق يُملأ بالملعقة ويُسوّى؛ بعض المقادير المنزلية تقريبية.', style: TextStyle(color: Color(0xFF9A8978), fontSize: 10, height: 1.7)),
          const SizedBox(height: 6),
          ...List.generate(r.ingredients.length, (i) => Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFFECE3D7)))),
            child: Row(children: [const Icon(Icons.circle, size: 6, color: _rose), const SizedBox(width: 10), Expanded(child: Text(_cups ? r.ingredients[i].cups : r.ingredients[i].metric, style: const TextStyle(fontSize: 12, height: 1.6, color: _coffee)))]),
          )),
          const SizedBox(height: 24),
          Text('الطريقة · ${r.steps.length} خطوات', style: const TextStyle(fontSize: 18, color: _ink, fontWeight: FontWeight.w800)),
          const SizedBox(height: 10),
          ...List.generate(r.steps.length, (i) => Padding(padding: const EdgeInsets.only(bottom: 12), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [Container(width: 28, height: 28, alignment: Alignment.center, decoration: const BoxDecoration(color: Color(0xFFF1E5D8), shape: BoxShape.circle), child: Text('${i + 1}', style: const TextStyle(color: _rose, fontWeight: FontWeight.w800, fontSize: 11))), const SizedBox(width: 10), Expanded(child: Text(r.steps[i], style: const TextStyle(fontSize: 12, height: 1.8, color: _coffee)))]))),
          if (r.steps.isNotEmpty) ...[
            const SizedBox(height: 4),
            FilledButton.icon(onPressed: widget.onCook, icon: const Icon(Icons.play_arrow_rounded), label: const Text('ابدئي وضع الطبخ خطوة بخطوة'), style: FilledButton.styleFrom(backgroundColor: _sage, minimumSize: const Size.fromHeight(48))),
          ],
          const SizedBox(height: 9),
          Row(children: [
            Expanded(child: OutlinedButton.icon(onPressed: widget.onTray, icon: const Icon(Icons.shopping_basket_outlined), label: const Text('أضيفي للصينية'), style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(45)))),
            const SizedBox(width: 9),
            Expanded(child: FilledButton.icon(onPressed: widget.onBaked, icon: const Icon(Icons.auto_awesome_rounded), label: const Text('خبزتها! ✦'), style: FilledButton.styleFrom(backgroundColor: _rose, minimumSize: const Size.fromHeight(45)))),
          ]),
          const SizedBox(height: 16),
          Row(children: [const Text('تقييمك:', style: TextStyle(color: _coffee)), const SizedBox(width: 8), ...List.generate(5, (i) => IconButton(onPressed: () { setState(() => r.rating = i + 1); widget.onNoteChanged(); }, visualDensity: VisualDensity.compact, icon: Icon(Icons.star_rounded, color: i < r.rating ? const Color(0xFFE0B344) : const Color(0xFFDCCDBA))))]),
          TextField(controller: _noteController, onChanged: (value) { r.note = value; widget.onNoteChanged(); }, maxLines: 2, decoration: const InputDecoration(labelText: 'ملاحظتك بعد التجربة', prefixIcon: Icon(Icons.edit_note_rounded), border: OutlineInputBorder())),
        ]),
      ),
    );
  }
}

class _UnitSwitch extends StatelessWidget {
  const _UnitSwitch({required this.cups, required this.onChanged});
  final bool cups;
  final ValueChanged<bool> onChanged;
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(color: const Color(0xFFF1E9DD), borderRadius: BorderRadius.circular(30)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          _unit('جرامات', !cups, () => onChanged(false)),
          _unit('أكواب', cups, () => onChanged(true)),
        ]),
      );
  Widget _unit(String title, bool active, VoidCallback onTap) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(30),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
          decoration: BoxDecoration(color: active ? _coffee : Colors.transparent, borderRadius: BorderRadius.circular(30)),
          child: Text(title, style: TextStyle(color: active ? Colors.white : _coffee, fontSize: 10, fontWeight: FontWeight.w700)),
        ),
      );
}

class _TraySheet extends StatefulWidget {
  const _TraySheet({required this.recipes, required this.cups, required this.checked, required this.onUnitChange, required this.onCheck, required this.onRemove, required this.onOpen, required this.onClear, required this.onCopy});
  final List<Recipe> recipes;
  final bool cups;
  final Set<String> checked;
  final ValueChanged<bool> onUnitChange;
  final void Function(String, bool) onCheck;
  final ValueChanged<Recipe> onRemove;
  final ValueChanged<Recipe> onOpen;
  final VoidCallback onClear;
  final VoidCallback onCopy;
  @override
  State<_TraySheet> createState() => _TraySheetState();
}

class _TraySheetState extends State<_TraySheet> {
  late bool _cups = widget.cups;
  late final List<Recipe> _recipes = List.of(widget.recipes);
  @override
  Widget build(BuildContext context) => DraggableScrollableSheet(
        initialChildSize: .8, minChildSize: .5, maxChildSize: .95,
        builder: (context, controller) => Container(
          decoration: const BoxDecoration(color: _cream, borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
          child: ListView(controller: controller, padding: const EdgeInsets.fromLTRB(20, 14, 20, 24), children: [
            Center(child: Container(width: 42, height: 4, decoration: BoxDecoration(color: const Color(0xFFD6C8B7), borderRadius: BorderRadius.circular(5)))),
            const SizedBox(height: 19),
            Row(children: [const Icon(Icons.shopping_basket_rounded, color: _rose), const SizedBox(width: 9), const Expanded(child: Text('صينية التجهيز', style: TextStyle(fontSize: 23, fontWeight: FontWeight.w800, color: _ink))), if (_recipes.isNotEmpty) Text('${_recipes.length} وصفة', style: const TextStyle(color: _sage, fontSize: 11))]),
            if (_recipes.isEmpty) ...[
              const SizedBox(height: 50),
              const Center(child: Text('🥐', style: TextStyle(fontSize: 64))),
              const SizedBox(height: 12),
              const Center(child: Text('صينيتك لسه فاضية', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: _ink))),
              const SizedBox(height: 7),
              const Center(child: Text('ضيفي وصفاتك المفضلة وجهزي مقاديرها هنا.', style: TextStyle(color: _sage, fontSize: 11))),
            ] else ...[
              const SizedBox(height: 15),
              Row(children: [const Expanded(child: Text('وحدات المقادير', style: TextStyle(color: _coffee, fontWeight: FontWeight.w700, fontSize: 12))), _UnitSwitch(cups: _cups, onChanged: (value) { setState(() => _cups = value); widget.onUnitChange(value); })]),
              const SizedBox(height: 4),
              const Text('الكوب المعياري 240 مل · الوصفات المضافة يدويًا تبقى كما أُدخلت.', style: TextStyle(fontSize: 10, color: _sage)),
              ..._recipes.map((r) => Card(
                    elevation: 0,
                    color: _paper,
                    margin: const EdgeInsets.only(top: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18), side: const BorderSide(color: Color(0xFFE9DDCE))),
                    child: Padding(padding: const EdgeInsets.all(13), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Row(children: [Text(r.emoji, style: const TextStyle(fontSize: 28)), const SizedBox(width: 9), Expanded(child: Text(r.title, style: const TextStyle(fontWeight: FontWeight.w800, color: _ink))), IconButton(onPressed: () { setState(() => _recipes.remove(r)); widget.onRemove(r); }, icon: const Icon(Icons.close_rounded, color: _rose))]),
                      ...List.generate(r.ingredients.length, (i) {
                        final key = '${r.id}:$i';
                        return CheckboxListTile(
                          contentPadding: EdgeInsets.zero,
                          dense: true,
                          controlAffinity: ListTileControlAffinity.leading,
                          value: widget.checked.contains(key),
                          onChanged: (value) => widget.onCheck(key, value ?? false),
                          activeColor: _sage,
                          title: Text(_cups ? r.ingredients[i].cups : r.ingredients[i].metric, style: TextStyle(fontSize: 11, color: widget.checked.contains(key) ? _sage : _coffee, decoration: widget.checked.contains(key) ? TextDecoration.lineThrough : null)),
                        );
                      }),
                      TextButton.icon(onPressed: () => widget.onOpen(r), icon: const Icon(Icons.menu_book_rounded), label: const Text('افتحي الوصفة')),
                    ])),
                  )),
              const SizedBox(height: 13),
              TextButton.icon(onPressed: widget.onCopy, icon: const Icon(Icons.copy_rounded), label: const Text('انسخي قائمة المقادير')),
              OutlinedButton.icon(onPressed: () { setState(() => _recipes.clear()); widget.onClear(); }, icon: const Icon(Icons.delete_outline_rounded), label: const Text('افرغي الصينية'), style: OutlinedButton.styleFrom(foregroundColor: _rose)),
            ],
          ]),
        ),
      );
}

class _CookDialog extends StatefulWidget {
  const _CookDialog({required this.recipe});
  final Recipe recipe;
  @override
  State<_CookDialog> createState() => _CookDialogState();
}

class _CookDialogState extends State<_CookDialog> {
  int _step = 0;
  int _remaining = 0;
  Timer? _timer;
  @override
  void dispose() { _timer?.cancel(); super.dispose(); }
  void _startTimer() {
    if (_timer != null) { _timer!.cancel(); _timer = null; setState(() {}); return; }
    _remaining = widget.recipe.id == 'cinnamon-rolls' ? 20 * 60 : widget.recipe.id == 'quick-sandwich-bread' ? 3 * 60 : math.min(widget.recipe.time, 60).toInt() * 60;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remaining <= 1) { timer.cancel(); setState(() { _timer = null; _remaining = 0; }); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تينغ! انتهى وقت الفرن 🔔'))); }
      else setState(() => _remaining--);
    });
    setState(() {});
  }
  String get _clock => '${(_remaining ~/ 60).toString().padLeft(2, '0')}:${(_remaining % 60).toString().padLeft(2, '0')}';
  @override
  Widget build(BuildContext context) {
    final last = _step == widget.recipe.steps.length - 1;
    return Dialog.fullscreen(
      backgroundColor: _paper,
      child: SafeArea(child: Padding(padding: const EdgeInsets.all(22), child: Column(children: [
        Row(children: [IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close_rounded)), const Spacer(), const Text('JURI COOKS  ·  وضع الطبخ', style: TextStyle(fontSize: 10, letterSpacing: 1, color: _sage, fontWeight: FontWeight.w800))]),
        const Spacer(),
        Text(widget.recipe.emoji, style: const TextStyle(fontSize: 60)),
        const SizedBox(height: 20),
        Text('الخطوة ${_step + 1} من ${widget.recipe.steps.length}', style: const TextStyle(color: _sage, fontWeight: FontWeight.w700)),
        const SizedBox(height: 14),
        AnimatedSwitcher(duration: const Duration(milliseconds: 300), child: Text(widget.recipe.steps[_step], key: ValueKey(_step), textAlign: TextAlign.center, style: const TextStyle(fontSize: 21, height: 1.8, color: _ink, fontWeight: FontWeight.w700))),
        const SizedBox(height: 25),
        Container(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), decoration: BoxDecoration(color: _cream, borderRadius: BorderRadius.circular(18)), child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.timer_outlined, color: _caramel), const SizedBox(width: 9), Text(_remaining > 0 ? _clock : 'مؤقّت الفرن جاهز', style: const TextStyle(fontWeight: FontWeight.w700)), const SizedBox(width: 10), TextButton(onPressed: _startTimer, child: Text(_timer == null ? 'ابدئي المؤقّت' : 'إيقاف'))])),
        const Spacer(),
        Row(children: [Expanded(child: OutlinedButton(onPressed: _step > 0 ? () => setState(() => _step--) : null, child: const Text('الخطوة السابقة'))), const SizedBox(width: 10), Expanded(child: FilledButton(onPressed: () { if (last) { Navigator.pop(context); } else { setState(() => _step++); } }, style: FilledButton.styleFrom(backgroundColor: _sage), child: Text(last ? 'خلصت، بالعافية ♡' : 'الخطوة التالية')))]),
        const SizedBox(height: 14),
      ]))),
    );
  }
}
