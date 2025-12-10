class BrandDeal {
  final String id;
  final String userId;
  final String brandName;
  final String? contactEmail;
  final String status;
  final double value;
  final List<dynamic> deliverables;
  final DateTime? expectedCloseDate;
  final DateTime createdAt;

  BrandDeal({
    required this.id,
    required this.userId,
    required this.brandName,
    this.contactEmail,
    required this.status,
    required this.value,
    required this.deliverables,
    this.expectedCloseDate,
    required this.createdAt,
  });

  factory BrandDeal.fromJson(Map<String, dynamic> json) {
    return BrandDeal(
      id: json['id'],
      userId: json['user_id'],
      brandName: json['brand_name'],
      contactEmail: json['contact_email'],
      status: json['status'] ?? 'prospecting',
      value: (json['value'] as num?)?.toDouble() ?? 0.0,
      deliverables: json['deliverables'] ?? [],
      expectedCloseDate: json['expected_close_date'] != null
          ? DateTime.parse(json['expected_close_date'])
          : null,
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'brand_name': brandName,
      'contact_email': contactEmail,
      'status': status,
      'value': value,
      'deliverables': deliverables,
      'expected_close_date': expectedCloseDate?.toIso8601String(),
    };
  }
}
