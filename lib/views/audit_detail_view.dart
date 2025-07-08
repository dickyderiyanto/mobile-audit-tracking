// ignore_for_file: use_build_context_synchronously, avoid_print

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_audit_tracking/core/config/format_currency.dart';
import 'package:mobile_audit_tracking/models/audit_model.dart';
import 'package:mobile_audit_tracking/repository/audit_repository.dart';
import 'package:mobile_audit_tracking/views/camera_screen.dart';
import 'package:mobile_audit_tracking/database/database_helper.dart';
import 'package:mobile_audit_tracking/repository/status_invoice_repository.dart';
import 'package:mobile_audit_tracking/models/invoice_status_model.dart';
import 'package:camera/camera.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  bool isLoading = false;
  Map<String, String> paymentInvoices = {};
  String roleCode = "";
  Map<String, List<String>> fakturOptions = {};

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

  void loadFakturOptions() async {
    final isOnline = await isConnected();
    if (isOnline) {
      try {
        fakturOptions = await fetchFakturOptions();
        await DatabaseHelper().insertFakturOptions(fakturOptions);
        setState(() {});
      } catch (e) {
        print("Gagal ambil data faktur (online): $e");

        // fallback offline jika online gagal
        fakturOptions = await DatabaseHelper().getFakturOptions();
        setState(() {});
      }
    } else {
      // ✅ tambahkan ini
      fakturOptions = await DatabaseHelper().getFakturOptions();
      print("📦 Data faktur dari SQLite: $fakturOptions");
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    loadFakturOptions();
    SharedPreferences.getInstance().then((prefs) {
      setState(() {
        roleCode = prefs.getString("role_code") ?? "";
      });
    });
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
          selectedInvoice.contains(detail.invoiceCode);

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
                        value: selectedInvoice.contains(detail.invoiceCode),
                        onChanged: (val) {
                          setState(() {
                            if (val == true) {
                              selectedInvoice.add(detail.invoiceCode);
                            } else {
                              selectedInvoice.remove(detail.invoiceCode);
                              selectedReasonPerInvoice.remove(
                                detail.invoiceCode,
                              );
                              selectedSubReasonPerInvoice.remove(
                                detail.invoiceCode,
                              );
                              paymentInvoices.remove(detail.payment);
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
                        selectedInvoice.contains(detail.invoiceCode)
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
                          selectedInvoice.contains(detail.invoiceCode)
                              ? (value) {
                                setState(() {
                                  selectedSubReasonPerInvoice[detail
                                          .invoiceCode] =
                                      value!;
                                });
                              }
                              : null,
                    ),
                  if ((roleCode == "07" || roleCode == "08") &&
                      selectedInvoice.contains(detail.invoiceCode))
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: StatefulBuilder(
                        builder: (context, setState) {
                          final controller = TextEditingController(
                            text:
                                paymentInvoices[detail.invoiceCode] != null
                                    ? FormatCurrency.formatCurrency.format(
                                      int.tryParse(
                                            paymentInvoices[detail
                                                .invoiceCode]!,
                                          ) ??
                                          0,
                                    )
                                    : '',
                          );

                          return TextField(
                            controller: controller,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: "Nominal Bayar",
                              labelStyle: GoogleFonts.poppins(fontSize: 12),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                            ),
                            onChanged: (value) {
                              // Bersihkan input dari karakter non-digit
                              String digitsOnly = value.replaceAll(
                                RegExp(r'[^\d]'),
                                '',
                              );

                              // Update value yang disimpan ke map
                              paymentInvoices[detail.invoiceCode] = digitsOnly;

                              // Format ulang tampilan
                              final newText = FormatCurrency.formatCurrency
                                  .format(double.tryParse(digitsOnly) ?? 0);
                              controller.value = TextEditingValue(
                                text: newText,
                                selection: TextSelection.collapsed(
                                  offset: newText.length,
                                ),
                              );
                            },
                          );
                        },
                      ),
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
            final totalInvoice = filteredDetails.length;
            final selectedCount = selectedInvoice.length;

            if (selectedCount < totalInvoice) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Checklist semua invoice sebelum lanjut."),
                ),
              );
              return;
            }
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
                      onPressed:
                          isLoading ? null : () => Navigator.pop(context),
                      child: const Text("Batal"),
                    ),
                    ElevatedButton(
                      onPressed:
                          isLoading
                              ? null
                              : () async {
                                if (keteranganController.text.trim().isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text("Catatan toko wajib diisi"),
                                    ),
                                  );
                                  return;
                                }

                                setState(() {
                                  isLoading = true;
                                });

                                final isOnline = await isConnected();
                                try {
                                  final db = DatabaseHelper();

                                  if (!isOnline) {
                                    for (final code in selectedInvoice) {
                                      final kategori =
                                          selectedReasonPerInvoice[code] ?? '';
                                      final sub =
                                          selectedSubReasonPerInvoice[code];
                                      final fullKet =
                                          sub != null
                                              ? "$kategori - $sub"
                                              : kategori;
                                      final paid = paymentInvoices[code];

                                      final sanitizedPaid =
                                          paid?.replaceAll(
                                            RegExp(r'[^\d]'),
                                            '',
                                          ) ??
                                          '0';

                                      final paided =
                                          double.tryParse(sanitizedPaid) ?? 0.0;

                                      await db.insertInvoiceStatusOffline(
                                        auditId: widget.idAudit,
                                        cif: widget.cif,
                                        invoiceCode: code,
                                        keterangan: fullKet,
                                        payment: paided,
                                      );
                                    }
                                  } else {
                                    final repo = StatusInvoiceRepository();
                                    final invoices =
                                        selectedInvoice.map((code) {
                                          final kategori =
                                              selectedReasonPerInvoice[code] ??
                                              '';
                                          final sub =
                                              selectedSubReasonPerInvoice[code];
                                          final fullKet =
                                              sub != null
                                                  ? "$kategori - $sub"
                                                  : kategori;
                                          final paid = paymentInvoices[code];

                                          final sanitizedPaid =
                                              paid?.replaceAll(
                                                RegExp(r'[^\d]'),
                                                '',
                                              ) ??
                                              '0';

                                          final paided =
                                              double.tryParse(sanitizedPaid) ??
                                              0.0;

                                          return InvoiceDetailStatusModel(
                                            invoiceCode: code,
                                            keterangan: fullKet,
                                            payment: paided,
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
                                } finally {
                                  setState(() {
                                    isLoading = false;
                                  });
                                }
                              },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                      ),
                      child:
                          isLoading
                              ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                              : const Text("Lanjut"),
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
