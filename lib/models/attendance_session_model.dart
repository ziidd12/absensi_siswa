class AttendanceSessionModel {
  String? status;
  String? message;
  String? tokenQr;

  AttendanceSessionModel({this.status, this.message, this.tokenQr});

  AttendanceSessionModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    tokenQr = json['token_qr'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    data['message'] = message;
    data['token_qr'] = tokenQr;
    return data;
  }
}