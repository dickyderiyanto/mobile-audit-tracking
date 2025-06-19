// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:mobile_audit_tracking/bloc/audit/audit_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
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
                        const SizedBox(height: 50),
                        Expanded(
                          child: ListView.builder(
                            itemCount: filteredDetails.length,
                            itemBuilder: (context, index) {
                              final detail = filteredDetails[index];
                              return Card(
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                elevation: 4,
                                child: ListTile(
                                  title: Text("Invoice: ${detail.invoiceCode}"),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text("Salesman: ${detail.salesmanName}"),
                                      Text(
                                        "Tagihan: Rp.${detail.invoiceValue.toStringAsFixed(0)}",
                                      ),
                                      Text(
                                        "Sisa Bayar: Rp.${detail.paymentRemaining.toStringAsFixed(0)}",
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
                                        }
                                      });
                                    },
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
          padding: const EdgeInsets.all(16.0),
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
                  SnackBar(
                    content: Text('Pilih minimal satu invoice terlebih dahulu'),
                  ),
                );
                return;
              }

              final prefs = await SharedPreferences.getInstance();
              double? currLat = prefs.getDouble('current_lat');
              double? currLong = prefs.getDouble('current_long');

              final request = InvoiceStatusModel(
                auditId: widget.idAudit,
                cif: widget.cif,
                invoiceCodes: selectedInvoice!.toList(),
                statusInvoice: "1",
              );

              try {
                final repo = StatusInvoiceRepository();
                final response = await repo.updateInvoiceStatus(request);

                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(response)));

                // Jika berhasil, lanjut ke camera
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
