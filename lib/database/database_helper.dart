// ignore_for_file: avoid_print

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/audit_model.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('audit_database.db');
    return _database!;
  }

  Future<Database> _initDB(String fileName) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, fileName);

    return await openDatabase(path, version: 3, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE audit (
        id_audit TEXT PRIMARY KEY,
        user_name TEXT,
        visit_date TEXT,
        total_payment_remaining TEXT,
        status_visit TEXT
      );
    ''');

    await db.execute('''
      CREATE TABLE group_details (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        audit_id TEXT,
        customer_name TEXT,
        customer_area_name TEXT,
        total_invoice_value TEXT
      );
    ''');

    await db.execute('''
      CREATE TABLE audit_details (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        audit_id TEXT,
        customer_name TEXT,
        invoice_code TEXT,
        invoice_value TEXT,
        payment_remaining TEXT,
        salesman_name TEXT,
        cif TEXT,
        latitude TEXT,
        longitude TEXT,
        payment REAL, 
        visit_status TEXT
      );
    ''');

    await db.execute('''
      CREATE TABLE invoice_status_offline (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        audit_id TEXT,
        cif TEXT,
        invoice_code TEXT,
        status_invoice TEXT,
        keterangan TEXT,
        created_at TEXT
      );
    ''');

    await db.execute('''
    CREATE TABLE photo_audit_offline (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      audit_id TEXT,
      cif TEXT,
      file_path TEXT,
      latitude TEXT,
      longitude TEXT,
      created_at TEXT
    );
    ''');

    await db.execute('''
  CREATE TABLE faktur_options (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    category TEXT,
    option_text TEXT
  );
''');
  }

  // ========== Insert Audit Data ==========
  Future<void> insertAudit(AuditModel audit) async {
    final db = await database;

    final exists = await auditExists(audit.idAudit);
    if (exists) {
      print("⚠️ Audit dengan ID ${audit.idAudit} sudah ada. Skip insert.");
      return;
    }

    await db.insert('audit', audit.toMap());

    for (final group in audit.groupDetails) {
      await db.insert('group_details', group.toMap(audit.idAudit));

      for (final detail in group.auditDetails) {
        await db.insert(
          'audit_details',
          detail.toMap(audit.idAudit, group.customerName),
        );
      }
    }
  }

  Future<void> insertFakturOptions(Map<String, List<String>> options) async {
    final db = await database;

    // Bersihkan data lama
    await db.delete('faktur_options');

    // Masukkan data baru
    for (final entry in options.entries) {
      final category = entry.key;
      final optionList = entry.value;

      // Jika tidak ada opsi, tetap simpan kategori tanpa opsi
      if (optionList.isEmpty) {
        await db.insert('faktur_options', {
          'category': category,
          'option_text': null,
        });
      } else {
        for (final option in optionList) {
          await db.insert('faktur_options', {
            'category': category,
            'option_text': option,
          });
        }
      }
    }
  }

  Future<Map<String, List<String>>> getFakturOptions() async {
    final db = await database;
    final result = await db.query('faktur_options');

    Map<String, List<String>> grouped = {};
    for (final row in result) {
      final category = row['category'] as String;
      final option = row['option_text'] as String?;

      if (!grouped.containsKey(category)) {
        grouped[category] = [];
      }

      if (option != null) {
        grouped[category]!.add(option);
      }
    }

    return grouped;
  }

  // ========== Get Audit by ID ==========
  Future<AuditModel?> getAuditById(String auditId) async {
    final db = await database;

    final auditResult = await db.query(
      'audit',
      where: 'id_audit = ?',
      whereArgs: [auditId],
    );
    if (auditResult.isEmpty) return null;

    final auditMap = auditResult.first;

    final groupResults = await db.query(
      'group_details',
      where: 'audit_id = ?',
      whereArgs: [auditId],
    );

    List<GroupDetail> groups = [];

    for (final groupMap in groupResults) {
      final customerName = groupMap['customer_name'] as String;

      final detailResults = await db.query(
        'audit_details',
        where: 'audit_id = ? AND customer_name = ?',
        whereArgs: [auditId, customerName],
      );

      final detailList =
          detailResults.map((e) => AuditDetail.fromMap(e)).toList();

      final group = GroupDetail.fromMap(groupMap, detailList);
      groups.add(group);
    }

    return AuditModel.fromMap(auditMap, groups);
  }

  // ========== Audit Exist ==========
  Future<bool> auditExists(String auditId) async {
    final db = await database;
    final result = await db.query(
      'audit',
      where: 'id_audit = ?',
      whereArgs: [auditId],
    );
    return result.isNotEmpty;
  }

  // ========== Clear Audit ==========
  Future<void> clearAuditData() async {
    final db = await database;
    await db.delete('audit_details');
    await db.delete('group_details');
    await db.delete('audit');
  }

  // ========== Get Audit Detail by CIF ==========
  Future<List<AuditDetail>> getAuditDetailsByCIF(
    String auditId,
    String cif,
  ) async {
    final db = await database;
    final result = await db.query(
      'audit_details',
      where: 'audit_id = ? AND cif = ?',
      whereArgs: [auditId, cif],
    );

    return result.map((e) => AuditDetail.fromMap(e)).toList();
  }

  // ========== Update Status Visit ==========
  Future<void> updateAuditDetailStatus({
    required String auditId,
    required String invoiceCode,
    required String visitStatus,
    required double payment,
  }) async {
    final db = await database;
    await db.update(
      'audit_details',
      {'visit_status': visitStatus},
      where: 'audit_id = ? AND invoice_code = ?',
      whereArgs: [auditId, invoiceCode],
    );
  }

  // ========== INSERT Invoice Status OFFLINE ==========
  Future<void> insertInvoiceStatusOffline({
    required String auditId,
    required String cif,
    required String invoiceCode,
    required String keterangan,
    required double payment,
  }) async {
    final db = await database;

    // Cek apakah data udah ada
    final existing = await db.query(
      'invoice_status_offline',
      where: 'audit_id = ? AND invoice_code = ?',
      whereArgs: [auditId, invoiceCode],
    );

    if (existing.isEmpty) {
      await db.insert('invoice_status_offline', {
        'audit_id': auditId,
        'cif': cif,
        'invoice_code': invoiceCode,
        'status_invoice': "1",
        'keterangan': keterangan,
        'payment': payment,
        'created_at': DateTime.now().toIso8601String(),
      });
    } else {
      await db.update(
        'invoice_status_offline',
        {
          'keterangan': keterangan,
          'payment': payment,
          'created_at': DateTime.now().toIso8601String(),
        },
        where: 'audit_id = ? AND invoice_code = ?',
        whereArgs: [auditId, invoiceCode],
      );
    }
  }

  // ========== GET All Offline Invoice ==========
  Future<List<Map<String, dynamic>>> getAllOfflineInvoiceStatuses() async {
    final db = await database;
    return await db.query('invoice_status_offline');
  }

  // ========== DELETE All Offline ==========
  Future<void> deleteAllOfflineInvoiceStatuses() async {
    final db = await database;
    await db.delete('invoice_status_offline');
  }

  Future<void> insertOfflinePhoto({
    required String auditId,
    required String cif,
    required String filePath,
    required String latitude,
    required String longitude,
  }) async {
    final db = await database;
    await db.insert('photo_audit_offline', {
      'audit_id': auditId,
      'cif': cif,
      'file_path': filePath,
      'latitude': latitude,
      'longitude': longitude,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  Future<List<Map<String, dynamic>>> getAllOfflinePhotos() async {
    final db = await database;
    return await db.query('photo_audit_offline');
  }

  Future<void> deleteOfflinePhoto(int id) async {
    final db = await database;
    await db.delete('photo_audit_offline', where: 'id = ?', whereArgs: [id]);
  }
}
