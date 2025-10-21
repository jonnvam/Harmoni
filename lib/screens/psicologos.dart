import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/screens/second_principal_screen.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_application_1/components/reusable_widgets.dart';
import 'package:flutter_application_1/data/psychologists_repo.dart';
import 'package:flutter_application_1/models/psychologist.dart';
import 'package:flutter_application_1/screens/psychologist_details.dart';
import 'package:flutter_application_1/screens/metas_screen.dart';
import 'package:flutter_application_1/screens/diario_screen.dart';
import 'package:flutter_application_1/screens/ia_screen.dart';

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
      setState(() {
        _items = res;
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
                left: 16, right: 16, top: 8,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Filtros', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Text('Precio máx:'),
                      const SizedBox(width: 12),
                      DropdownButton<int?>(
                        value: tempPrice,
                        items: <int?>[null, 400, 500, 600, 800]
                            .map((v) => DropdownMenuItem<int?>(
                                  value: v,
                                  child: Text(v == null ? 'Cualquiera' : '\u0024${v}'),
                                ))
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
                        items: <double?>[null, 3.5, 4.0, 4.5, 5.0]
                            .map((v) => DropdownMenuItem<double?>(
                                  value: v,
                                  child: Text(v == null ? 'Cualquiera' : '${v.toStringAsFixed(1)} ★'),
                                ))
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
                            _specialty = tempSpec.trim().isEmpty ? null : tempSpec.trim();
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
                const SizedBox(height: 10),
                const TitleSection(texto: 'Explorar Psicólogos', padding: EdgeInsets.only(top: 30, left: 24, right: 24)),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _searchCtrl,
                          decoration: InputDecoration(
                            hintText: 'Buscar por nombre o especialidad',
                            prefixIcon: const Icon(Icons.search),
                            isDense: true,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      IconButton.filledTonal(
                        onPressed: _openFilters,
                        icon: const Icon(Icons.filter_list_rounded),
                        tooltip: 'Filtros',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
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
                      Navigator.push(context, MaterialPageRoute(builder: (context) => DiarioScreen()));
                    },
                  ),
                  RadialMenuItem(
                    iconAsset: "assets/images/icon/metas.svg",
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => MetasScreen()));
                    },
                  ),

                  RadialMenuItem(
                    iconAsset: "assets/images/icon/house.svg",
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder:(context)=>SecondPrincipalScreen()));
                    },
                  ),
                  RadialMenuItem(
                    iconAsset: "assets/images/icon/ia.svg",
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => IaScreen()));
                    },
                  ),
                  RadialMenuItem(
                    iconAsset: "assets/images/icon/progreso.svg",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => MetasScreen()),
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
        crossAxisCount: 3,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 0.75,
      ),
      itemCount: _items.length,
      itemBuilder: (context, index) {
        final p = _items[index];
        return _PsychCard(
          p: p,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => PsychologistDetailsScreen(psychologist: p),
              ),
            );
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
      borderRadius: BorderRadius.circular(16),
      child: Ink(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: const Color(0xFFE2E8F0)),
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(color: Color(0x12000000), blurRadius: 8, offset: Offset(0, 3)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                        color: const Color(0xFFF1F5F9),
                      ),
                      child: Builder(
                        builder: (_) {
                          if (p.avatarUrl != null && p.avatarUrl!.isNotEmpty) {
                            return ClipRRect(
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                              child: Image.network(
                                p.avatarUrl!,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => const Icon(Icons.account_circle, size: 56, color: Colors.black26),
                              ),
                            );
                          }
                          if (p.avatarAsset != null) {
                            return Padding(
                              padding: const EdgeInsets.all(18),
                              child: _AvatarAsset(path: p.avatarAsset!),
                            );
                          }
                          return const Icon(Icons.account_circle, size: 56, color: Colors.black26);
                        },
                      ),
                    ),
                  ),
                  if (p.isTop)
                    const Positioned(
                      top: 8,
                      left: 8,
                      child: Icon(Icons.lightbulb, color: Colors.amber, size: 20),
                    ),
                  if (p.isAvailable)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(color: Colors.green.shade200),
                        ),
                        child: const Text('Disponible', style: TextStyle(fontSize: 10, color: Colors.green)),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(p.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.star_rounded, size: 16, color: Colors.amber.shade600),
                      const SizedBox(width: 2),
                      Text(p.rating.toStringAsFixed(1)),
                      const Spacer(),
                      Text('\$${p.price}', style: const TextStyle(fontWeight: FontWeight.w500)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
 
class _AvatarAsset extends StatelessWidget {
  final String path;
  const _AvatarAsset({required this.path});

  @override
  @override
  Widget build(BuildContext context) {
    if (path.toLowerCase().endsWith('.svg')) {
      return SvgPicture.asset(path, fit: BoxFit.contain);
    }
    return Image.asset(path, fit: BoxFit.contain);
  }
}
