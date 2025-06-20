class AuditModel {
  final String idAudit;
  final String userName;
  final String visitDate;
  final double totalPaymentRemaining;
  final List<GroupDetail> groupDetails;

  AuditModel({
    required this.idAudit,
    required this.userName,
    required this.visitDate,
    required this.totalPaymentRemaining,
    required this.groupDetails,
  });

  factory AuditModel.fromJson(Map<String, dynamic> json) {
    return AuditModel(
      idAudit: json['id_audit'],
      userName: json['user_name'],
      visitDate: json['visit_date'],
      totalPaymentRemaining: double.parse(json['total_payment_remaining']),
      groupDetails:
          (json['group_details'] as List)
              .map((e) => GroupDetail.fromJson(e))
              .toList(),
    );
  }
}

class GroupDetail {
  final String customerName;
  final String customerAreaName;
  final double totalInvoiceValue;
  final List<AuditDetail> auditDetails;

  GroupDetail({
    required this.customerName,
    required this.customerAreaName,
    required this.totalInvoiceValue,
    required this.auditDetails,
  });

  factory GroupDetail.fromJson(Map<String, dynamic> json) {
    return GroupDetail(
      customerName: json['customer_name'],
      customerAreaName: json['customer_area_name'],
      totalInvoiceValue: double.parse(json['total_invoice_value']),
      auditDetails:
          (json['audit_details'] as List)
              .map((e) => AuditDetail.fromJson(e))
              .toList(),
    );
  }
}

class AuditDetail {
  final String invoiceCode;
  final double invoiceValue;
  final double paymentRemaining;
  final String salesmanName;
  final String cif;
  final String latitude;
  final String longitude;
  final String visitStatus;

  AuditDetail({
    required this.visitStatus,
    required this.invoiceCode,
    required this.invoiceValue,
    required this.paymentRemaining,
    required this.salesmanName,
    required this.cif,
    required this.latitude,
    required this.longitude,
  });

  factory AuditDetail.fromJson(Map<String, dynamic> json) {
    return AuditDetail(
      visitStatus: json['visit_status'] ?? '',
      invoiceCode: json['invoice_code'] ?? '',
      invoiceValue: double.tryParse(json['invoice_value'] ?? '0') ?? 0.0,
      paymentRemaining:
          double.tryParse(json['payment_remaining'] ?? '0') ?? 0.0,
      salesmanName: json['salesman_name'] ?? '',
      cif: json['cif'] ?? '',
      latitude: json['latitude'] ?? '',
      longitude: json['longitude'] ?? '',
    );
  }
}
