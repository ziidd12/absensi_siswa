class AttendanceScanModel {
  String? status;
  String? message;
  int? poinTerbaru; // Tambahan field poin sesuai respons Laravel

  AttendanceScanModel({this.status, this.message, this.poinTerbaru});

  AttendanceScanModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    // Handle poin_terbaru agar aman jika null atau bertipe lain
    poinTerbaru = json['poin_terbaru'] != null 
        ? int.parse(json['poin_terbaru'].toString()) 
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    data['message'] = message;
    data['poin_terbaru'] = poinTerbaru;
    return data;
  }
}