import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'loading_button_child.dart';

class ChannelImageUrlSelector extends StatefulWidget {
  const ChannelImageUrlSelector({Key? key, required this.editingController})
      : super(key: key);

  final TextEditingController editingController;

  @override
  _ChannelImageUrlSelectorState createState() =>
      _ChannelImageUrlSelectorState();
}

class _ChannelImageUrlSelectorState extends State<ChannelImageUrlSelector> {
  String? imageUrl;
  bool _isLoading = false;
  late PersistentBottomSheetController _bottomSheetController;

  void setUrl(String url) async {
    setState(() {
      imageUrl = url;
    });
    Navigator.pop(context);
  }

  void _setLoadingState(bool isLoading) {
    _bottomSheetController.setState?.call(() {
      _isLoading = isLoading;
    });
  }

  final _formKey = GlobalKey<FormState>();
  bool _isBottomSheetOpen = false;

  @override
  Widget build(BuildContext context) {
    final showImage = imageUrl != null;
    return Row(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: GestureDetector(
            onTap: () {
              if (_isBottomSheetOpen) {
                _bottomSheetController.close();
              } else {
                _bottomSheetController = showBottomSheet(
                  context: context,
                  builder: (context) => _bottomSheetWidget(),
                  backgroundColor: Colors.transparent,
                );
              }
              _isBottomSheetOpen = !_isBottomSheetOpen;
            },
            child: CircleAvatar(
              radius: 50,
              backgroundColor: Colors.blueGrey,
              backgroundImage: showImage ? NetworkImage(imageUrl ?? '') : null,
              child: showImage
                  ? null
                  : const Icon(
                      Icons.portrait,
                      size: 50,
                    ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _bottomSheetWidget() {
    return Container(
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.all(Radius.circular(15)),
          boxShadow: [
            BoxShadow(blurRadius: 10, color: Colors.grey[300]!, spreadRadius: 5)
          ]),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: TextFormField(
                  controller: widget.editingController,
                  decoration: const InputDecoration.collapsed(
                    hintText: 'Image URL',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a URL';
                    } else {
                      final isValidURL = Uri.parse(value).isAbsolute;
                      if (!isValidURL) {
                        return 'Not a valid URL';
                      }
                    }
                  },
                ),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextButton(
                  onPressed: () async {
                    _bottomSheetController.close();
                    _isBottomSheetOpen = false;
                  },
                  child: const Text('Close'),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState != null) {
                      if (!_formKey.currentState!.validate()) {
                        final url = widget.editingController.value.text;
                        _setLoadingState(true);
                        if (await isValidImageUrl(url)) {
                          setUrl(url);
                        }
                        _setLoadingState(false);
                      }
                    }
                  },
                  child: LoadingButtonChild(
                    title: 'Set Picture',
                    isLoading: _isLoading,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<bool> isValidImageUrl(String url) async {
    try {
      final response = await http.head(Uri.parse(url));
      if (response.statusCode == 200) {
        final contentType = response.headers['content-type'];
        if (contentType == 'image/jpeg' || contentType == 'image/png') {
          return true;
        }
      }
      return false;
    } on Exception catch (e) {
      print(e);
      return false;
    }
  }
}
