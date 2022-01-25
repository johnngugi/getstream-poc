import 'package:awesome_flutter_chat/app_model.dart';
import 'package:awesome_flutter_chat/channel_list_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';
import 'package:uuid/uuid.dart';

import 'loading_button_child.dart';

class CreateChannelInputWidget extends StatefulWidget {
  const CreateChannelInputWidget({
    Key? key,
    this.memberIDs = const [],
  }) : super(key: key);

  final List<String> memberIDs;

  @override
  _CreateChannelInputWidgetState createState() =>
      _CreateChannelInputWidgetState();
}

class _CreateChannelInputWidgetState extends State<CreateChannelInputWidget> {
  late TextEditingController _textChannelName;

  late StreamChatClient client;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _textChannelName = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    client = Provider.of<AppModel>(context).chatClient;
  }

  @override
  void dispose() {
    _textChannelName.dispose();
    super.dispose();
  }

  void _setStateLoading(bool isLoading) {
    setState(() {
      _isLoading = isLoading;
    });
  }

  Future<bool> _createChannel() async {
    final channelName = _textChannelName.value.text;
    // final imageURL = _textImageUrl.text;

    // if (imageURL.isEmpty) {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     const SnackBar(
    //       content: Text('Please set a channel image'),
    //       behavior: SnackBarBehavior.floating,
    //       shape: RoundedRectangleBorder(
    //         borderRadius: BorderRadius.all(
    //           Radius.circular(20),
    //         ),
    //       ),
    //     ),
    //   );

    //   return false;
    // }

    final channel = client.channel(
      'messaging',
      id: const Uuid().v1(), // generate a random id
      extraData: {
        'name': channelName,
        // 'image': imageURL,
        'members': widget.memberIDs,
      },
    );
    // await channel.create();
    await channel.watch();
    return true;
  }

  void _returnToChat() {
    // Navigator.of(context).pushNamedAndRemoveUntil(
    //     HomePage.route, ModalRoute.withName(AuthPage.route));
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => StreamChannel(
            channel: Provider.of<AppModel>(context).channel,
            child: const ChannelListPage(),
          ),
        ));
  }

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              // ChannelImageUrlSelector(
              //   editingController: _textImageUrl,
              // ),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(8),
                  child: Form(
                    key: _formKey,
                    child: TextFormField(
                      controller: _textChannelName,
                      // onSubmitted: (value) {},
                      decoration: const InputDecoration(
                        hintText: 'Channel name',
                      ),
                      validator: (value) {
                        if (value != null && value.isEmpty) {
                          return 'Please enter a channel name';
                        }
                        return null;
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
          Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState != null) {
                    if (!_formKey.currentState!.validate()) {
                      return;
                    }
                  }

                  _setStateLoading(true);
                  final channelCreated = await _createChannel();
                  _setStateLoading(false);

                  if (channelCreated) {
                    _returnToChat();
                  }
                },
                child: LoadingButtonChild(
                  title: 'Create',
                  isLoading: _isLoading,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
