class ModelResponse {
  ModelResponse({this.error, this.data, this.message});

  final dynamic error;
  final dynamic data;
  final dynamic message;

  Map<String, dynamic> toJson() =>
      {'data': data ?? '', 'error': error ?? '', 'message': message ?? ''};
}
