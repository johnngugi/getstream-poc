import 'package:awesome_flutter_chat/app_model.dart';
import 'package:awesome_flutter_chat/channel_list_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';

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

    channel = StreamChannel.of(context).channel;
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
      home: const ChannelListPage(),
    );
  }
}
