// ignore_for_file: public_member_api_docs, sort_constructors_first
class InvoiceStatusModel {
  final String auditId;
  final String cif;
  final List<String> invoiceCodes;
  final String statusInvoice;

  InvoiceStatusModel({
    required this.auditId,
    required this.cif,
    required this.invoiceCodes,
    required this.statusInvoice,
  });

  //json decode
  factory InvoiceStatusModel.fromJson(Map<String, dynamic> json) {
    return InvoiceStatusModel(
      auditId: json['audit_id'],
      cif: json['cif'],
      invoiceCodes: List<String>.from(json['invoice_code']),
      statusInvoice: json['status_invoice'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'audit_id': auditId,
      'cif': cif,
      'invoice_code': invoiceCodes,
      'status_invoice': statusInvoice,
    };
  }
}
