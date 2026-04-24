import 'package:equatable/equatable.dart';

class ApiDefinition extends Equatable {
  final String apiId;
  final String apiName;
  final String method;
  final String path;
  final int timeoutMs;
  final Map<String, String> headers;

  const ApiDefinition({
    this.apiId = '',
    this.apiName = '',
    this.method = 'POST',
    this.path = '',
    this.timeoutMs = 30000,
    this.headers = const {},
  });

  Map<String, dynamic> toMap() {
    return {
      'apiId': apiId,
      'apiName': apiName,
      'method': method,
      'path': path,
      'timeoutMs': timeoutMs,
      'headers': headers,
    };
  }

  factory ApiDefinition.fromMap(Map<String, dynamic> map) {
    final rawHeaders = map['headers'] as Map<String, dynamic>? ?? {};
    return ApiDefinition(
      apiId: map['apiId'] ?? '',
      apiName: map['apiName'] ?? '',
      method: map['method'] ?? 'POST',
      path: map['path'] ?? '',
      timeoutMs: (map['timeoutMs'] as num?)?.toInt() ?? 30000,
      headers: rawHeaders.map((k, v) => MapEntry(k, v.toString())),
    );
  }

  @override
  List<Object> get props => [apiId, apiName, method, path, timeoutMs];
}
