import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/config.dart';
import '../models/message_model.dart';

class ApiService {
  Future<void> reset() async {
    final res = await http.post(
      Uri.parse('$kBaseUrl/reset'),
      headers: {'Authorization': 'Bearer $kToken'},
    );
    if (res.statusCode != 200) {
      throw Exception('Reset failed: ${res.statusCode} ${res.body}');
    }
  }

  Future<List<MessageModel>> fetchMessages() async {
    final res = await http.get(
      Uri.parse('$kBaseUrl/messages'),
      headers: {'Authorization': 'Bearer $kToken'},
    );
    if (res.statusCode != 200) {
      throw Exception('fetchMessages failed: ${res.statusCode} ${res.body}');
    }
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    return (data['messages'] as List)
        .map((e) => MessageModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
