// ignore_for_file: public_member_api_docs, sort_constructors_first
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

class AuditStatusVisit {
  final String idAudit;
  final String idUser;
  final String statusVisit;
  final String updatedBy;

  AuditStatusVisit({
    required this.idAudit,
    required this.idUser,
    required this.statusVisit,
    required this.updatedBy,
  });

  factory AuditStatusVisit.fromJson(Map<String, dynamic> json) {
    return AuditStatusVisit(
      idAudit: json['id_audit'],
      idUser: json['user_id'],
      statusVisit: json['status_visit'],
      updatedBy: json['updated_by'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_audit': idAudit,
      'user_id': idUser,
      'status_visit': statusVisit,
      'updated_by': updatedBy,
    };
  }
}
