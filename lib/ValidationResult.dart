class ValidationResult {
  final List<FieldErrorDetail> fieldErrors;
  final List<ObjectErrorDetail> globalErrors;

  ValidationResult({required this.fieldErrors, required this.globalErrors});

  factory ValidationResult.fromJson(Map<String, dynamic> json) {
    var fieldErrorsJson = json['fieldErrors'] as List;
    var globalErrorsJson = json['globalErrors'] as List;
    List<FieldErrorDetail> fieldErrorsList = fieldErrorsJson
        .map((error) => FieldErrorDetail.fromJson(error))
        .toList();
    List<ObjectErrorDetail> globalErrorsList = globalErrorsJson
        .map((error) => ObjectErrorDetail.fromJson(error))
        .toList();

    return ValidationResult(
        fieldErrors: fieldErrorsList, globalErrors: globalErrorsList);
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

  static String? errValidate(List<FieldErrorDetail> errors, String errField) {
    if (errors.any((error) => error.field == errField)) {
      if(errors.where((error) => error.field == errField).any((error) => error.codes.contains("NotBlank"))){
        return errors.where((error) => error.field == errField).firstWhere((error) => error.codes.contains("NotBlank")).message;
      }else{
        return errors.firstWhere((error) => error.field == errField).message;
      }

    } else {
      return null;
    }
  }
}

class ObjectErrorDetail {
  final String objectName;
  final List<String> codes;
  final String message;

  ObjectErrorDetail({
    required this.objectName,
    required this.codes,
    required this.message,
  });

  factory ObjectErrorDetail.fromJson(Map<String, dynamic> json) {
    var codesJson = json['codes'] as List;
    List<String> codesList = List<String>.from(codesJson);

    return ObjectErrorDetail(
      objectName: json['objectName'],
      codes: codesList,
      message: json['message'],
    );
  }
}
