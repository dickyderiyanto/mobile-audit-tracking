// ignore_for_file: depend_on_referenced_packages, avoid_print, unrelated_type_equality_checks, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_audit_tracking/core/config/format_currency.dart';
import 'package:mobile_audit_tracking/core/config/get_location.dart';
import 'package:mobile_audit_tracking/models/audit_model.dart';
import 'package:mobile_audit_tracking/views/audit_detail_view.dart';
import 'package:mobile_audit_tracking/views/login_view.dart';
import '../bloc/audit/audit_bloc.dart';
// import '../models/audit_model.dart' show AuditDetail, GroupDetail;
import '../repository/audit_repository.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:android_intent_plus/android_intent.dart';
import 'package:android_intent_plus/flag.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:safe_device/safe_device.dart';

import '../repository/auth_repository.dart' show AuthRepository;

class AuditView extends StatefulWidget {
  final String token; // Token dari login

  const AuditView({super.key, required this.token});

  @override
  State<AuditView> createState() => _AuditViewState();
}

class _AuditViewState extends State<AuditView> {
  late AuditBloc _auditBloc;
  late TextEditingController _searchController;
  List<GroupDetail> filteredGroupDetails = [];
  bool checkinButtonShown = false;

  @override
  void initState() {
    super.initState();
    _auditBloc = AuditBloc(AuditRepository());
    _auditBloc.add(FetchAuditData(widget.token));
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _auditBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _auditBloc,
      child: Scaffold(
        // appBar: AppBar(title: const Text("Audit Report")),
        body: SafeArea(
          child: BlocBuilder<AuditBloc, AuditState>(
            builder: (context, state) {
              if (state is AuditLoading) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is AuditLoaded) {
                final audit = state.audit;
                if (filteredGroupDetails.isEmpty) {
                  filteredGroupDetails = audit.groupDetails;
                  _searchController.addListener(() {
                    final query = _searchController.text.toLowerCase();
                    setState(() {
                      filteredGroupDetails =
                          audit.groupDetails.where((group) {
                            return group.customerName.toLowerCase().contains(
                              query,
                            );
                          }).toList();
                    });
                  });
                }

                return Stack(
                  children: [
                    Positioned(
                      top: 0,
                      right: 0,
                      left: 0,
                      height: MediaQuery.of(context).size.height * 0.17,
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
                            horizontal: 14,
                            // vertical: 12,
                          ),
                          child: Text(
                            "Today",
                            style: GoogleFonts.poppins(
                              textStyle: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          child: Text(
                            DateFormat('dd MMMM, yyyy').format(DateTime.now()),
                            style: GoogleFonts.poppins(
                              textStyle: TextStyle(
                                fontSize: 12,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 14),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              vertical: 6.0,
                              horizontal: 12.0,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: const BorderRadius.all(
                                Radius.circular(20.0),
                              ),
                            ),
                            child: Row(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Icon(
                                    Icons.search,
                                    color: Colors.grey[500],
                                  ),
                                ),
                                Expanded(
                                  child: TextFormField(
                                    controller: _searchController,
                                    initialValue: null,
                                    decoration: InputDecoration.collapsed(
                                      filled: true,
                                      fillColor: Colors.transparent,
                                      hintText: "Search...",
                                      hintStyle: TextStyle(
                                        color: Colors.grey[500],
                                      ),
                                      hoverColor: Colors.transparent,
                                    ),
                                    onFieldSubmitted: (value) {},
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
                        Expanded(
                          child: ListView.builder(
                            itemCount: filteredGroupDetails.length,
                            itemBuilder: (context, index) {
                              final group = filteredGroupDetails[index];
                              final visitStatus =
                                  group.auditDetails.first.visitStatus;
                              return Card(
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 4,
                                ),
                                elevation: 4,
                                child: ExpansionTile(
                                  title: Text(
                                    group.customerName,
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black,
                                    ),
                                  ),

                                  trailing: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          visitStatus == "0"
                                              ? Colors.blue.shade800
                                              : Colors.green,
                                      foregroundColor: Colors.white,
                                      shape: ContinuousRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                    ),
                                    onPressed: () async {
                                      if (group.auditDetails.first.latitude ==
                                                  '' &&
                                              group
                                                      .auditDetails
                                                      .first
                                                      .longitude ==
                                                  '' ||
                                          group.auditDetails.first.latitude ==
                                                  'Belum disetting' &&
                                              group
                                                      .auditDetails
                                                      .first
                                                      .longitude ==
                                                  'Belum disetting') {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'Titik koordinat belum disetting atau masih kosong',
                                            ),
                                          ),
                                        );
                                      } else {
                                        final lat = double.parse(
                                          group.auditDetails.first.latitude,
                                        );
                                        final lng = double.parse(
                                          group.auditDetails.first.longitude,
                                        );

                                        openGoogleMaps(lat, lng);
                                      }
                                    },
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          "Directions",
                                          style: GoogleFonts.poppins(
                                            textStyle: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 8),
                                        Icon(Icons.arrow_forward_ios_sharp),
                                      ],
                                    ),
                                  ),

                                  subtitle: Text(
                                    "Area: ${group.customerAreaName}",
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      color: Colors.grey[800],
                                    ),
                                  ),
                                  children:
                                      group.auditDetails.map((detail) {
                                        return ListTile(
                                          title: Text(
                                            detail.invoiceCode,
                                            style: GoogleFonts.poppins(
                                              fontSize: 12,
                                              color: Colors.grey[800],
                                            ),
                                          ),
                                          trailing:
                                              (detail.visitStatus == "0" &&
                                                      !checkinButtonShown)
                                                  ? ElevatedButton(
                                                    style: ElevatedButton.styleFrom(
                                                      backgroundColor:
                                                          Colors.red,
                                                      foregroundColor:
                                                          Colors.white,
                                                      shape: ContinuousRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              12,
                                                            ),
                                                      ),
                                                    ),
                                                    onPressed: () async {
                                                      try {
                                                        final location =
                                                            GetLocation();
                                                        final position =
                                                            await location
                                                                .getCurrentLocation();

                                                        final isMockLocation =
                                                            await SafeDevice
                                                                .isMockLocation;
                                                        if (isMockLocation) {
                                                          ScaffoldMessenger.of(
                                                            context,
                                                          ).showSnackBar(
                                                            const SnackBar(
                                                              content: Text(
                                                                "Terdeteksi menggunakan Fake GPS!",
                                                              ),
                                                              backgroundColor:
                                                                  Colors.red,
                                                            ),
                                                          );
                                                          return;
                                                        }

                                                        final prefs =
                                                            await SharedPreferences.getInstance();
                                                        prefs.setDouble(
                                                          'current_lat',
                                                          position.latitude,
                                                        );
                                                        prefs.setDouble(
                                                          'current_long',
                                                          position.longitude,
                                                        );

                                                        print(
                                                          'latitude: ${position.latitude}, longitude: ${position.longitude}',
                                                        );

                                                        await Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                            builder:
                                                                (
                                                                  context,
                                                                ) => AuditDetailView(
                                                                  token:
                                                                      widget
                                                                          .token,
                                                                  cif:
                                                                      detail
                                                                          .cif,
                                                                  idAudit:
                                                                      audit
                                                                          .idAudit,
                                                                ),
                                                          ),
                                                        );
                                                      } catch (e) {
                                                        print('Error: $e');
                                                        ScaffoldMessenger.of(
                                                          context,
                                                        ).showSnackBar(
                                                          SnackBar(
                                                            content: Text(
                                                              "Error saat ambil lokasi: $e",
                                                            ),
                                                            backgroundColor:
                                                                Colors.red,
                                                          ),
                                                        );
                                                      }
                                                    },
                                                    child: Row(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: const [
                                                        Text("Checkin"),
                                                        SizedBox(width: 8),
                                                        Icon(
                                                          Icons
                                                              .arrow_forward_ios_sharp,
                                                        ),
                                                      ],
                                                    ),
                                                  )
                                                  : null,
                                          subtitle: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              // Text(
                                              //   "Salesman: ${detail.salesmanName}",
                                              //   style: GoogleFonts.poppins(
                                              //     fontSize: 12,
                                              //     color: Colors.grey[800],
                                              //   ),
                                              // ),
                                              Text(
                                                "Tagihan: ${FormatCurrency.formatCurrency.format(double.tryParse(detail.invoiceValue.toString()) ?? 0)}",
                                                style: GoogleFonts.poppins(
                                                  fontSize: 12,
                                                  color: Colors.grey[800],
                                                ),
                                              ),
                                              Text(
                                                "Sisa: ${FormatCurrency.formatCurrency.format(double.tryParse(detail.paymentRemaining.toString()) ?? 0)}",
                                                style: GoogleFonts.poppins(
                                                  fontSize: 12,
                                                  color: Colors.grey[800],
                                                ),
                                              ),
                                              // Text("Tanggal: ${detail.invoiceDate}"),
                                            ],
                                          ),
                                        );
                                      }).toList(),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              } else if (state is AuditError) {
                return Center(
                  child: Text(
                    "Data perjalanan belum ada, silahkan buat perjalanan!",
                  ),
                );
              }

              return const SizedBox.shrink();
            },
          ),
        ),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.all(16.0),
          child: BlocBuilder<AuditBloc, AuditState>(
            builder: (context, state) {
              if (state is AuditLoading) {
                return Center(child: CircularProgressIndicator());
              } else if (state is AuditLoaded) {
                final audit = state.audit;
                final isAllVisited = audit.groupDetails
                    .expand((group) => group.auditDetails)
                    .every((item) => item.visitStatus == "1");

                return OutlinedButton.icon(
                  icon: const Icon(Icons.done_all_rounded, color: Colors.white),
                  label: Text(
                    "Selesaikan Perjalanan",
                    style: GoogleFonts.poppins(
                      textStyle: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.resolveWith<Color?>((
                      states,
                    ) {
                      if (states.contains(WidgetState.disabled)) {
                        return Colors.grey;
                      }
                      return Colors.blue.shade800;
                    }),
                    foregroundColor: WidgetStateProperty.resolveWith<Color?>((
                      states,
                    ) {
                      if (states.contains(WidgetState.disabled)) {
                        return Colors.grey;
                      }
                      return Colors.white;
                    }),
                    side: WidgetStateProperty.all(
                      const BorderSide(color: Colors.grey),
                    ),
                    shape: WidgetStateProperty.all(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    minimumSize: WidgetStateProperty.all(
                      const Size(double.infinity, 48),
                    ),
                  ),
                  onPressed:
                      isAllVisited
                          ? () async {
                            bool confirm = false;
                            await showDialog<void>(
                              context: context,
                              barrierDismissible: true,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text('Confirm'),
                                  content: const SingleChildScrollView(
                                    child: ListBody(
                                      children: <Widget>[
                                        Text(
                                          'Apakah anda yakin ingin mengakhiri perjalanan ?',
                                        ),
                                      ],
                                    ),
                                  ),
                                  actions: <Widget>[
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.red,
                                      ),
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      child: const Text(
                                        "No",
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),

                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.green,
                                      ),
                                      onPressed: () async {
                                        confirm = true;
                                        Navigator.of(
                                          context,
                                        ).pop(); // Tutup dialog

                                        // Hapus token dan pindah ke login
                                        await AuthRepository().logout();
                                        Navigator.of(
                                          context,
                                        ).pushAndRemoveUntil(
                                          MaterialPageRoute(
                                            builder: (_) => const LoginView(),
                                          ),
                                          (route) => false,
                                        );
                                      },
                                      child: const Text(
                                        "Yes",
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            );

                            if (confirm) {
                              print("Confirmed!");
                            }
                          }
                          : null,
                );
              }

              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
  }
}

void openGoogleMaps(double latitude, double longitude) async {
  if (Platform.isAndroid) {
    final intent = AndroidIntent(
      action: 'action_view',
      data: 'google.navigation:q=$latitude,$longitude&mode=d',
      package: 'com.google.android.apps.maps',
      flags: <int>[Flag.FLAG_ACTIVITY_NEW_TASK],
    );
    await intent.launch();
  } else {
    // fallback untuk iOS atau lainnya
    final url = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=$latitude,$longitude&travelmode=motorcycle',
    );
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      throw 'Tidak bisa membuka Google Maps';
    }
  }
}
