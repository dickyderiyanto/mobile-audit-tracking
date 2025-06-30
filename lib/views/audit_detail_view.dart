// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_audit_tracking/core/config/format_currency.dart';
import 'package:mobile_audit_tracking/models/audit_model.dart';
import 'package:mobile_audit_tracking/views/camera_screen.dart';
import 'package:mobile_audit_tracking/database/database_helper.dart';
import 'package:mobile_audit_tracking/repository/status_invoice_repository.dart';
import 'package:mobile_audit_tracking/models/invoice_status_model.dart';
import 'package:camera/camera.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class AuditDetailView extends StatefulWidget {
  final String token;
  final String cif;
  final String idAudit;
  final AuditModel audit;

  const AuditDetailView({
    super.key,
    required this.token,
    required this.cif,
    required this.idAudit,
    required this.audit,
  });

  @override
  State<AuditDetailView> createState() => _AuditDetailViewState();
}

class _AuditDetailViewState extends State<AuditDetailView> {
  List<String> selectedInvoice = [];
  Map<String, String> selectedReasonPerInvoice = {};
  Map<String, String?> selectedSubReasonPerInvoice = {};
  final TextEditingController keteranganController = TextEditingController();

  final Map<String, List<String>> fakturOptions = {
    "Barang diterima, faktur belum bayar.": [
      "Belum jatuh tempo",
      "Sales tidak kunjungan",
      "Barang masih ada",
    ],
    "Barang diterima, faktur sudah dibayar.": [],
    "Barang tidak diterima toko": [],
    "Faktur udah cicil, nilai benar per hari ini.": [],
    "Toko tidak ditemukan": [],
  };

  Future<bool> isConnected() async {
    try {
      final result = await InternetAddress.lookup('audit.jessindo.net');
      final connected = result.isNotEmpty && result.first.rawAddress.isNotEmpty;
      print("🌐 Internet status: $connected");
      return connected;
    } catch (e) {
      print("🚫 Tidak ada koneksi internet: $e");
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final group = widget.audit.groupDetails.firstWhere(
      (group) => group.auditDetails.any((detail) => detail.cif == widget.cif),
      orElse: () => throw Exception("Customer tidak ditemukan!"),
    );

    final filteredDetails =
        group.auditDetails.where((detail) => detail.cif == widget.cif).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text("List of Invoices"),
        backgroundColor: Colors.blue.shade800,
        foregroundColor: Colors.white,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: filteredDetails.length,
        itemBuilder: (context, index) {
          final detail = filteredDetails[index];
          final isChecked = selectedInvoice.contains(detail.invoiceCode);

          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 3,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          "Invoice: ${detail.invoiceCode}",
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      Checkbox(
                        value: selectedInvoice!.contains(detail.invoiceCode),
                        onChanged: (val) {
                          setState(() {
                            if (val == true) {
                              selectedInvoice!.add(detail.invoiceCode);
                            } else {
                              selectedInvoice!.remove(detail.invoiceCode);
                              selectedReasonPerInvoice.remove(
                                detail.invoiceCode,
                              );
                              selectedSubReasonPerInvoice.remove(
                                detail.invoiceCode,
                              );
                            }
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Salesman: ${detail.salesmanName}",
                    style: GoogleFonts.poppins(fontSize: 12),
                  ),
                  Text(
                    "Tagihan: ${FormatCurrency.formatCurrency.format(detail.invoiceValue)}",
                    style: GoogleFonts.poppins(fontSize: 12),
                  ),
                  Text(
                    "Sisa Bayar: ${FormatCurrency.formatCurrency.format(detail.paymentRemaining)}",
                    style: GoogleFonts.poppins(fontSize: 12),
                  ),
                  const SizedBox(height: 10),

                  // Dropdown Keterangan
                  DropdownButtonFormField<String>(
                    isExpanded: true,
                    value: selectedReasonPerInvoice[detail.invoiceCode],
                    decoration: InputDecoration(
                      labelText: "Keterangan Faktur",
                      labelStyle: GoogleFonts.poppins(fontSize: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                    items:
                        fakturOptions.keys.map((value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(
                              value,
                              style: GoogleFonts.poppins(fontSize: 12),
                            ),
                          );
                        }).toList(),
                    onChanged:
                        selectedInvoice!.contains(detail.invoiceCode)
                            ? (value) {
                              setState(() {
                                selectedReasonPerInvoice[detail.invoiceCode] =
                                    value!;
                                selectedSubReasonPerInvoice[detail
                                        .invoiceCode] =
                                    null;
                              });
                            }
                            : null,
                  ),

                  const SizedBox(height: 8),

                  if ((fakturOptions[selectedReasonPerInvoice[detail
                              .invoiceCode]] ??
                          [])
                      .isNotEmpty)
                    DropdownButtonFormField<String>(
                      isExpanded: true,
                      value: selectedSubReasonPerInvoice[detail.invoiceCode],
                      decoration: InputDecoration(
                        labelText: "Detail Keterangan",
                        labelStyle: GoogleFonts.poppins(fontSize: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                      items:
                          fakturOptions[selectedReasonPerInvoice[detail
                                  .invoiceCode]]!
                              .map((subOption) {
                                return DropdownMenuItem<String>(
                                  value: subOption,
                                  child: Text(
                                    subOption,
                                    style: GoogleFonts.poppins(fontSize: 12),
                                  ),
                                );
                              })
                              .toList(),
                      onChanged:
                          selectedInvoice!.contains(detail.invoiceCode)
                              ? (value) {
                                setState(() {
                                  selectedSubReasonPerInvoice[detail
                                          .invoiceCode] =
                                      value!;
                                });
                              }
                              : null,
                    ),
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(12),
        child: ElevatedButton.icon(
          icon: const Icon(Icons.done, color: Colors.white),
          label: Text(
            "Selesai",
            style: GoogleFonts.poppins(
              textStyle: TextStyle(color: Colors.white),
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue.shade800,
            minimumSize: const Size(double.infinity, 48),
          ),
          onPressed: () async {
            if (selectedInvoice.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Pilih minimal satu invoice")),
              );
              return;
            }

            final hasEmptyKeterangan = selectedInvoice.any(
              (code) =>
                  selectedReasonPerInvoice[code] == null ||
                  selectedReasonPerInvoice[code]!.isEmpty,
            );

            if (hasEmptyKeterangan) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Semua invoice harus punya keterangan"),
                ),
              );
              return;
            }

            final prefs = await SharedPreferences.getInstance();
            final lat = prefs.getDouble("current_lat") ?? 0.0;
            final long = prefs.getDouble("current_long") ?? 0.0;

            final isOnline = await isConnected();

            // Dialog input catatan toko
            await showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) {
                return AlertDialog(
                  title: const Text("Catatan Toko"),
                  content: TextField(
                    controller: keteranganController,
                    decoration: const InputDecoration(
                      hintText: "Masukkan catatan toko...",
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Batal"),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        if (keteranganController.text.trim().isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Catatan toko wajib diisi"),
                            ),
                          );
                          return;
                        }
                        final isOnline = await isConnected();
                        try {
                          final db = DatabaseHelper();

                          if (!isOnline) {
                            for (final code in selectedInvoice) {
                              final kategori =
                                  selectedReasonPerInvoice[code] ?? '';
                              final sub = selectedSubReasonPerInvoice[code];
                              final fullKet =
                                  sub != null ? "$kategori - $sub" : kategori;

                              await db.insertInvoiceStatusOffline(
                                auditId: widget.idAudit,
                                cif: widget.cif,
                                invoiceCode: code,
                                keterangan: fullKet,
                              );
                            }
                          } else {
                            final repo = StatusInvoiceRepository();
                            final invoices =
                                selectedInvoice.map((code) {
                                  final kategori =
                                      selectedReasonPerInvoice[code] ?? '';
                                  final sub = selectedSubReasonPerInvoice[code];
                                  final fullKet =
                                      sub != null
                                          ? "$kategori - $sub"
                                          : kategori;

                                  return InvoiceDetailStatusModel(
                                    invoiceCode: code,
                                    keterangan: fullKet,
                                  );
                                }).toList();

                            final request = InvoiceStatusModel(
                              auditId: widget.idAudit,
                              cif: widget.cif,
                              statusInvoice: "1",
                              invoices: invoices,
                            );

                            await repo.updateInvoiceStatus(request);
                            await repo.postKeteranganToko(
                              widget.idAudit,
                              widget.cif,
                              keteranganController.text,
                            );
                          }

                          Navigator.pop(context);

                          final cameras = await availableCameras();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (_) => CameraScreen(
                                    cameras: cameras,
                                    idAudit: widget.idAudit,
                                    cif: widget.cif,
                                    latitude: lat,
                                    longitude: long,
                                  ),
                            ),
                          );
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("Gagal simpan: $e"),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
                      child: const Text("Lanjut"),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }
}
