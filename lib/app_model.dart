import 'package:stream_chat_flutter/stream_chat_flutter.dart';

class AppModel {
  final Channel channel;
  final StreamChatClient chatClient;

  AppModel({
    required this.channel,
    required this.chatClient,
  });

  Future<List<User>> queryUsers() async {
    final usersResponse = await chatClient.queryUsers(
      filter: Filter.equal('banned', false),
    );
    return usersResponse.users;
  }
}
