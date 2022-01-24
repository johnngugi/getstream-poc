import 'package:awesome_flutter_chat/channel_list_page.dart';
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
    User(id: 'john'),
    // client.devToken('john').toString(),
    userToken,
  );

  final channel = client.channel('messaging', id: 'test');

  /// `.watch()` is used to create and listen to the channel for updates. If the
  /// channel already exists, it will simply listen for new events.
  await channel.watch();

  runApp(
    Provider(
      create: (context) => AppModel(
        channel: channel,
        chatClient: client,
      ),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  /// To initialize this example, an instance of [client] and [channel] is required.
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  /// Instance of [StreamChatClient] we created earlier. This contains information about
  /// our application and connection state.
  late StreamChatClient client;

  /// The channel we'd like to observe and participate.
  late Channel channel;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    channel = Provider.of<AppModel>(context, listen: false).channel;
    client = Provider.of<AppModel>(context, listen: false).chatClient;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      builder: (context, widget) {
        return StreamChat(
          client: client,
          child: widget,
        );
      },
      home: StreamChannel(
        channel: channel,
        child: const ChannelListPage(),
      ),
    );
  }
}

class AppModel {
  final Channel channel;
  final StreamChatClient chatClient;

  AppModel({
    required this.channel,
    required this.chatClient,
  });
}
