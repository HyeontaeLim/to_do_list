class ValidationResult{
  final List<FieldErrorDetail> errors;

  ValidationResult({
    required this.errors
});

  factory ValidationResult.fromJson(Map<String,dynamic> json) {
    var errorsJson = json['errors'] as List;
    List<FieldErrorDetail> errorsList = errorsJson.map((error) => FieldErrorDetail.fromJson(error)).toList();

    return ValidationResult(
    errors: errorsList,
  );
  }
}

class FieldErrorDetail {
  final String field;
  final List<String> codes;
  final Object? rejectedValue; // Object 타입이므로 nullable로 설정
  final String message;

  FieldErrorDetail({
    required this.field,
    required this.codes,
    required this.rejectedValue,
    required this.message,
  });

  factory FieldErrorDetail.fromJson(Map<String, dynamic> json) {
    var codesJson = json['codes'] as List;
    List<String> codesList = List<String>.from(codesJson);

    return FieldErrorDetail(
      field: json['field'],
      codes: codesList,
      rejectedValue: json['rejectedValue'],
      message: json['message'],
    );
  }
}