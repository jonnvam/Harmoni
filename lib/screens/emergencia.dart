import 'dart:io' show Platform;
import 'package:permission_handler/permission_handler.dart' as ph;
import 'package:android_intent_plus/android_intent.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/components/reusable_widgets.dart';
import 'package:flutter_application_1/core/text_styles.dart';
import 'package:flutter_application_1/screens/diario_screen.dart';
import 'package:flutter_application_1/screens/ia_screen.dart';
import 'package:flutter_application_1/screens/metas_screen.dart';
import 'package:flutter_application_1/screens/psicologos.dart';
import 'package:flutter_application_1/utils/navigation_helper.dart';
import 'package:flutter_application_1/services/emergency_contacts_service.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_application_1/state/app_state.dart';
import 'package:flutter_application_1/core/app_colors.dart';
import 'package:flutter/services.dart';
import 'package:flutter_contacts/flutter_contacts.dart';

class EmergenciaScreen extends StatefulWidget {
  const EmergenciaScreen({super.key});

  @override
  State<EmergenciaScreen> createState() => _EmergenciaScreenState();
}

class _EmergenciaScreenState extends State<EmergenciaScreen> {
  Future<void> _addOrEdit({EmergencyContactModel? existing}) async {
    final nameCtrl = TextEditingController(text: existing?.name ?? '');
    final phoneCtrl = TextEditingController(
      text: existing == null ? '' : _formatMexicanPhone(existing.phone),
    );
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
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  existing == null ? 'Nuevo contacto' : 'Editar contacto',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
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
                  inputFormatters: [MexicanPhoneInputFormatter()],
                  decoration: const InputDecoration(
                    labelText: 'Teléfono',
                    hintText: '771 123 4567',
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
                      final phone = phoneCtrl.text.replaceAll(
                        RegExp(r'\D'),
                        '',
                      );
                      final relation =
                          relationCtrl.text.trim().isEmpty
                              ? null
                              : relationCtrl.text.trim();

                      if (name.isEmpty || phone.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Nombre y teléfono son obligatorios.',
                            ),
                          ),
                        );
                        return;
                      }

                      try {
                        if (existing == null) {
                          await EmergencyContactsService.instance.addContact(
                            name: name,
                            phone: phone,
                            relation: relation,
                          );
                        } else {
                          await EmergencyContactsService.instance.updateContact(
                            contactId: existing.id,
                            name: name,
                            phone: phone,
                            relation: relation,
                          );
                        }

                        if (!context.mounted) return;

                        Navigator.of(ctx).pop();

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              existing == null
                                  ? 'Contacto agregado.'
                                  : 'Contacto actualizado.',
                            ),
                          ),
                        );
                      } catch (e) {
                        if (!context.mounted) return;

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('No se pudo guardar: $e')),
                        );
                      }
                    },
                    child: const Text('Guardar'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    // No hacemos dispose manual aquí.
    // En este caso evitamos el error de controller usado después de dispose.
  }

  String _contactName(Contact contact) {
    final name = contact.displayName?.trim();

    if (name == null || name.isEmpty) {
      return 'Sin nombre';
    }

    return name;
  }

  String _normalizeMexicanPhoneFromContact(String phone) {
    var digits = phone.replaceAll(RegExp(r'\D'), '');

    // Formatos comunes:
    // +52 7711234567  -> 527711234567
    // +52 1 7711234567 -> 5217711234567
    if (digits.length == 12 && digits.startsWith('52')) {
      digits = digits.substring(2);
    }

    if (digits.length == 13 && digits.startsWith('521')) {
      digits = digits.substring(3);
    }

    // Si viene con prefijos raros, tomamos los últimos 10 dígitos.
    // Ejemplo: 0447711234567 -> 7711234567
    if (digits.length > 10) {
      digits = digits.substring(digits.length - 10);
    }

    return digits;
  }

  String _formatMexicanPhone(String phone) {
    final digits = phone.replaceAll(RegExp(r'\D'), '');

    if (digits.length != 10) return phone;

    return '${digits.substring(0, 3)} ${digits.substring(3, 6)} ${digits.substring(6)}';
  }

  Future<void> _delete(EmergencyContactModel c) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Eliminar contacto'),
          content: Text('¿Eliminar a ${c.name}?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );

    if (ok == true) {
      try {
        await EmergencyContactsService.instance.deleteContact(c.id);

        if (!mounted) return;

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Contacto eliminado.')));
      } catch (e) {
        if (!mounted) return;

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('No se pudo eliminar: $e')));
      }
    }
  }

  Future<void> _showAddContactOptions() async {
    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Agregar contacto de emergencia',
                  style: TextStyle(
                    fontSize: 20,
                    fontFamily: 'Kantumruy Pro',
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Puedes elegir un contacto guardado o ingresarlo manualmente.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    fontFamily: 'Kantumruy Pro',
                    fontWeight: FontWeight.w300,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 18),

                _EmergencyOptionTile(
                  icon: Icons.contacts_rounded,
                  title: 'Seleccionar de mis contactos',
                  subtitle: 'Elegir desde el directorio del teléfono',
                  onTap: () async {
                    Navigator.of(ctx).pop();
                    await Future.delayed(const Duration(milliseconds: 120));

                    if (!mounted) return;
                    await _pickFromDeviceContacts();
                  },
                ),

                const SizedBox(height: 10),

                _EmergencyOptionTile(
                  icon: Icons.edit_note_rounded,
                  title: 'Ingresar manualmente',
                  subtitle: 'Escribir nombre y teléfono',
                  onTap: () async {
                    Navigator.of(ctx).pop();
                    await Future.delayed(const Duration(milliseconds: 120));

                    if (!mounted) return;
                    await _addOrEdit();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _pickFromDeviceContacts() async {
    // 1. En v2.0.0 requestPermission() devuelve un bool directamente
    final bool isGranted = await FlutterContacts.requestPermission();

    debugPrint('CONTACTS PERMISSION STATUS: $isGranted');

    // Usamos 'isGranted' que es la variable definida arriba
    if (!isGranted) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'No se otorgó acceso a contactos. Puedes agregarlo manualmente.',
          ),
        ),
      );
      return;
    }

    try {
      // 2. 'getAll' cambió a 'getContacts' en la nueva versión
      // 'withProperties: true' trae teléfonos, nombres, etc.
      final contacts = await FlutterContacts.getContacts(
        withProperties: true,
      );

      final contactsWithPhones =
          contacts.where((contact) => contact.phones.isNotEmpty).toList();

      if (!mounted) return;

      if (contactsWithPhones.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No encontramos contactos con número telefónico.'),
          ),
        );
        return;
      }

      await _showDeviceContactsPicker(contactsWithPhones);
    } catch (e) {
      if (!mounted) return;
      debugPrint('Error en contactos: $e');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudieron cargar tus contactos: $e')),
      );
    }
  }

  Future<void> _showDeviceContactsPicker(List<Contact> contacts) async {
    final searchCtrl = TextEditingController();
    List<Contact> filtered = List.of(contacts);

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return SafeArea(
              child: Padding(
                padding: EdgeInsets.only(
                  left: 16,
                  right: 16,
                  top: 16,
                  bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
                ),
                child: SizedBox(
                  height: MediaQuery.of(ctx).size.height * 0.75,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Selecciona un contacto',
                        style: TextStyle(
                          fontSize: 20,
                          fontFamily: 'Kantumruy Pro',
                          fontWeight: FontWeight.w700,
                        ),
                      ),

                      const SizedBox(height: 12),

                      TextField(
                        controller: searchCtrl,
                        decoration: InputDecoration(
                          hintText: 'Buscar contacto...',
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        onChanged: (value) {
                          final query = value.trim().toLowerCase();

                          setModalState(() {
                            filtered =
                                contacts.where((contact) {
                                  final name =
                                      _contactName(contact).toLowerCase();
                                  final phones = contact.phones
                                      .map((p) => p.number.toLowerCase())
                                      .join(' ');

                                  return name.contains(query) ||
                                      phones.contains(query);
                                }).toList();
                          });
                        },
                      ),

                      const SizedBox(height: 12),

                      Expanded(
                        child:
                            filtered.isEmpty
                                ? const Center(
                                  child: Text('No encontramos coincidencias.'),
                                )
                                : ListView.separated(
                                  itemCount: filtered.length,
                                  separatorBuilder:
                                      (_, __) => const SizedBox(height: 8),
                                  itemBuilder: (_, index) {
                                    final contact = filtered[index];

                                    final firstPhone =
                                        contact.phones.isNotEmpty
                                            ? contact.phones.first.number
                                            : '';

                                    return InkWell(
                                      borderRadius: BorderRadius.circular(16),
                                      onTap: () async {
                                        Navigator.of(ctx).pop();
                                        await Future.delayed(
                                          const Duration(milliseconds: 120),
                                        );

                                        if (!mounted) return;
                                        await _handleSelectedDeviceContact(
                                          contact,
                                        );
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 12,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                          border: Border.all(
                                            color: const Color(0xFFE2E8F0),
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            Container(
                                              width: 42,
                                              height: 42,
                                              decoration: const BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: Color(0xFFF2EEFF),
                                              ),
                                              child: const Icon(
                                                Icons.person_rounded,
                                                color: AppColors.primary,
                                              ),
                                            ),

                                            const SizedBox(width: 12),

                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    _contactName(contact),
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: const TextStyle(
                                                      fontFamily:
                                                          'Kantumruy Pro',
                                                      fontWeight:
                                                          FontWeight.w700,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 3),
                                                  Text(
                                                    firstPhone,
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: const TextStyle(
                                                      fontFamily:
                                                          'Kantumruy Pro',
                                                      color: Colors.black54,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),

                                            const Icon(
                                              Icons.chevron_right_rounded,
                                              color: Colors.black38,
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
            );
          },
        );
      },
    );

    searchCtrl.dispose();
  }

  Future<void> _handleSelectedDeviceContact(Contact contact) async {
    if (contact.phones.isEmpty) return;

    if (contact.phones.length == 1) {
      final phone = contact.phones.first.number;

      await _saveImportedContact(name: _contactName(contact), phone: phone);

      return;
    }

    await _showPhoneNumberPickerForContact(contact);
  }

  Future<void> _showPhoneNumberPickerForContact(Contact contact) async {
    await showDialog(
      context: context,
      builder: (ctx) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 24),
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(26),
              border: Border.all(color: const Color(0xFFE2E8F0)),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x1A000000),
                  blurRadius: 18,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _contactName(contact),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: 'Kantumruy Pro',
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 14),

                ...contact.phones.map((phone) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () async {
                        Navigator.of(ctx).pop();
                        await Future.delayed(const Duration(milliseconds: 120));

                        if (!mounted) return;
                        await _saveImportedContact(
                          name: _contactName(contact),
                          phone: phone.number,
                        );
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 13,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.call_rounded,
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                phone.number,
                                style: const TextStyle(
                                  fontFamily: 'Kantumruy Pro',
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),

                const SizedBox(height: 8),

                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text('Cancelar'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _saveImportedContact({
    required String name,
    required String phone,
  }) async {
    final cleanPhone = _normalizeMexicanPhoneFromContact(phone);

    if (cleanPhone.length != 10) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'El número de $name no parece tener 10 dígitos válidos.',
          ),
        ),
      );
      return;
    }

    try {
      await EmergencyContactsService.instance.addContact(
        name: name.trim().isEmpty ? 'Contacto' : name.trim(),
        phone: cleanPhone,
        relation: null,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Contacto agregado desde tu directorio.')),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo guardar el contacto: $e')),
      );
    }
  }

  Future<void> _call(String phone) async {
  final dialPhone = EmergencyContactsService.instance.phoneForDialer(phone);

  if (dialPhone.isEmpty || dialPhone.length != 10) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Número inválido.')),
    );
    return;
  }

  try {
    if (Platform.isAndroid) {
      final status = await ph.Permission.phone.request();

      if (!mounted) return;

      if (!status.isGranted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Permiso de llamada denegado. Actívalo para llamar directamente.',
            ),
          ),
        );
        return;
      }

      final intent = AndroidIntent(
        action: 'android.intent.action.CALL',
        data: 'tel:$dialPhone',
      );

      await intent.launch();
      return;
    }

    // Fallback para iOS u otras plataformas.
    final uri = Uri(scheme: 'tel', path: dialPhone);

    final launched = await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );

    if (!launched && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo abrir la app de teléfono.')),
      );
    }
  } catch (e) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('No se pudo realizar la llamada: $e')),
    );
  }
}

  Future<void> _showContactDetails(EmergencyContactModel c) async {
    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 24),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: const Color(0xFFEAEAF4)),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x14000000),
                  blurRadius: 18,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 74,
                  height: 74,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEEEAFE),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.contact_phone_rounded,
                    size: 34,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 16),

                Text(
                  c.name,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 22,
                    fontFamily: 'Kantumruy Pro',
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 6),

                Text(
                  _formatMexicanPhone(c.phone),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    fontFamily: 'Kantumruy Pro',
                    fontWeight: FontWeight.w400,
                    color: Colors.black54,
                  ),
                ),

                if (c.relation != null && c.relation!.trim().isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF6F3FF),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(
                      c.relation!,
                      style: const TextStyle(
                        fontSize: 13,
                        fontFamily: 'Kantumruy Pro',
                        fontWeight: FontWeight.w500,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 22),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(ctx).pop();
                      _call(c.phone);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    icon: const Icon(Icons.call_rounded),
                    label: const Text(
                      'Llamar',
                      style: TextStyle(
                        fontFamily: 'Kantumruy Pro',
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.of(ctx).pop();
                          _addOrEdit(existing: c);
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          side: const BorderSide(color: Color(0xFFD8D4F5)),
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        icon: const Icon(Icons.edit_outlined),
                        label: const Text(
                          'Editar',
                          style: TextStyle(
                            fontFamily: 'Kantumruy Pro',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.of(ctx).pop();
                          _delete(c);
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.redAccent,
                          side: const BorderSide(color: Color(0xFFF2CACA)),
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        icon: const Icon(Icons.delete_outline),
                        label: const Text(
                          'Eliminar',
                          style: TextStyle(
                            fontFamily: 'Kantumruy Pro',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  style: TextButton.styleFrom(foregroundColor: Colors.black54),
                  child: const Text(
                    'Cerrar',
                    style: TextStyle(
                      fontFamily: 'Kantumruy Pro',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildContactCard(EmergencyContactModel c) {
    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: () => _showContactDetails(c),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: const Color(0xFFEAEAF4)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x12000000),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 54,
              height: 54,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFF2EEFF),
              ),
              child: const Icon(
                Icons.contact_phone_rounded,
                color: AppColors.primary,
                size: 26,
              ),
            ),
            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    c.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16,
                      fontFamily: 'Kantumruy Pro',
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatMexicanPhone(c.phone),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontFamily: 'Kantumruy Pro',
                      fontWeight: FontWeight.w400,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),

            Material(
              color: const Color(0xFFF2EEFF),
              shape: const CircleBorder(),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: () => _call(c.phone),
                child: const Padding(
                  padding: EdgeInsets.all(12),
                  child: Icon(
                    Icons.call_rounded,
                    color: AppColors.primary,
                    size: 22,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
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
                                  onPressed: () => _showAddContactOptions(),
                                  icon: const Icon(Icons.add),
                                  label: const Text('Agregar'),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 8),

                          Expanded(
                            child: StreamBuilder<List<EmergencyContactModel>>(
                              stream:
                                  EmergencyContactsService.instance
                                      .contactsStream(),
                              builder: (context, snap) {
                                if (snap.connectionState ==
                                    ConnectionState.waiting) {
                                  return const Center(
                                    child: CircularProgressIndicator(),
                                  );
                                }

                                if (snap.hasError) {
                                  return const Center(
                                    child: Text(
                                      'No se pudieron cargar tus contactos.',
                                      textAlign: TextAlign.center,
                                    ),
                                  );
                                }

                                final contacts = snap.data ?? [];

                                if (contacts.isEmpty) {
                                  return const Center(
                                    child: Text(
                                      'Aún no has agregado contactos.',
                                    ),
                                  );
                                }

                                return ListView.separated(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 10,
                                  ),
                                  itemCount: contacts.length,
                                  separatorBuilder:
                                      (_, __) => const SizedBox(height: 10),
                                  itemBuilder: (_, i) {
                                    final c = contacts[i];
                                    return _buildContactCard(c);
                                  },
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
                  navigateToHome(context);
                },
                items: [
                  RadialMenuItem(
                    iconAsset: "assets/images/icon/psicologos.svg",
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
                        MaterialPageRoute(
                          builder: (context) => const Psicologos(),
                        ),
                      );
                    },
                  ),
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
                        MaterialPageRoute(
                          builder: (context) => const DiarioScreen(),
                        ),
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
                        MaterialPageRoute(
                          builder: (context) => const MetasScreen(),
                        ),
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
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class MexicanPhoneInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    String digits = newValue.text.replaceAll(RegExp(r'\D'), '');

    if (digits.length > 10) {
      digits = digits.substring(0, 10);
    }

    String formatted = digits;

    if (digits.length > 6) {
      formatted =
          '${digits.substring(0, 3)} ${digits.substring(3, 6)} ${digits.substring(6)}';
    } else if (digits.length > 3) {
      formatted = '${digits.substring(0, 3)} ${digits.substring(3)}';
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

class _EmergencyOptionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _EmergencyOptionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFF2EEFF),
              ),
              child: Icon(icon, color: AppColors.primary),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontFamily: 'Kantumruy Pro',
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontFamily: 'Kantumruy Pro',
                      fontWeight: FontWeight.w300,
                      fontSize: 13,
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
