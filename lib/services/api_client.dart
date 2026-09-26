import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:employee_management_app/constants/api_constant.dart';
import 'package:http/http.dart' as http;


/// Typed error so screens can show a real message.
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  const ApiException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

/// Thin wrapper over http. The [client] is injectable so tests
/// can pass a MockClient instead of hitting the network.
class ApiClient {
  final http.Client _client;

  ApiClient({http.Client? client}) : _client = client ?? http.Client();

  static const _headers = {'Content-Type': 'application/json'};

  Uri _uri(String path) => Uri.parse('${ApiConstants.baseUrl}$path');

  Future<dynamic> get(String path) =>
      _send(() => _client.get(_uri(path), headers: _headers));

  Future<dynamic> post(String path, Map<String, dynamic> body) => _send(
      () => _client.post(_uri(path), headers: _headers, body: jsonEncode(body)));

  Future<dynamic> put(String path, Map<String, dynamic> body) => _send(
      () => _client.put(_uri(path), headers: _headers, body: jsonEncode(body)));

  Future<dynamic> delete(String path) =>
      _send(() => _client.delete(_uri(path), headers: _headers));

  Future<dynamic> _send(Future<http.Response> Function() request) async {
    try {
      final res = await request().timeout(ApiConstants.timeout);

      if (res.statusCode >= 200 && res.statusCode < 300) {
        return res.body.isEmpty ? null : jsonDecode(res.body);
      }
      if (res.statusCode == 404) {
        throw const ApiException('Employee not found.', statusCode: 404);
      }
      throw ApiException('Request failed (${res.statusCode}).',
          statusCode: res.statusCode);
    } on SocketException {
      throw const ApiException('No internet connection.');
    } on TimeoutException {
      throw const ApiException('Request timed out. Please try again.');
    } on FormatException {
      throw const ApiException('Unexpected response from server.');
    }
  }
}