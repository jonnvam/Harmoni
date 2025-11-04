import 'package:flutter/material.dart';
import 'package:flutter_application_1/components/reusable_widgets.dart';
import 'package:flutter_application_1/core/text_styles.dart';
import 'package:flutter_application_1/screens/diario_screen.dart';
import 'package:flutter_application_1/screens/ia_screen.dart';
import 'package:flutter_application_1/screens/metas_screen.dart';
import 'package:flutter_application_1/screens/second_principal_screen.dart';
import 'package:flutter_application_1/screens/psicologos.dart';
import 'package:flutter_application_1/data/emergency_contacts_repo.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_application_1/state/app_state.dart';

class EmergenciaScreen extends StatefulWidget {
  const EmergenciaScreen({super.key});

  @override
  State<EmergenciaScreen> createState() => _EmergenciaScreenState();
}

class _EmergenciaScreenState extends State<EmergenciaScreen> {
  List<EmergencyContact> _contacts = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final list = await EmergencyContactsRepo.instance.list();
    if (!mounted) return;
    setState(() => _contacts = list);
  }

  Future<void> _addOrEdit({EmergencyContact? existing}) async {
    final nameCtrl = TextEditingController(text: existing?.name ?? '');
    final phoneCtrl = TextEditingController(text: existing?.phone ?? '');
    final relationCtrl = TextEditingController(text: existing?.relation ?? '');

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(existing == null ? 'Nuevo contacto' : 'Editar contacto',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              const SizedBox(height: 10),
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(
                  labelText: 'Nombre',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: phoneCtrl,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Teléfono',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: relationCtrl,
                decoration: const InputDecoration(
                  labelText: 'Relación (opcional)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 14),
              Align(
                alignment: Alignment.centerRight,
                child: FilledButton(
                  onPressed: () async {
                    final name = nameCtrl.text.trim();
                    final phone = phoneCtrl.text.trim();
                    final relation = relationCtrl.text.trim().isEmpty ? null : relationCtrl.text.trim();
                    if (name.isEmpty || phone.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Nombre y teléfono son obligatorios.')),
                      );
                      return;
                    }
                    final contact = EmergencyContact(
                      id: existing?.id ?? EmergencyContactsRepo.nextId(),
                      name: name,
                      phone: phone,
                      relation: relation,
                    );
                    await EmergencyContactsRepo.instance.upsert(contact);
                    if (!mounted) return;
                    Navigator.of(ctx).pop();
                    await _load();
                  },
                  child: const Text('Guardar'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _delete(EmergencyContact c) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Eliminar contacto'),
          content: Text('¿Eliminar a ${c.name}?'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
            FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Eliminar')),
          ],
        );
      },
    );
    if (ok == true) {
      await EmergencyContactsRepo.instance.delete(c.id);
      await _load();
    }
  }

  Future<void> _call(String phone) async {
    final uri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo iniciar la llamada.')),
      );
    }
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
                DropMenu(),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),

                  child: Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: ContainerC1(
                      width: 334,
                      height: 511,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 20),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              "¿Te sientes en crisis o en peligro?",
                              style: TextStyles.textBlackLogin,
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              'Tu bienestar es lo más importante. No estás solo.',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                                fontFamily: 'Kantumruy Pro',
                                fontWeight: FontWeight.w300,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Row(
                              children: [
                                const Expanded(
                                  child: Text(
                                    "Contactos de Emergencia",
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 18,
                                      fontFamily: 'Mandali',
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                FilledButton.icon(
                                  onPressed: () => _addOrEdit(),
                                  icon: const Icon(Icons.add),
                                  label: const Text('Agregar'),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Expanded(
                            child: _contacts.isEmpty
                                ? const Center(
                                    child: Text('Aún no has agregado contactos.'),
                                  )
                                : ListView.separated(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                    itemCount: _contacts.length,
                                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                                    itemBuilder: (_, i) {
                                      final c = _contacts[i];
                                      return Container(
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(color: const Color(0xFFE2E8F0)),
                                        ),
                                        child: ListTile(
                                          title: Text(c.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                                          subtitle: Text(
                                            [c.phone, if (c.relation != null) ' • ${c.relation}'].join(''),
                                          ),
                                          leading: const Icon(Icons.contact_phone),
                                          trailing: Wrap(
                                            spacing: 8,
                                            children: [
                                              IconButton(
                                                tooltip: 'Llamar',
                                                icon: const Icon(Icons.call, color: Colors.green),
                                                onPressed: () => _call(c.phone),
                                              ),
                                              IconButton(
                                                tooltip: 'Editar',
                                                icon: const Icon(Icons.edit, color: Colors.blueGrey),
                                                onPressed: () => _addOrEdit(existing: c),
                                              ),
                                              IconButton(
                                                tooltip: 'Eliminar',
                                                icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                                                onPressed: () => _delete(c),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: SemiCircularRadialMenu(
                currentIconAsset: "assets/images/icon/house.svg",
                ringColor: Colors.transparent,
                onCenterDoubleTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SecondPrincipalScreen(),
                    ),
                  );
                },
                items: [
                  RadialMenuItem(
                    iconAsset: "assets/images/icon/psicologos.svg",
                    onTap: () {
                      if (!AppState.instance.isTestCompleted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Completa el test inicial para desbloquear esta sección.')),
                        );
                        return;
                      }
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const Psicologos()),
                      );
                    },
                  ),
                  RadialMenuItem(
                    iconAsset: "assets/images/icon/diario.svg",
                    onTap: () {
                      if (!AppState.instance.isTestCompleted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Completa el test inicial para desbloquear esta sección.')),
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
                          const SnackBar(content: Text('Completa el test inicial para desbloquear esta sección.')),
                        );
                        return;
                      }
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => MetasScreen()),
                      );
                    },
                  ),

                  // Home (center of ring)
                  RadialMenuItem(
                    iconAsset: "assets/images/icon/progreso.svg",
                    onTap: () {
                      if (!AppState.instance.isTestCompleted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Completa el test inicial para desbloquear esta sección.')),
                        );
                        return;
                      }
                    },
                  ),
                  RadialMenuItem(
                    iconAsset: "assets/images/icon/ia.svg",
                    onTap: () {
                      if (!AppState.instance.isTestCompleted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Completa el test inicial para desbloquear esta sección.')),
                        );
                        return;
                      }
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => IaScreen()),
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
}
