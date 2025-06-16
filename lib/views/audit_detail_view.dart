import 'package:flutter/material.dart';
import 'package:mobile_audit_tracking/bloc/audit/audit_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_audit_tracking/views/audit_view.dart';
import 'package:mobile_audit_tracking/views/camera_view.dart';
import '../repository/audit_repository.dart';

class AuditDetailView extends StatefulWidget {
  final String token;
  final String cif;
  const AuditDetailView({super.key, required this.token, required this.cif});

  @override
  State<AuditDetailView> createState() => _AuditDetailViewState();
}

class _AuditDetailViewState extends State<AuditDetailView> {
  late AuditBloc _auditBloc;

  @override
  void initState() {
    super.initState();
    _auditBloc = AuditBloc(AuditRepository());
    _auditBloc.add(FetchAuditData(widget.token));
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _auditBloc.close();
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
                return Center(child: CircularProgressIndicator());
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
                          borderRadius: BorderRadius.vertical(
                            bottom: Radius.circular(20),
                          ),
                          color: Colors.blue.shade800,
                        ),
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 20),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            // vertical: 12,
                          ),
                          child: Center(
                            child: Text(
                              "List of Faktur",
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
                        SizedBox(height: 50),
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
                                  trailing: IconButton(
                                    icon: const Icon(
                                      Icons.check_box,
                                      color: Colors.red,
                                    ),
                                    onPressed: () {
                                      // final lat = detail.latitude;
                                      // final lng = detail.longitude;
                                      // print(
                                      //   "Navigasi ke koordinat: $lat, $lng",
                                      // );
                                      // bisa tambahkan logika navigasi ke Google Maps di sini
                                    },
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        // SizedBox(height: 60),
                        OutlinedButton.icon(
                          icon: const Icon(Icons.done_all),
                          label: const Text("Selesai"),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.green,
                            side: const BorderSide(color: Colors.green),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () {
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CameraView(),
                              ),
                              ModalRoute.withName('/home'),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                );
              } else if (state is AuditError) {
                return Center(child: Text("Data tidak ada!"));
              }

              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
  }
}
