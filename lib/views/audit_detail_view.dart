// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:mobile_audit_tracking/bloc/audit/audit_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_audit_tracking/core/config/format_currency.dart';
import 'package:mobile_audit_tracking/repository/status_invoice_repository.dart';
import 'package:mobile_audit_tracking/views/camera_screen.dart';
import '../models/invoice_status_model.dart';
import '../repository/audit_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:camera/camera.dart';

class AuditDetailView extends StatefulWidget {
  final String token;
  final String cif;
  final String idAudit;

  const AuditDetailView({
    super.key,
    required this.token,
    required this.cif,
    required this.idAudit,
  });

  @override
  State<AuditDetailView> createState() => _AuditDetailViewState();
}

class _AuditDetailViewState extends State<AuditDetailView> {
  late AuditBloc _auditBloc;
  List<String>? selectedInvoice = [];
  Map<String, String> selectedReasonPerInvoice = {};
  final TextEditingController keteranganController = TextEditingController();

  final List<String> fakturOptions = [
    "Barang diterima, faktur belum bayar.",
    "Barang diterima, faktur sudah dibayar.",
    "Barang tidak diterima toko",
    "Faktur udah cicil, nilai benar per hari ini.",
    "Toko tidak ditemukan",
  ];

  String? selectedReason;

  @override
  void initState() {
    super.initState();
    _auditBloc = AuditBloc(AuditRepository());
    _auditBloc.add(FetchAuditData(widget.token));
  }

  @override
  void dispose() {
    _auditBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => _auditBloc,
      child: Scaffold(
        body: SafeArea(
          child: BlocBuilder<AuditBloc, AuditState>(
            builder: (context, state) {
              if (state is AuditLoading) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is AuditLoaded) {
                final group = state.audit.groupDetails.firstWhere(
                  (group) => group.auditDetails.any(
                    (detail) => detail.cif == widget.cif,
                  ),
                  orElse: () => throw Exception('Customer tidak ditemukan!'),
                );

                final filteredDetails =
                    group.auditDetails
                        .where((detail) => detail.cif == widget.cif)
                        .toList();

                return Stack(
                  children: [
                    Positioned(
                      top: 0,
                      right: 0,
                      left: 0,
                      height: MediaQuery.of(context).size.height * 0.10,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.blue.shade800,
                          borderRadius: const BorderRadius.vertical(
                            bottom: Radius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 20),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Center(
                            child: Text(
                              "List of Invoices",
                              style: GoogleFonts.poppins(
                                textStyle: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 42),
                        Expanded(
                          child: ListView.builder(
                            itemCount:
                                filteredDetails.length, // +1 untuk dropdown
                            itemBuilder: (context, index) {
                              final detail = filteredDetails[index];
                              return Card(
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                elevation: 4,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 4,
                                    vertical: 4,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      ListTile(
                                        title: Text(
                                          "Invoice: ${detail.invoiceCode}",
                                          style: GoogleFonts.poppins(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.black,
                                          ),
                                        ),
                                        subtitle: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "Salesman: ${detail.salesmanName}",
                                              style: GoogleFonts.poppins(
                                                fontSize: 12,
                                              ),
                                            ),
                                            Text(
                                              "Tagihan: ${FormatCurrency.formatCurrency.format(detail.invoiceValue)}",
                                              style: GoogleFonts.poppins(
                                                fontSize: 12,
                                              ),
                                            ),
                                            Text(
                                              "Sisa Bayar: ${FormatCurrency.formatCurrency.format(detail.paymentRemaining)}",
                                              style: GoogleFonts.poppins(
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        ),
                                        trailing: Checkbox(
                                          value: selectedInvoice!.contains(
                                            detail.invoiceCode,
                                          ),
                                          onChanged: (bool? value) {
                                            setState(() {
                                              if (value == true) {
                                                selectedInvoice!.add(
                                                  detail.invoiceCode,
                                                );
                                              } else {
                                                selectedInvoice!.remove(
                                                  detail.invoiceCode,
                                                );
                                                selectedReasonPerInvoice.remove(
                                                  detail.invoiceCode,
                                                ); // hapus juga keterangannya
                                              }
                                            });
                                          },
                                        ),
                                      ),

                                      const SizedBox(height: 12),
                                      DropdownButtonFormField<String>(
                                        isExpanded: true,
                                        decoration: InputDecoration(
                                          labelText: "Keterangan Faktur",
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                horizontal: 12,
                                                vertical: 10,
                                              ),
                                        ),
                                        value:
                                            selectedReasonPerInvoice[detail
                                                .invoiceCode],
                                        hint: Text(
                                          "Pilih keterangan faktur",
                                          style: GoogleFonts.poppins(
                                            textStyle: TextStyle(fontSize: 12),
                                          ),
                                        ),
                                        items:
                                            fakturOptions.map((option) {
                                              return DropdownMenuItem<String>(
                                                value: option,
                                                child: Text(
                                                  option,
                                                  style: GoogleFonts.poppins(
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              );
                                            }).toList(),
                                        onChanged:
                                            selectedInvoice!.contains(
                                                  detail.invoiceCode,
                                                )
                                                ? (value) {
                                                  setState(() {
                                                    selectedReasonPerInvoice[detail
                                                            .invoiceCode] =
                                                        value!;
                                                  });
                                                }
                                                : null, // nonaktif kalau belum dipilih
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),

                        const SizedBox(
                          height: 80,
                        ), // Spacer agar tidak tertutup tombol bawah
                      ],
                    ),
                  ],
                );
              } else if (state is AuditError) {
                return const Center(child: Text("Data tidak ada!"));
              }

              return const SizedBox();
            },
          ),
        ),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: OutlinedButton.icon(
            icon: const Icon(Icons.done_all),
            label: const Text("Selesai"),
            style: OutlinedButton.styleFrom(
              backgroundColor: Colors.blue.shade800,
              foregroundColor: Colors.white,
              side: const BorderSide(color: Colors.grey),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              minimumSize: const Size(double.infinity, 48),
            ),
            onPressed: () async {
              if (selectedInvoice!.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Pilih minimal satu invoice')),
                );
                return;
              }

              // validasi keterangan
              final hasEmptyKeterangan = selectedInvoice!.any(
                (code) =>
                    selectedReasonPerInvoice[code] == null ||
                    selectedReasonPerInvoice[code]!.isEmpty,
              );

              if (hasEmptyKeterangan) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Semua invoice harus punya keterangan'),
                  ),
                );
                return;
              }

              final prefs = await SharedPreferences.getInstance();
              double? currLat = prefs.getDouble('current_lat');
              double? currLong = prefs.getDouble('current_long');

              final invoices =
                  selectedInvoice!.map((code) {
                    return InvoiceDetailStatusModel(
                      invoiceCode: code,
                      keterangan: selectedReasonPerInvoice[code] ?? '',
                    );
                  }).toList();

              final request = InvoiceStatusModel(
                auditId: widget.idAudit,
                cif: widget.cif,
                statusInvoice: "1",
                invoices: invoices,
              );
              await showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: Text('Catatan Toko'),
                    content: TextField(
                      controller: keteranganController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: 'Masukkan keterangan toko...',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text('Batal'),
                      ),
                      ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text('Lanjut'),
                      ),
                    ],
                  );
                },
              );
              try {
                final repo = StatusInvoiceRepository();
                final response = await repo.updateInvoiceStatus(request);
                await repo.postKeteranganToko(
                  widget.idAudit,
                  widget.cif,
                  keteranganController.text,
                );
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(response)));

                final cameras = await availableCameras();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => CameraScreen(
                          cameras: cameras,
                          idAudit: widget.idAudit,
                          cif: widget.cif,
                          latitude: currLat ?? 0.0,
                          longitude: currLong ?? 0.0,
                        ),
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Gagal update invoice: $e')),
                );
              }
            },
          ),
        ),
      ),
    );
  }
}
