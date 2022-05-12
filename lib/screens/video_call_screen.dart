import 'package:flutter/material.dart';
import 'package:flutter_video_chat/signalling.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

import '../constants.dart';
import '../widgets/rounded_button.dart';

class VideoCallScreen extends StatefulWidget {
  static const routName = '/video-call';
  const VideoCallScreen({Key? key}) : super(key: key);

  @override
  State<VideoCallScreen> createState() => _VideoCallScreenState();
}

class _VideoCallScreenState extends State<VideoCallScreen> {
  Signaling signaling = Signaling();
  final RTCVideoRenderer _localRenderer = RTCVideoRenderer();
  final RTCVideoRenderer _remoteRenderer = RTCVideoRenderer();
  String? roomId;
  TextEditingController textEditingController = TextEditingController(text: '');
  Future<void> initialisation() async {
    signaling.openUserMedia(_localRenderer, _remoteRenderer);
    print('cam&mic opened');

    roomId = await signaling.createRoom(_remoteRenderer);

    textEditingController.text = roomId!;
    setState(() {});
    if (roomId != null) {
      print('room created: ' + roomId!);
    }
  }

  @override
  void initState() {
    _localRenderer.initialize();
    _remoteRenderer.initialize();

    signaling.onAddRemoteStream = ((stream) {
      _remoteRenderer.srcObject = stream;
      setState(() {});
    });

    super.initState();

    initialisation();
  }

  @override
  void dispose() {
    _localRenderer.dispose();
    _remoteRenderer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        extendBodyBehindAppBar: true,
        body: Row(
          children: [
            Expanded(child: RTCVideoView(_localRenderer, mirror: true)),
            Expanded(child: RTCVideoView(_remoteRenderer)),
          ],
        ),
        bottomNavigationBar: Container(
          color: kBackgoundColor,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              RoundedButton(
                color: kRedColor,
                iconColor: Colors.white,
                size: 35,
                iconSrc: "assets/icons/Icon Mic.svg",
                press: () {},
              ),
              RoundedButton(
                color: Color(0xFF2C384D),
                iconColor: Colors.white,
                size: 35,
                iconSrc: "assets/icons/call_end.svg",
                press: () {
                  signaling.hangUp(_localRenderer);
                  Navigator.of(context).pushNamed('/');
                },
              ),
              RoundedButton(
                color: Color(0xFF2C384D),
                iconColor: Colors.white,
                size: 35,
                iconSrc: "assets/icons/Icon Volume.svg",
                press: () {},
              ),
            ],
          ),
        ));
  }
}


// class _MyHomePageState extends State<MyHomePage> {
//   Signaling signaling = Signaling();
//   final RTCVideoRenderer _localRenderer = RTCVideoRenderer();
//   final RTCVideoRenderer _remoteRenderer = RTCVideoRenderer();
//   String? roomId;
//   TextEditingController textEditingController = TextEditingController(text: '');

//   @override
//   void initState() async {
//     _localRenderer.initialize();
//     _remoteRenderer.initialize();

//     signaling.onAddRemoteStream = ((stream) {
//       _remoteRenderer.srcObject = stream;
//       setState(() {});
//     });

//     super.initState();

//     roomId = await signaling.createRoom(_remoteRenderer);

//     textEditingController.text = roomId!;
//     setState(() {});
//     print('room created');
//   }

//   @override
//   void dispose() {
//     _localRenderer.dispose();
//     _remoteRenderer.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Welcome to Flutter Explained - WebRTC"),
//       ),
//       body: Column(
//         children: [
//           const SizedBox(height: 8),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               ElevatedButton(
//                 onPressed: () {
//                   signaling.openUserMedia(_localRenderer, _remoteRenderer);
//                 },
//                 child: const Text("Open camera & microphone"),
//               ),
//               const SizedBox(
//                 width: 8,
//               ),
//               ElevatedButton(
//                 onPressed: () async {
//                   roomId = await signaling.createRoom(_remoteRenderer);
//                   textEditingController.text = roomId!;
//                   setState(() {});
//                 },
//                 child: const Text("Create room"),
//               ),
//               const SizedBox(
//                 width: 8,
//               ),
//               ElevatedButton(
//                 onPressed: () {
//                   // Add roomId
//                   signaling.joinRoom(
//                     textEditingController.text,
//                     _remoteRenderer,
//                   );
//                 },
//                 child: const Text("Join room"),
//               ),
//               const SizedBox(
//                 width: 8,
//               ),
//               ElevatedButton(
//                 onPressed: () {
//                   signaling.hangUp(_localRenderer);
//                 },
//                 child: const Text("Hangup"),
//               )
//             ],
//           ),
//           const SizedBox(height: 8),
//           Expanded(
//             child: Padding(
//               padding: const EdgeInsets.all(8.0),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Expanded(child: RTCVideoView(_localRenderer, mirror: true)),
//                   Expanded(child: RTCVideoView(_remoteRenderer)),
//                 ],
//               ),
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 const Text("Join the following Room: "),
//                 Flexible(
//                   child: TextFormField(
//                     controller: textEditingController,
//                   ),
//                 )
//               ],
//             ),
//           ),
//           const SizedBox(height: 8)
//         ],
//       ),
//     );
//   }
// }
