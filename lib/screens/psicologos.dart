import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/screens/progreso.dart';
import 'package:flutter_application_1/screens/second_principal_screen.dart';
import 'package:flutter_application_1/components/reusable_widgets.dart';
import 'package:flutter_application_1/services/public_psychologists_service.dart';
import 'package:flutter_application_1/models/psychologist.dart';
import 'package:flutter_application_1/screens/psychologist_details.dart';
import 'package:flutter_application_1/screens/metas_screen.dart';
import 'package:flutter_application_1/screens/diario_screen.dart';
import 'package:flutter_application_1/screens/ia_screen.dart';
import 'package:flutter_application_1/core/app_colors.dart';
import 'package:flutter_application_1/core/text_styles.dart';
import 'package:flutter_application_1/state/app_state.dart';
import 'package:flutter_application_1/screens/mis_citas_screen.dart';

class Psicologos extends StatefulWidget {
  const Psicologos({super.key});

  @override
  State<Psicologos> createState() => _PsicologosState();
}

class _PsicologosState extends State<Psicologos> {
  final _repo = PublicPsychologistsService.instance;
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

                const SizedBox(height: 14),
                const _MyAppointmentsShortcut(),
                const SizedBox(height: 16),

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
        childAspectRatio: 0.62,
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

  String get _specialtiesText {
    if (p.specialties.isEmpty) return 'Psicología';
    return p.specialties.take(2).join(' • ');
  }

  String get _modalidadesText {
    if (p.modalidades.isEmpty) return 'Modalidad no especificada';
    return p.modalidades.take(2).join(' • ');
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Ink(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: const Color(0xFFEAECEE)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0D000000),
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 31,
                  backgroundColor: const Color(0xFFF2EEFF),
                  backgroundImage:
                      (p.avatarUrl != null && p.avatarUrl!.isNotEmpty)
                          ? NetworkImage(p.avatarUrl!)
                          : (p.avatarAsset != null && p.avatarAsset!.isNotEmpty)
                          ? AssetImage(p.avatarAsset!) as ImageProvider
                          : null,
                  child:
                      (p.avatarUrl == null &&
                              (p.avatarAsset == null || p.avatarAsset!.isEmpty))
                          ? const Icon(
                            Icons.person_rounded,
                            size: 32,
                            color: AppColors.fondo3,
                          )
                          : null,
                ),

                const SizedBox(height: 9),

                Text(
                  p.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'Kantumruy Pro',
                    fontWeight: FontWeight.w800,
                    fontSize: 14.5,
                    height: 1.05,
                    color: Colors.black87,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  _specialtiesText,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'Kantumruy Pro',
                    color: Colors.black54,
                    fontSize: 12,
                  ),
                ),

                const SizedBox(height: 7),

                Container(
                  constraints: const BoxConstraints(maxWidth: 140),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8F8FD),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Text(
                    _modalidadesText,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: 'Kantumruy Pro',
                      fontSize: 11,
                      color: Colors.black54,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),

                const Spacer(),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      child: Text(
                        '\$${p.price} ${p.moneda}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: 'Kantumruy Pro',
                          fontWeight: FontWeight.w800,
                          fontSize: 11,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                SizedBox(
                  width: double.infinity,
                  height: 40,
                  child: ElevatedButton(
                    onPressed: onTap,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.fondo3,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      'Ver perfil',
                      style: TextStyle(
                        fontFamily: 'Kantumruy Pro',
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ],
            ),
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

class _ProfileInfoSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;

  const _ProfileInfoSection({
    required this.title,
    required this.icon,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: AppColors.fondo3),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  fontFamily: 'Kantumruy Pro',
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}

class _ProfileChipWrap extends StatelessWidget {
  final List<String> items;

  const _ProfileChipWrap({required this.items});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const Text(
        'No especificado',
        style: TextStyle(
          fontSize: 13,
          color: Colors.black54,
          fontFamily: 'Kantumruy Pro',
        ),
      );
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children:
          items.map((item) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
              decoration: BoxDecoration(
                color: const Color(0xFFEEF2FF),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: const Color(0xFFDCE4FF)),
              ),
              child: Text(
                item,
                style: const TextStyle(
                  fontSize: 12,
                  fontFamily: 'Kantumruy Pro',
                  fontWeight: FontWeight.w700,
                  color: AppColors.fondo3,
                ),
              ),
            );
          }).toList(),
    );
  }
}

class _PriceBadge extends StatelessWidget {
  final Psychologist p;

  const _PriceBadge({required this.p});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFEEF2FF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFDCE4FF)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.payments_rounded, color: AppColors.fondo3, size: 18),
          const SizedBox(width: 8),
          Text(
            '\$${p.price} ${p.moneda} / sesión',
            style: const TextStyle(
              fontFamily: 'Kantumruy Pro',
              fontWeight: FontWeight.w800,
              color: AppColors.fondo3,
            ),
          ),
        ],
      ),
    );
  }
}

void _openPreview(BuildContext context, Psychologist p) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (ctx) {
      return DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.88,
        minChildSize: 0.55,
        maxChildSize: 0.95,
        builder: (_, scrollController) {
          return SingleChildScrollView(
            controller: scrollController,
            padding: const EdgeInsets.fromLTRB(22, 12, 22, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 42,
                    height: 5,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE5E7EB),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),

                const SizedBox(height: 10),

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
                      radius: 42,
                      backgroundColor: const Color(0xFFF2EEFF),
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
                              ? const Icon(
                                Icons.person_rounded,
                                size: 42,
                                color: AppColors.fondo3,
                              )
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
                              height: 1.1,
                            ),
                          ),

                          const SizedBox(height: 8),

                          Text(
                            p.specialties.isEmpty
                                ? 'Psicología'
                                : p.specialties.join(' • '),
                            style: TextStyles.textDicho.copyWith(fontSize: 13),
                          ),

                          const SizedBox(height: 8),

                          _PriceBadge(p: p),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                _ProfileInfoSection(
                  title: 'Descripción profesional',
                  icon: Icons.description_rounded,
                  child: Text(
                    p.descripcionProfesional.trim().isEmpty
                        ? 'Este psicólogo aún no agregó una descripción profesional.'
                        : p.descripcionProfesional,
                    style: const TextStyle(
                      fontSize: 14,
                      height: 1.4,
                      color: Colors.black87,
                      fontFamily: 'Kantumruy Pro',
                    ),
                  ),
                ),

                _ProfileInfoSection(
                  title: 'Especialidades',
                  icon: Icons.psychology_rounded,
                  child: _ProfileChipWrap(items: p.specialties),
                ),

                _ProfileInfoSection(
                  title: 'Modalidades',
                  icon: Icons.video_call_rounded,
                  child: _ProfileChipWrap(items: p.modalidades),
                ),

                _ProfileInfoSection(
                  title: 'Enfoque terapéutico',
                  icon: Icons.lightbulb_rounded,
                  child: _ProfileChipWrap(items: p.enfoquesTerapia),
                ),

                _ProfileInfoSection(
                  title: 'Población que atiende',
                  icon: Icons.groups_rounded,
                  child: _ProfileChipWrap(items: p.atiendeA),
                ),

                if (p.aniosExperiencia != null)
                  _ProfileInfoSection(
                    title: 'Experiencia',
                    icon: Icons.workspace_premium_rounded,
                    child: Text(
                      p.aniosExperiencia == 1
                          ? '1 año de experiencia'
                          : '${p.aniosExperiencia} años de experiencia',
                      style: const TextStyle(
                        fontSize: 14,
                        fontFamily: 'Kantumruy Pro',
                        color: Colors.black87,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                const SizedBox(height: 8),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.fondo3,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
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
                    label: const Text(
                      'Visitar perfil completo',
                      style: TextStyle(
                        fontFamily: 'Kantumruy Pro',
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      );
    },
  );
}

class _MyAppointmentsShortcut extends StatelessWidget {
  const _MyAppointmentsShortcut();

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const MisCitasScreen()),
        );
      },
      child: Ink(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0A000000),
              blurRadius: 8,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: const BoxDecoration(
                color: Color(0xFFEEF2FF),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.calendar_month_rounded,
                color: AppColors.fondo3,
              ),
            ),

            const SizedBox(width: 12),

            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Mis citas',
                    style: TextStyle(
                      fontFamily: 'Kantumruy Pro',
                      fontWeight: FontWeight.w900,
                      fontSize: 15,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 3),
                  Text(
                    'Consulta el estado de tus solicitudes.',
                    style: TextStyle(
                      fontFamily: 'Kantumruy Pro',
                      fontSize: 12,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),

            const Icon(Icons.chevron_right_rounded, color: Colors.black38),
          ],
        ),
      ),
    );
  }
}
