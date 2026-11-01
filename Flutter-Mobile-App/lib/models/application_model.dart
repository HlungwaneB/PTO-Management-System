class ApplicationModel {
  final String applicationId;
  final String fullName;
  final String phoneNumber;
  final String email;
  final String siteId;
  final String currentStatus;
  final DateTime startDate;
  final DateTime endDate;

  ApplicationModel({
    required this.applicationId,
    required this.fullName,
    required this.phoneNumber,
    required this.email,
    required this.siteId,
    required this.currentStatus,
    required this.startDate,
    required this.endDate,
  });

  // Factory to convert Supabase JSON to Model
  factory ApplicationModel.fromJson(Map<String, dynamic> json) {
    return ApplicationModel(
      applicationId: json['application_id'] ?? '',
      fullName: json['full_name'] ?? '',
      phoneNumber: json['phone_number'] ?? '',
      email: json['email'] ?? '',
      siteId: json['site_id'] ?? '',
      currentStatus: json['current_status'] ?? 'Pending',
      startDate: DateTime.parse(json['start_date']),
      endDate: DateTime.parse(json['end_date']),
    );
  }
}
