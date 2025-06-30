// ignore_for_file: avoid_print, use_build_context_synchronously

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mobile_audit_tracking/bloc/user_info/user_info_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_audit_tracking/repository/auth_repository.dart';
import 'package:mobile_audit_tracking/views/login_view.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../bloc/audit/audit_bloc.dart';
import '../database/database_helper.dart';
import '../models/invoice_status_model.dart';
import '../repository/audit_repository.dart';
import '../repository/camera_repository.dart';
import '../repository/status_invoice_repository.dart';
import 'preview_camera_screen.dart';

class ProfileView extends StatefulWidget {
  final String token;
  const ProfileView({super.key, required this.token});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  late AuditBloc _auditBloc;

  @override
  void initState() {
    Future.microtask(() {
      // ignore: use_build_context_synchronously
      context.read<UserInfoBloc>().add(LoadUserInfo(widget.token));
      _auditBloc = AuditBloc(AuditRepository());
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(title: const Text("Profil"), actions: const []),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned(
              top: 0,
              right: 0,
              left: 0,
              height: MediaQuery.of(context).size.height * 0.17,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(12),
                  ),
                  color: Colors.blue.shade800,
                ),
              ),
            ),
            Positioned(
              top: 20,
              left: 10,
              right: 10,
              // bottom: 20,
              child: Center(
                child: Text(
                  "Profil",
                  style: GoogleFonts.poppins(
                    textStyle: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: MediaQuery.of(context).size.height * 0.28 - 100,
              left: (MediaQuery.of(context).size.width - 320) / 2,
              child: Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Container(
                  width: 320,
                  height: 360,
                  padding: const EdgeInsets.all(16),
                  child: BlocBuilder<UserInfoBloc, UserInfoState>(
                    builder: (context, state) {
                      if (state is UserInfoLoading) {
                        return Center(child: CircularProgressIndicator());
                      } else if (state is UserInfoLoaded) {
                        final user = state.userInfo;

                        return Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            // const Text("Profile", style: TextStyle(fontSize: 20)),
                            CircleAvatar(
                              radius: 28.0,
                              backgroundImage: NetworkImage(
                                "https://res.cloudinary.com/dotz74j1p/raw/upload/v1716044979/nr7gt66alfhmu9vaxu2u.png",
                              ),
                            ),

                            const SizedBox(height: 16),
                            Text(
                              user.name,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text("Username: ${user.username}"),
                            Text("Kode User: ${user.userCode}"),
                            // Text("Role: ${user.roleCode}"),
                            // SizedBox(height: 40),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.black,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: () => _showLogoutDialog(context),
                              child: const Text("Keluar"),
                            ),
                            ElevatedButton.icon(
                              onPressed: () async {
                                showDialog(
                                  context: context,
                                  barrierDismissible: false,
                                  builder:
                                      (_) => AlertDialog(
                                        content: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: const [
                                            CircularProgressIndicator(),
                                            SizedBox(height: 16),
                                            Text("Menyinkronkan data..."),
                                          ],
                                        ),
                                      ),
                                );

                                try {
                                  final db = DatabaseHelper();
                                  final repo = StatusInvoiceRepository();

                                  // 1. Sinkronisasi invoice_status_offline
                                  final offlineInvoices =
                                      await db.getAllOfflineInvoiceStatuses();

                                  for (final entry in offlineInvoices) {
                                    final invoice = InvoiceDetailStatusModel(
                                      invoiceCode: entry['invoice_code'],
                                      keterangan: entry['keterangan'],
                                    );

                                    final request = InvoiceStatusModel(
                                      auditId: entry['audit_id'],
                                      cif: entry['cif'],
                                      statusInvoice: "1",
                                      invoices: [invoice],
                                    );

                                    try {
                                      await repo.updateInvoiceStatus(request);

                                      if (entry.containsKey('keterangan') &&
                                          entry['keterangan'] != null) {
                                        await repo.postKeteranganToko(
                                          entry['audit_id'],
                                          entry['cif'],
                                          entry['keterangan'],
                                        );
                                      }
                                    } catch (e) {
                                      debugPrint('❌ Gagal sinkron invoice: $e');
                                    }
                                  }

                                  await db.deleteAllOfflineInvoiceStatuses();

                                  // 2. Sinkronisasi photo_audit_offline
                                  final offlinePhotos =
                                      await db.getAllOfflinePhotos();
                                  final cameraRepo = CameraRepository();

                                  for (final photo in offlinePhotos) {
                                    try {
                                      final filePath = photo['file_path'];

                                      if (filePath == null ||
                                          filePath.toString().isEmpty) {
                                        debugPrint(
                                          '❌ file_path kosong untuk photo ID: ${photo['id']}',
                                        );
                                        continue;
                                      }

                                      final file = File(filePath);
                                      if (!await file.exists()) {
                                        debugPrint(
                                          '❌ file tidak ditemukan: $filePath',
                                        );
                                        continue;
                                      }

                                      await cameraRepo.uploadPhotoAudit(
                                        auditId: photo['audit_id'].toString(),
                                        cif: photo['cif'].toString(),
                                        imagePath: filePath.toString(),
                                        latitude: photo['latitude'].toString(),
                                        longitude:
                                            photo['longitude'].toString(),
                                      );

                                      await db.deleteOfflinePhoto(photo['id']);
                                    } catch (e) {
                                      debugPrint('❌ Gagal sinkron foto: $e');
                                    }
                                  }

                                  // 3. Opsional: Sinkron data lain
                                } catch (e) {
                                  debugPrint("❌ Error saat sinkronisasi: $e");
                                } finally {
                                  Navigator.of(context).pop(); // Tutup loading
                                }

                                // 4. Notifikasi sukses
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      '✅ Semua data offline berhasil disinkronkan',
                                    ),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              },

                              icon: const Icon(Icons.sync),
                              label: const Text("Sinkronkan Data Offline"),
                            ),

                            ElevatedButton.icon(
                              icon: const Icon(Icons.cloud_download),
                              label: const Text("Ambil Data dari Server"),
                              onPressed: () async {
                                final isOnline = await isConnected();
                                if (!isOnline) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        "🚫 Tidak ada koneksi internet",
                                      ),
                                    ),
                                  );
                                  return;
                                }

                                // ✅ Tampilkan dialog loading
                                showDialog(
                                  context: context,
                                  barrierDismissible: false,
                                  builder:
                                      (_) => const Center(
                                        child: CircularProgressIndicator(),
                                      ),
                                );

                                final repo = AuditRepository();
                                final db = DatabaseHelper();
                                final prefs =
                                    await SharedPreferences.getInstance();

                                try {
                                  final audit = await repo.fetchAuditData(
                                    widget.token,
                                  );

                                  await prefs.setString(
                                    'id_audit',
                                    audit.idAudit,
                                  );

                                  final exists = await db.auditExists(
                                    audit.idAudit,
                                  );
                                  if (!exists) {
                                    await db.clearAuditData();
                                    await db.insertAudit(audit);
                                    print(
                                      "✅ Data audit berhasil disimpan ke SQLite",
                                    );
                                  } else {
                                    print(
                                      "ℹ️ Data audit sudah ada, akan diperbarui",
                                    );
                                    await db.clearAuditData();
                                    await db.insertAudit(audit);
                                  }

                                  _auditBloc.add(
                                    LoadAuditFromLocal(audit.idAudit),
                                  );

                                  Navigator.pop(
                                    context,
                                  ); // ✅ Tutup dialog loading

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        "✅ Data berhasil diambil dari server",
                                      ),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                } catch (e) {
                                  Navigator.pop(
                                    context,
                                  ); // ✅ Tutup dialog jika error juga
                                  print("❌ Error ambil data dari server: $e");
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text("❌ Gagal ambil data: $e"),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue.shade800,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                minimumSize: const Size(double.infinity, 48),
                              ),
                            ),
                          ],
                        );
                      } else if (state is UserInfoError) {
                        return Center(child: Text("Gagal memuat data profile"));
                      } else {
                        return Text("Tidak ada data user");
                      }
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void _showLogoutDialog(BuildContext context) {
  showDialog(
    context: context,
    builder:
        (context) => AlertDialog(
          title: const Text('Konfirmasi'),
          content: const Text('Apakah yakin ingin keluar aplikasi ?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(), // Batal
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop(); // Tutup dialog

                // Hapus token dan pindah ke login
                await AuthRepository().logout();
                // ignore: use_build_context_synchronously
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginView()),
                  (route) => false,
                );
              },
              child: const Text('Keluar'),
            ),
          ],
        ),
  );
}
