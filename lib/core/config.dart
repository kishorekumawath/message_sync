import 'package:flutter_dotenv/flutter_dotenv.dart';

String get kToken => dotenv.env['TOKEN']!;
String get kBaseUrl => dotenv.env['BASE_URL']!;
String get kWsUrl =>
    'wss://${Uri.parse(kBaseUrl).host}/ws?token=$kToken';
const int kTotalMessages = 30;
