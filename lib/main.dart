import 'package:awesome_flutter_chat/app_model.dart';
import 'package:awesome_flutter_chat/my_app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_config/flutter_config.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FlutterConfig.loadEnvVariables();

  final apiKey = FlutterConfig.get('API_KEY') as String;
  final userToken = FlutterConfig.get('USER_TOKEN') as String;

  /// Create a new instance of [StreamChatClient] passing the apikey obtained from your
  /// project dashboard.
  final client = StreamChatClient(
    apiKey,
    logLevel: Level.INFO,
  );

  /// Set the current user. In a production scenario, this should be done using
  /// a backend to generate a user token using our server SDK.
  /// Please see the following for more information:
  /// https://getstream.io/chat/docs/flutter-dart/tokens_and_authentication/?language=dart
  await client.connectUser(
    User(id: 'savannah_informatics'),
    userToken,
  );

  final channel = client.channel('messaging', id: 'test');

  /// `.watch()` is used to create and listen to the channel for updates. If the
  /// channel already exists, it will simply listen for new events.
  await channel.watch();

  runApp(
    StreamChannel(
      child: Provider(
        create: (context) => AppModel(
          channel: channel,
          chatClient: client,
        ),
        child: const MyApp(),
      ),
      channel: channel,
    ),
  );
}
