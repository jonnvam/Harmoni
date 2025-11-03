import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class EmergencyContact {
  final String id; // timestamp-based id
  final String name;
  final String phone;
  final String? relation;

  EmergencyContact({
    required this.id,
    required this.name,
    required this.phone,
    this.relation,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'phone': phone,
        'relation': relation,
      };

  static EmergencyContact fromJson(Map<String, dynamic> j) => EmergencyContact(
        id: j['id'] as String,
        name: j['name'] as String,
        phone: j['phone'] as String,
        relation: j['relation'] as String?,
      );
}

class EmergencyContactsRepo {
  EmergencyContactsRepo._();
  static final instance = EmergencyContactsRepo._();

  static const _kKey = 'emergency_contacts_v1';

  Future<SharedPreferences> get _prefs async => SharedPreferences.getInstance();

  Future<List<EmergencyContact>> list() async {
    final prefs = await _prefs;
    final raw = prefs.getString(_kKey);
    if (raw == null || raw.isEmpty) return [];
    try {
      final arr = (jsonDecode(raw) as List<dynamic>).cast<Map<String, dynamic>>();
      final items = arr.map(EmergencyContact.fromJson).toList();
      items.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
      return items;
    } catch (_) {
      return [];
    }
  }

  Future<void> saveAll(List<EmergencyContact> contacts) async {
    final prefs = await _prefs;
    await prefs.setString(
      _kKey,
      jsonEncode(contacts.map((e) => e.toJson()).toList()),
    );
  }

  Future<void> upsert(EmergencyContact contact) async {
    final items = await list();
    final idx = items.indexWhere((c) => c.id == contact.id);
    if (idx >= 0) {
      items[idx] = contact;
    } else {
      items.add(contact);
    }
    await saveAll(items);
  }

  Future<void> delete(String id) async {
    final items = await list();
    items.removeWhere((c) => c.id == id);
    await saveAll(items);
  }

  static String nextId() => DateTime.now().millisecondsSinceEpoch.toString();
}
