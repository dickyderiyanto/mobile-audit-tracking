class InvoiceDetailStatusModel {
  final String invoiceCode;
  final String keterangan;

  InvoiceDetailStatusModel({
    required this.invoiceCode,
    required this.keterangan,
  });

  factory InvoiceDetailStatusModel.fromJson(Map<String, dynamic> json) {
    return InvoiceDetailStatusModel(
      invoiceCode: json['invoice_code'],
      keterangan: json['keterangan'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'invoice_code': invoiceCode, 'keterangan': keterangan};
  }
}

class InvoiceStatusModel {
  final String auditId;
  final String cif;
  final String statusInvoice;
  final List<InvoiceDetailStatusModel> invoices;

  InvoiceStatusModel({
    required this.auditId,
    required this.cif,
    required this.statusInvoice,
    required this.invoices,
  });

  factory InvoiceStatusModel.fromJson(Map<String, dynamic> json) {
    return InvoiceStatusModel(
      auditId: json['audit_id'],
      cif: json['cif'],
      statusInvoice: json['status_invoice'],
      invoices:
          (json['invoices'] as List)
              .map((e) => InvoiceDetailStatusModel.fromJson(e))
              .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'audit_id': auditId,
      'cif': cif,
      'status_invoice': statusInvoice,
      'invoices': invoices.map((e) => e.toJson()).toList(),
    };
  }
}
