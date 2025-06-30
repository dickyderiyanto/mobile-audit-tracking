class AuditModel {
  final String idAudit;
  final String userName;
  final String visitDate;
  final double totalPaymentRemaining;
  final String statusVisit;
  final List<GroupDetail> groupDetails;

  AuditModel({
    required this.idAudit,
    required this.userName,
    required this.visitDate,
    required this.totalPaymentRemaining,
    required this.statusVisit,
    required this.groupDetails,
  });

  factory AuditModel.fromJson(Map<String, dynamic> json) {
    return AuditModel(
      idAudit: json['id_audit'],
      userName: json['user_name'],
      visitDate: json['visit_date'],
      totalPaymentRemaining: double.parse(json['total_payment_remaining']),
      statusVisit: json['status_visit'],
      groupDetails:
          (json['group_details'] as List)
              .map((e) => GroupDetail.fromJson(e))
              .toList(),
    );
  }
  Map<String, dynamic> toMap() {
    return {
      'id_audit': idAudit,
      'user_name': userName,
      'visit_date': visitDate,
      'total_payment_remaining': totalPaymentRemaining.toString(),
      'status_visit': statusVisit,
    };
  }

  factory AuditModel.fromMap(
    Map<String, dynamic> map,
    List<GroupDetail> groupDetails,
  ) {
    return AuditModel(
      idAudit: map['id_audit'],
      userName: map['user_name'],
      visitDate: map['visit_date'],
      totalPaymentRemaining:
          double.tryParse(map['total_payment_remaining']) ?? 0.0,
      statusVisit: map['status_visit'],
      groupDetails: groupDetails,
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
  Map<String, dynamic> toMap(String auditId) {
    return {
      'audit_id': auditId,
      'customer_name': customerName,
      'customer_area_name': customerAreaName,
      'total_invoice_value': totalInvoiceValue.toString(),
    };
  }

  factory GroupDetail.fromMap(
    Map<String, dynamic> map,
    List<AuditDetail> auditDetails,
  ) {
    return GroupDetail(
      customerName: map['customer_name'],
      customerAreaName: map['customer_area_name'],
      totalInvoiceValue: double.tryParse(map['total_invoice_value']) ?? 0.0,
      auditDetails: auditDetails,
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
  Map<String, dynamic> toMap(String auditId, String customerName) {
    return {
      'audit_id': auditId,
      'customer_name': customerName,
      'invoice_code': invoiceCode,
      'invoice_value': invoiceValue.toString(),
      'payment_remaining': paymentRemaining.toString(),
      'salesman_name': salesmanName,
      'cif': cif,
      'latitude': latitude,
      'longitude': longitude,
      'visit_status': visitStatus,
    };
  }

  factory AuditDetail.fromMap(Map<String, dynamic> map) {
    return AuditDetail(
      invoiceCode: map['invoice_code'],
      invoiceValue: double.tryParse(map['invoice_value']) ?? 0.0,
      paymentRemaining: double.tryParse(map['payment_remaining']) ?? 0.0,
      salesmanName: map['salesman_name'],
      cif: map['cif'],
      latitude: map['latitude'],
      longitude: map['longitude'],
      visitStatus: map['visit_status'],
    );
  }
}
