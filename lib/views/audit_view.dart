// ignore_for_file: depend_on_referenced_packages

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/audit/audit_bloc.dart';
import '../repository/audit_repository.dart';

class AuditView extends StatefulWidget {
  final String token; // Token dari login

  const AuditView({super.key, required this.token});

  @override
  State<AuditView> createState() => _AuditViewState();
}

class _AuditViewState extends State<AuditView> {
  late AuditBloc _auditBloc;

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
      create: (_) => _auditBloc,
      child: Scaffold(
        // appBar: AppBar(title: const Text("Audit Report")),
        body: SafeArea(
          child: BlocBuilder<AuditBloc, AuditState>(
            builder: (context, state) {
              if (state is AuditLoading) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is AuditLoaded) {
                final audit = state.audit;

                return Stack(
                  children: [
                    Positioned(
                      top: 0,
                      right: 0,
                      left: 0,
                      height: MediaQuery.of(context).size.height * 0.20,
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
                          child: Text(
                            "Today",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Text(
                            "11 June, 2025",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white,
                              // fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        SizedBox(height: 10),
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
                            itemCount: audit.groupDetails.length,
                            itemBuilder: (context, index) {
                              final group = audit.groupDetails[index];

                              return Card(
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                elevation: 4,
                                child: ExpansionTile(
                                  title: Text(
                                    group.customerName,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  trailing: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blue.shade800,
                                      foregroundColor: Colors.white,
                                      shape: ContinuousRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                          64.0,
                                        ),
                                      ),
                                    ),
                                    onPressed: () {},
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: const [
                                        Text("Directions"),
                                        SizedBox(width: 8),
                                        Icon(Icons.arrow_forward_ios_sharp),
                                      ],
                                    ),
                                  ),

                                  subtitle: Text(
                                    "Area: ${group.customerAreaName}",
                                  ),
                                  children:
                                      group.auditDetails.map((detail) {
                                        return ListTile(
                                          title: Text(detail.invoiceCode),
                                          subtitle: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                "Salesman: ${detail.salesmanName}",
                                              ),
                                              Text(
                                                "Tagihan: Rp. ${detail.invoiceValue.toStringAsFixed(0)}",
                                              ),
                                              Text(
                                                "Sisa: Rp. ${detail.paymentRemaining.toStringAsFixed(0)}",
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
      ),
    );
  }
}
