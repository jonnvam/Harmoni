import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/screens/progreso.dart';
import 'package:flutter_application_1/screens/second_principal_screen.dart';
import 'package:flutter_application_1/components/reusable_widgets.dart';
import 'package:flutter_application_1/data/psychologists_repo.dart';
import 'package:flutter_application_1/models/psychologist.dart';
import 'package:flutter_application_1/screens/psychologist_details.dart';
import 'package:flutter_application_1/screens/metas_screen.dart';
import 'package:flutter_application_1/screens/diario_screen.dart';
import 'package:flutter_application_1/screens/ia_screen.dart';
import 'package:flutter_application_1/core/app_colors.dart';
import 'package:flutter_application_1/core/text_styles.dart';
import 'package:flutter_application_1/state/app_state.dart';

class Psicologos extends StatefulWidget {
  const Psicologos({super.key});

  @override
  State<Psicologos> createState() => _PsicologosState();
}

class _PsicologosState extends State<Psicologos> {
  final _repo = PsychologistsRepo.instance;
  final TextEditingController _searchCtrl = TextEditingController();
  Timer? _debounce;

  int? _maxPrice; // MXN
  double? _minRating; // 0..5
  String? _specialty;
  bool _onlyAvailable = false;
  bool _onlyTop = false;

  bool _loading = true;
  String? _error;
  List<Psychologist> _items = const [];

  @override
  void initState() {
    super.initState();
    _searchCtrl.addListener(_onSearchChanged);
    _fetch();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchCtrl.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), _fetch);
  }

  Future<void> _fetch() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final res = await _repo.fetchAll(
        query: _searchCtrl.text.trim().isEmpty ? null : _searchCtrl.text.trim(),
        maxPrice: _maxPrice,
        minRating: _minRating,
        specialty: _specialty,
      );
      // filtros locales por flags
      var list = res;
      if (_onlyAvailable) list = list.where((e) => e.isAvailable).toList();
      if (_onlyTop) list = list.where((e) => e.isTop).toList();
      setState(() {
        _items = list;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _openFilters() async {
    await showModalBottomSheet(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (ctx) {
        int? tempPrice = _maxPrice;
        double? tempRating = _minRating;
        String tempSpec = _specialty ?? '';
        return StatefulBuilder(
          builder: (ctx2, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
                left: 16,
                right: 16,
                top: 8,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Filtros',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Text('Precio máx:'),
                      const SizedBox(width: 12),
                      DropdownButton<int?>(
                        value: tempPrice,
                        items:
                            <int?>[null, 400, 500, 600, 800]
                                .map(
                                  (v) => DropdownMenuItem<int?>(
                                    value: v,
                                    child: Text(
                                      v == null ? 'Cualquiera' : '\u0024$v',
                                    ),
                                  ),
                                )
                                .toList(),
                        onChanged: (v) => setModalState(() => tempPrice = v),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      const Text('Rating mín:'),
                      const SizedBox(width: 12),
                      DropdownButton<double?>(
                        value: tempRating,
                        items:
                            <double?>[null, 3.5, 4.0, 4.5, 5.0]
                                .map(
                                  (v) => DropdownMenuItem<double?>(
                                    value: v,
                                    child: Text(
                                      v == null
                                          ? 'Cualquiera'
                                          : '${v.toStringAsFixed(1)} ★',
                                    ),
                                  ),
                                )
                                .toList(),
                        onChanged: (v) => setModalState(() => tempRating = v),
                      ),
                    ],
                  ),
                  TextFormField(
                    initialValue: tempSpec,
                    decoration: const InputDecoration(
                      labelText: 'Especialidad (texto)',
                    ),
                    onChanged: (v) => tempSpec = v,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(ctx);
                        },
                        child: const Text('Cancelar'),
                      ),
                      const Spacer(),
                      FilledButton(
                        onPressed: () {
                          setState(() {
                            _maxPrice = tempPrice;
                            _minRating = tempRating;
                            _specialty =
                                tempSpec.trim().isEmpty
                                    ? null
                                    : tempSpec.trim();
                          });
                          Navigator.pop(ctx);
                          _fetch();
                        },
                        child: const Text('Aplicar'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                const DropMenu(),
                const SizedBox(height: 6),
                const TitleSection(
                  texto: 'Explorar Psicólogos',
                  padding: EdgeInsets.only(top: 30, left: 24, right: 24),
                ),
                const SizedBox(height: 10),

                // Search + filtros (estilo moderno)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F6F8),
                          borderRadius: BorderRadius.circular(28),
                        ),
                        child: Row(
                          children: [
                            const SizedBox(width: 8),
                            const Icon(Icons.search, color: Colors.black54),
                            const SizedBox(width: 8),
                            Expanded(
                              child: TextField(
                                controller: _searchCtrl,
                                decoration: const InputDecoration(
                                  hintText: 'Buscar por nombre o especialidad',
                                  border: InputBorder.none,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 6,
                              ),
                              child: InkWell(
                                onTap: _openFilters,
                                borderRadius: BorderRadius.circular(999),
                                child: Ink(
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Padding(
                                    padding: EdgeInsets.all(10),
                                    child: Icon(
                                      Icons.tune_rounded,
                                      size: 20,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 14),
                      // Categorías / Especialidades
                      _CategoriesRow(
                        selected: _specialty,
                        onSelect: (value) {
                          setState(() {
                            _specialty = value == 'Todas' ? null : value;
                          });
                          _fetch();
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),
                // Encabezado de lista con "Ver todos"
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    children: [
                      Text(
                        'Psicólogos Disponibles',
                        style: TextStyles.tituloBienvenida.copyWith(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _specialty = null;
                            _minRating = null;
                            _maxPrice = null;
                            _onlyTop = false;
                            _onlyAvailable = false;
                          });
                          _fetch();
                        },
                        child: const Text('Ver todos'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _buildContent(),
                ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: SemiCircularRadialMenu(
                currentIconAsset: "assets/images/icon/psicologos.svg",
                ringColor: Colors.transparent,
                items: [
                  RadialMenuItem(
                    iconAsset: "assets/images/icon/diario.svg",
                    onTap: () {
                      if (!AppState.instance.isTestCompleted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Completa el test inicial para desbloquear esta sección.',
                            ),
                          ),
                        );
                        return;
                      }
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => DiarioScreen()),
                      );
                    },
                  ),
                  RadialMenuItem(
                    iconAsset: "assets/images/icon/metas.svg",
                    onTap: () {
                      if (!AppState.instance.isTestCompleted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Completa el test inicial para desbloquear esta sección.',
                            ),
                          ),
                        );
                        return;
                      }
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => MetasScreen()),
                      );
                    },
                  ),

                  RadialMenuItem(
                    iconAsset: "assets/images/icon/house.svg",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SecondPrincipalScreen(),
                        ),
                      );
                    },
                  ),
                  RadialMenuItem(
                    iconAsset: "assets/images/icon/ia.svg",
                    onTap: () {
                      if (!AppState.instance.isTestCompleted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Completa el test inicial para desbloquear esta sección.',
                            ),
                          ),
                        );
                        return;
                      }
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => IaScreen()),
                      );
                    },
                  ),
                  RadialMenuItem(
                    iconAsset: "assets/images/icon/progreso.svg",
                    onTap: () {
                      if (!AppState.instance.isTestCompleted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Completa el test inicial para desbloquear esta sección.',
                            ),
                          ),
                        );
                        return;
                      }
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => Progreso()),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_loading) {
      return const Padding(
        padding: EdgeInsets.all(40),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (_error != null) {
      return Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          children: [
            const Icon(Icons.error_outline, color: Colors.redAccent, size: 40),
            const SizedBox(height: 8),
            Text(_error!, style: const TextStyle(color: Colors.redAccent)),
            const SizedBox(height: 8),
            OutlinedButton(onPressed: _fetch, child: const Text('Reintentar')),
          ],
        ),
      );
    }
    if (_items.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          children: const [
            Icon(Icons.person_search_rounded, size: 44, color: Colors.black26),
            SizedBox(height: 8),
            Text('No se encontraron resultados'),
          ],
        ),
      );
    }
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 14,
        crossAxisSpacing: 14,
        childAspectRatio: 0.70,
      ),
      itemCount: _items.length,
      itemBuilder: (context, index) {
        final p = _items[index];
        return _PsychCard(
          p: p,
          onTap: () {
            _openPreview(context, p);
          },
        );
      },
    );
  }
}

class _PsychCard extends StatelessWidget {
  final Psychologist p;
  final VoidCallback onTap;
  const _PsychCard({required this.p, required this.onTap});

  @override
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Ink(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFEAECEE)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0D000000),
              blurRadius: 8,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 14, 12, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Avatar redondo grande
              CircleAvatar(
                radius: 36,
                backgroundImage:
                    (p.avatarUrl != null && p.avatarUrl!.isNotEmpty)
                        ? NetworkImage(p.avatarUrl!)
                        : (p.avatarAsset != null && p.avatarAsset!.isNotEmpty)
                        ? AssetImage(p.avatarAsset!) as ImageProvider
                        : null,
                child:
                    (p.avatarUrl == null &&
                            (p.avatarAsset == null || p.avatarAsset!.isEmpty))
                        ? const Icon(Icons.person, size: 36)
                        : null,
              ),
              const SizedBox(height: 10),
              Text(
                p.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                p.specialties.take(2).join(' • '),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.black54, fontSize: 12),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.star_rounded,
                    size: 16,
                    color: Color(0xFFF59E0B),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    p.rating.toStringAsFixed(1),
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 4,
                    height: 4,
                    decoration: const BoxDecoration(
                      color: Color(0xFFCBD5E1),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '\$${p.price}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.fondo3,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                  onPressed: onTap,
                  child: const Text('Ver Perfil'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoriesRow extends StatelessWidget {
  final String? selected;
  final ValueChanged<String> onSelect;
  const _CategoriesRow({required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    final categories = <({IconData icon, String label, Color color})>[
      (
        icon: Icons.psychology_alt,
        label: 'Todas',
        color: const Color(0xFFE8EAF6),
      ),
      (
        icon: Icons.lightbulb_outline,
        label: 'Terapia Cognitivo-Conductual',
        color: const Color(0xFFE6F7F2),
      ),
      (
        icon: Icons.child_care,
        label: 'Psicología Infantil',
        color: const Color(0xFFFFF3E6),
      ),
      (
        icon: Icons.favorite_outline,
        label: 'Terapia de Pareja',
        color: const Color(0xFFF3E8FF),
      ),
    ];
    final scaler = MediaQuery.textScalerOf(context);
    final factor = scaler.scale(1.0);
    final extra =
        ((factor - 1.0).clamp(0.0, 1.0)) *
        44.0; // add up to 44px when scale up to 2.0
    final rowHeight = 92.0 + extra;
    return SizedBox(
      height: rowHeight,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.only(left: 4, right: 4),
        itemBuilder: (ctx, i) {
          final item = categories[i];
          final isSel =
              selected == null ? item.label == 'Todas' : selected == item.label;
          return _CategoryPill(
            icon: item.icon,
            label: item.label,
            color: item.color,
            selected: isSel,
            onTap: () => onSelect(item.label),
          );
        },
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemCount: categories.length,
      ),
    );
  }
}

class _CategoryPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final bool selected;
  final VoidCallback onTap;
  const _CategoryPill({
    required this.icon,
    required this.label,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bg = selected ? AppColors.fondo3.withValues(alpha: 0.12) : color;
    final fg = selected ? AppColors.fondo3 : Colors.black87;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Ink(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: Colors.white,
              child: Icon(icon, size: 18, color: fg),
            ),
            const SizedBox(height: 6),
            SizedBox(
              width: 110,
              child: Text(
                label,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11,
                  height: 1.2,
                  fontWeight: FontWeight.w600,
                  color: fg,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Eliminado: _AvatarAsset ya no se utiliza tras el rediseño de las tarjetas.

void _openPreview(BuildContext context, Psychologist p) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (ctx) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(ctx),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundImage:
                        (p.avatarUrl != null && p.avatarUrl!.isNotEmpty)
                            ? NetworkImage(p.avatarUrl!)
                            : (p.avatarAsset != null &&
                                p.avatarAsset!.isNotEmpty)
                            ? AssetImage(p.avatarAsset!) as ImageProvider
                            : null,
                    child:
                        (p.avatarUrl == null &&
                                (p.avatarAsset == null ||
                                    p.avatarAsset!.isEmpty))
                            ? const Icon(Icons.person, size: 40)
                            : null,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          p.name,
                          style: TextStyles.tituloBienvenida.copyWith(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            ...List.generate(5, (i) {
                              final full = p.rating.floor();
                              final half = (p.rating - full) >= 0.5;
                              if (i < full)
                                return const Icon(
                                  Icons.star,
                                  color: Colors.amber,
                                  size: 18,
                                );
                              if (i == full && half)
                                return const Icon(
                                  Icons.star_half,
                                  color: Colors.amber,
                                  size: 18,
                                );
                              return const Icon(
                                Icons.star_border,
                                color: Colors.amber,
                                size: 18,
                              );
                            }),
                            const SizedBox(width: 6),
                            Text(
                              '${p.rating.toStringAsFixed(1)} (2,100 reseñas)',
                              style: TextStyles.textDicho.copyWith(
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          p.specialties.join(' • '),
                          style: TextStyles.textDicho.copyWith(fontSize: 13),
                        ),
                        const SizedBox(height: 8),
                        if (p.isAvailable)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green.shade50,
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(color: Colors.green.shade200),
                            ),
                            child: const Text(
                              'Disponible Hoy',
                              style: TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x0F000000),
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const CircleAvatar(
                      radius: 16,
                      child: Icon(Icons.person, size: 16),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        '“Excelente profesional, muy empático y con herramientas claras. Me ayudó mucho a manejar el estrés.”',
                        style: TextStyles.textDicho.copyWith(fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.fondo3,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(ctx);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (_) => PsychologistDetailsScreen(psychologist: p),
                      ),
                    );
                  },
                  icon: const Icon(Icons.arrow_forward_rounded),
                  label: const Text('Visitar Perfil'),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
