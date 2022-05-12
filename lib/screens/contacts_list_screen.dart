import 'package:flutter/material.dart';
import 'package:flutter_video_chat/screens/video_call_screen.dart';

import '../size_config.dart';

class ContactsListScreen extends StatelessWidget {
  const ContactsListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contacts'),
      ),
      body: ListView(
        children: <Widget>[
          Card(
            child: ListTile(
              onTap: () => Navigator.of(context).pushNamed(
                VideoCallScreen.routName,
              ),
              title: Text('Doctor'),
            ),
          ),
   
     
        ],
      ),
    );
  }
}
