import 'package:awesome_flutter_chat/app_model.dart';
import 'package:awesome_flutter_chat/create_channel_input.dart';
import 'package:awesome_flutter_chat/user_icon.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';

class AddChannelPage extends StatefulWidget {
  const AddChannelPage({Key? key}) : super(key: key);

  @override
  State<AddChannelPage> createState() => _AddChannelPageState();
}

class _AddChannelPageState extends State<AddChannelPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('new group'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: FutureBuilder<List<User>>(
            future: Provider.of<AppModel>(context).queryUsers(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                final ids =
                    snapshot.data?.map((user) => user.id).toList() ?? [];

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    CreateChannelInputWidget(
                      memberIDs: ids,
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                    const Divider(
                      thickness: 1,
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                    Text('Selected members',
                        style: Theme.of(context).textTheme.headline4),
                    if (snapshot.data != null)
                      Wrap(
                        children: <Widget>[
                          for (final user in snapshot.data!)
                            UserIcon(
                              user: user,
                            )
                        ],
                      ),
                  ],
                );
              } else {
                return Container();
              }
            },
          ),
        ),
      ),
    );
  }
}
