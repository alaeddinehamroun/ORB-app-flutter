import 'package:alan_voice/alan_voice.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_video_chat/data/data.dart';
import 'package:flutter_video_chat/screens/video_call_screen.dart';
import 'package:flutter_video_chat/services/expression_service.dart';
import 'package:flutter_video_chat/services/order_service.dart';
import 'package:flutter_video_chat/services/password_service.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:progress_state_button/progress_button.dart' as pb;
import 'dart:math';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:roslibdart/roslibdart.dart';
import 'package:flutter_ripple/flutter_ripple.dart';
import 'package:url_launcher/url_launcher.dart' as url;

import '../services/music_service.dart';
import '../services/patient_service.dart';

class OrbScreen extends StatelessWidget {
  const OrbScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ORB ALPHA',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with WidgetsBindingObserver {

  late Ros ros;
  late Topic display;
  late Topic order;
  late Topic name;
  late Topic recognition;
  late Topic facesTopic;
  late Topic talk;
  bool param = false;
  String devicesIP = "192.168.124.235";
  bool arja3 = false;
  bool startedTV = false;
  bool startedNotif = false;

  bool begin = true;
  bool canSay = false;
  double height = 0;
  double width = 0;
  bool canChangeFace = false;
  bool espActive = false;
  _MyHomePageState() {
    AlanVoice.addButton(
      "4db70e7a40290c970f6bf03ce5bc092b2e956eca572e1d8b807a3e2338fdd0dc/prod",
    );
    AlanVoice.setLogLevel("all");
  }

  pb.ButtonState stateOnlyText = pb.ButtonState.idle;
  pb.ButtonState stateOnlyCustomIndicatorText = pb.ButtonState.idle;
  pb.ButtonState stateTextWithIcon = pb.ButtonState.idle;
  pb.ButtonState stateTextWithIconMinWidthState = pb.ButtonState.idle;
  int compteurPutMeDown = 0;
  int compteurBehind = 0;
  int compteurFront = 0;
  bool eleminateOne = true;
  int i = 6;
  int screen = 1;
  int level = 0;
  int times = 0;
  int statecap = 11;
  bool password = true;
  String rosUrl = 'ws://192.168.184.112:9090';
  String cameraIP = "192.168.233.233";
  bool tvState = false;
  var dialog;
  String CurrentFace = "unknown";
  late int ir1, ir2, ir3, sharp1, sharp2, gyrox, gyroy, gyroz;

  String CurrentTrack = MUSIC[0];

  PatientService ps = PatientService();
  OrderService orderService = OrderService();

  void active() {
    if (AlanVoice.isActive() == false) {
      AlanVoice.activate();
    }
    AlanVoice.activate();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        ps.toggleOnlieStatus(true);
        active();

        break;
      case AppLifecycleState.inactive:
        ps.toggleOnlieStatus(false);

        // print("app in inactive");
        break;
      case AppLifecycleState.paused:
        // print("app in paused");
        break;

      case AppLifecycleState.detached:
        ps.toggleOnlieStatus(false);

        // TODO: Handle this case.
        break;
    }
  }

  void checkIR(double code) {
    if (code == statecap) {
      switch (statecap) {
        case 11:
          statecap = 101;
          break;
        case 101:
          statecap = 110;
          break;
        case 110:
          statecap = 11;
          times = times + 1;
          break;
      }
    } else if (code == 11 && statecap == 101) {
      times = times;
    } else if (code == 101 && statecap == 110) {
      times = times;
    } else if (code == 110 && statecap == 11) {
      times = times;
    } else if (code != 111) {
      statecap = 11;
      times = 0;
    }
    if (times == 3) {
      times = 0;

      active();
      setState(() {
        i = 20;
        orderService.publishOrder(110, order);
      });
      AlanVoice.playText("yayyy this is very relaxing");
      arja3 = true;
    }
  }

  Future<void> call(int phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber.toString(),
    );
    await url.launchUrl(launchUri);
  }

  void checkSharp(double front, double back) {
    if (front.toInt() > 11) {
      compteurFront++;
      if (compteurFront > 50) {
        active();
        AlanVoice.playText("i'm falling from front");
        compteurFront = 0;
      }
    }
  }

  void checkGyro(double x, double y, double z) {
    if (x.toInt() > 60 || x.toInt() < -60) {
      compteurPutMeDown++;
      if (compteurPutMeDown > 200) {
        setState(() {
          i = 0;
        });
        active();
        AlanVoice.playText("Hey put me down");
        compteurPutMeDown = 0;
      }
    }
  }

  Future<void> talkSub(Map<String, dynamic> msg) async {
    String toSay = msg["data"];
    active();
    AlanVoice.playText(toSay);
  }

  Future<void> facesSub(Map<String, dynamic> msg) async {
    CurrentFace = msg["data"];
    if (canSay == true && CurrentFace != "unknown") {
      AlanVoice.playText("you are " + CurrentFace + " right?");
      canSay = false;
    }
  }

  void sendDeviceOrder(String device, String order) async {
    String dev = "0";
    if (device.contains("TV")) {
      dev = "0";
    } else if (device.contains("lights")) {
      dev = "1";
    } else {
      dev = "3";
    }

    String url =
        "http://" + devicesIP + "/orb?device=" + dev + "&order=" + order;
    // print(url);
//  print(res.body);
    http.Response res;
    try {
      res = await http.get(Uri.parse(url));
      if (espActive == false) {
        setState(() {
          espActive = true;
        });
      }
    } catch (e) {
      // ps.toggleDevice(device, false);
      AlanVoice.activate();
      AlanVoice.playText(
          "I can not do that.Please check the ip address of your the ESP");
      setState(() {
        espActive = false;
      });
    }
  }

  Future<void> subscribeHandler(Map<String, dynamic> msg) async {
    // var sensors = json.encode(msg);

    double code = msg["ixx"] * 100 + msg["ixy"] * 10 + msg["ixz"];
    ir1 = msg["ixx"].toInt();
    ir2 = msg["ixy"].toInt();
    ir3 = msg["ixz"].toInt();
    sharp1 = msg["iyy"].toInt();
    sharp2 = msg["iyz"].toInt();
    gyrox = msg["com"]["x"].toInt();
    gyroy = msg["com"]["y"].toInt();
    gyroz = msg["com"]["z"].toInt();
    // print(code.toString());

    checkIR(code);
    checkSharp(msg["iyy"], msg["iyz"]);
    // checkGyro(msg["com"]["x"], msg["com"]["y"], msg["com"]["z"]);
  }

  _handleCommand(Map<String, dynamic> response) {
    if (eleminateOne == true) {
      eleminateOne = false;
    } else {
      eleminateOne = true;
      if (response["command"] == "password") {
        String password = response["password"];
        PasswordService passwordService = PasswordService();
        passwordService.passwordCheck(password, dialog);
      } else if (response["command"] == "order") {
        String ord = response["order"].toString();
        orderService.move(ord, order);
      } else if (response["command"] == "sensors") {
        if (response["sensors"].toString() == "the first laser") {
          active();
          AlanVoice.playText(ir1.toInt().toString());
        } else if (response["sensors"].toString() == "the second laser") {
          active();

          AlanVoice.playText(ir2.toInt().toString());
        } else if (response["sensors"].toString() == "the third laser") {
          active();

          AlanVoice.playText(ir3.toInt().toString());
        } else if (response["sensors"].toString() == "the first Sharp") {
          active();

          AlanVoice.playText(sharp1.toInt().toString());
        } else if (response["sensors"].toString() == "the second Sharp") {
          active();

          AlanVoice.playText(sharp2.toInt().toString());
        } else if (response["sensors"].toString() == "the gyro") {
          active();
          // AlanVoice.playText("gyrooo yes");
          String ch = "on x axis we have " +
              gyrox.toInt().toString() +
              "on y axis we have " +
              gyroy.toInt().toString() +
              "and on z axis we have " +
              gyroz.toInt().toString();
          AlanVoice.playText(ch.toString());
        } else {
          active();

          AlanVoice.playText("please select a sensor");
        }
      } else if (response["command"] == "saveFace") {
        publishName(response["Face"]);
      } else if (response["command"] == "removeFace") {
        publishName("remove_" + response["Face"]);
      } else if (response["command"] == "recognition") {
        if (response["recognition"] == "start") {
          canSay = true;
        } else if (response["recognition"] == "stop") {
          CurrentFace = "unknown";
        }
        publishRecognition(response["recognition"]);
      } else if (response["command"] == "music") {
        MusicService musicService = MusicService();

        if (response["music"] == "play") {
          CurrentTrack =
              "assets/music/" + MUSIC[Random().nextInt(MUSIC.length)];
          musicService.playLocal(CurrentTrack);
        } else if (response["music"] == "resume") {
          musicService.playLocal(CurrentTrack);
        } else if (response["music"] == "pause") {
          musicService.pausePlayer();
        }
      } else if (response["command"] == "settings") {
        if (response["settings"] == "show") {
          setState(() {
            param = true;
          });
        } else if (response["settings"] == "hide") {
          setState(() {
            param = false;
          });
        }
      } else if (response["command"] == "ros") {
        if (response["ros"] == "connect") {
          initializeTopics();
          setState(() {});
        } else if (response["ros"] == "disconnect") {
          ros.close();
          setState(() {});
        }
      } else if (response["command"] == "rosIP") {
        List<String> x;
        x = response["rosIP"].toString().split('/');

        rosUrl = "ws://" +
            x[0].trim() +
            "." +
            x[1].trim() +
            "." +
            x[2].trim() +
            "." +
            x[3].trim() +
            ":9090";
        initializeTopics();
        setState(() {});
      } else if (response["command"] == "devicesIP") {
        List<String> x;
        x = response["IP"].toString().split('/');
        print(x);

        devicesIP = x[0].trim() +
            "." +
            x[1].trim() +
            "." +
            x[2].trim() +
            "." +
            x[3].trim();
        setState(() {});
      } else if (response["command"] == "deviceOrder") {
        String device;
        device = response["device"].toString();
        print("device number: " + device.toString());
        String order = "";
        order = response["order"].toString();
        print("order: " + order.toString());
        sendDeviceOrder(device, order);
        setState(() {});
      } else if (response["command"] == "expression") {
        String expression = response["expression"];
        ExpressionService expressionService = ExpressionService();
        expressionService.changeExpression(expression, canChangeFace, i);

        setState(() {});
      } else if (response["command"] == "servo") {
        int degree = 90;
        degree = int.parse(response["command"]);
        orderService.publishOrder(degree, order);
      } else if (response["command"] == "call") {
        int number = 90;
        number = int.parse(response["number"]);
        print(number);
        call(number);
        print(number);
      } else if (response["command"] == "notification") {
        print(response["notification"].toString());
        ps.sendNotification('from orb', response["notification"].toString());
      } else if (response["command"] == "video") {
        print('video');
        //Navigator.pushNamed(context, '/video-call');
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => VideoCallScreen()));
      }
    }
  }

  @override
  void initState() {
    initializeTopics();
    AlanVoice.callbacks.add((command) => _handleCommand(command.data));
    AlanVoice.onButtonState.add((event) {
      if (event.name.toString() == "REPLY") {
        canChangeFace = false;
        setState(() {
          i = 20;
        });
      } else {
        if (canChangeFace == false) {
          setState(() {
            i = 6;
          });
        }
        if (arja3 == true) {
          arja3 = true;
          orderService.publishOrder(90, order);
        }
      }
    });
    super.initState();

    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AlanVoice.activate();
      AlanVoice.playText("Please say your password");
      ps.toggleOnlieStatus(true);
      //dialog.show();
    });
    final docRef = FirebaseFirestore.instance
        .collection("patients")
        .doc(PatientService.userId);
    docRef.snapshots().listen(
      (event) {
        if (startedTV == true) {
          bool tv = (event.data()!["devices"]["tv"]);

          if (tv == true) {
            if (tvState == true) {
              AlanVoice.activate();
              AlanVoice.playText("the TV is already on");
            } else {
              AlanVoice.activate();
              AlanVoice.playText("i am activating the tv");
            }
            sendDeviceOrder("TV", "on");
            tvState = true;
          } else if (tv == false) {
            if (tvState == false) {
              AlanVoice.activate();
              AlanVoice.playText("the TV is already off");
            } else {
              AlanVoice.activate();
              AlanVoice.playText("i am shutting down the tv");
            }

            sendDeviceOrder("TV", "off");
            tvState = false;
          }
        } else {
          startedTV = true;
        }
      },
      onError: (error) => print("Listen failed: $error"),
    );

    final notfRef = FirebaseFirestore.instance
        .collection("patients")
        .doc(PatientService.userId)
        .collection('notifications')
        .orderBy("date", descending: true)
        .limit(1);
    notfRef.snapshots().listen((event) {
      if (startedNotif == true) {
        final notif = event.docs[0].data()["text"];
        if (event.docs[0].data()["type"] != 'from orb') {
          AlanVoice.activate();
          AlanVoice.playText("you have a message. It is " + notif);
        }
      } else {
        startedNotif = true;
      }
    });
  }

  @override
  void dispose() {
    print('dispose');
    ps.toggleOnlieStatus(false);
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> initializeTopics() async {
    ros = Ros(url: rosUrl);
    display = Topic(
        ros: ros,
        name: '/sensors',
        type: "geometry_msgs/Inertia",
        reconnectOnClose: true,
        queueLength: 1000,
        queueSize: 1000);
    order = Topic(
        ros: ros,
        name: '/order',
        type: "std_msgs/Int32",
        reconnectOnClose: true,
        queueLength: 10,
        queueSize: 10);
    name = Topic(
        ros: ros,
        name: '/name',
        type: "std_msgs/String",
        reconnectOnClose: true,
        queueLength: 10,
        queueSize: 10);
    recognition = Topic(
        ros: ros,
        name: '/recognition',
        type: "std_msgs/String",
        reconnectOnClose: true,
        queueLength: 10,
        queueSize: 10);
    facesTopic = Topic(
        ros: ros,
        name: '/faces',
        type: "std_msgs/String",
        reconnectOnClose: true,
        queueLength: 10,
        queueSize: 10);
    talk = Topic(
        ros: ros,
        name: '/talk',
        type: "std_msgs/String",
        reconnectOnClose: true,
        queueLength: 10,
        queueSize: 10);
    ros.connect();
    await name.advertise();
    await recognition.advertise();
    await order.advertise();
    await display.subscribe(subscribeHandler);
    await facesTopic.subscribe(facesSub);
    await talk.subscribe(talkSub);
  }

  void publishName(String n) async {
    var msg = {'data': n};
    await name.publish(msg);
    print('done publihsing face name');
  }

  void publishRecognition(String b) async {
    var msg = {'data': b};
    await recognition.publish(msg);
    print('done publihsing in recognition');
  }

  void _incrementCounter() async {
    AlanVoice.showButton();
    setState(() {
      i = (i + 1) % FACES.length;
    });
  }

  void _decrementCounter() {
    setState(() {
      i = max((i - 1) % FACES.length, 0);
    });
    canSay = true;
  }

  @override
  Widget build(BuildContext context) {
    // dialog = AwesomeDialog(
    //   context: context,
    //   dialogType: DialogType.ERROR,
    //   borderSide: const BorderSide(color: Colors.red, width: 5),
    //   buttonsBorderRadius: const BorderRadius.all(Radius.circular(10)),
    //   animType: AnimType.SCALE,
    //   title: 'Authentification',
    //   desc: 'Voice Authentification',
    //   btnOk: Container(),
    //   dialogBackgroundColor: Colors.white,
    //   dismissOnBackKeyPress: false,
    //   dismissOnTouchOutside: false,
    //   body: Center(
    //       child: Column(children: [
    //     const Text(
    //       "Please Say your Secret Word :)",
    //       style: TextStyle(
    //         fontStyle: FontStyle.italic,
    //         color: Colors.red,
    //         fontWeight: FontWeight.bold,
    //       ),
    //     ),
    //     SizedBox(
    //       child: FlutterRipple(
    //         radius: 70,
    //         child: IconButton(
    //             onPressed: () {
    //               print("pressed");
    //             },
    //             icon: const Icon(Icons.multitrack_audio_rounded)),
    //         rippleColor: const Color.fromARGB(255, 164, 7, 7),
    //         duration: const Duration(milliseconds: 1500),
    //         onTap: () {
    //           //print("hello");
    //         },
    //       ),
    //       width: 200,
    //       height: 200,
    //     )
    //   ])),
    // );
    return Scaffold(
      body: Center(
        child: GestureDetector(
          child: Stack(
            alignment: Alignment.center,
            children: [
              Image.asset(
                FACES[i],
                fit: BoxFit.fill,
                height: double.infinity,
                width: double.infinity,
                alignment: Alignment.center,
              ),
              if (param == true)
                Card(
                    elevation: 50,
                    //margin: EdgeInsets.all(50),
                    color: Colors.grey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "RosBridge IP :" + ros.url,
                            ),
                            Icon(
                              Icons.camera,
                              color: ros.status == Status.connected
                                  ? Colors.green
                                  : Colors.redAccent,
                            ),
                          ],
                        ),
                        TextField(
                          onChanged: (value) {
                            setState(() {
                              rosUrl = rosUrl = "ws://" + value + ":9090";
                              initializeTopics();
                            });
                          },
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "Camera IP :" + cameraIP,
                            ),
                            Icon(
                              Icons.settings,
                              color: ros.status == Status.connected
                                  ? Colors.green
                                  : Colors.redAccent,
                            ),
                          ],
                        ),
                        TextField(onSubmitted: (value) {
                          setState(() {
                            cameraIP = value.trim();
                          });
                        }),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "Devices IP:" + devicesIP,
                            ),
                            Icon(
                              Icons.devices_rounded,
                              color: espActive == true
                                  ? Colors.green
                                  : Colors.redAccent,
                            ),
                          ],
                        ),
                        TextField(
                          onSubmitted: (value) {
                            setState(() {
                              devicesIP = value.trim();
                            });
                          },
                        )
                      ],
                    ))
            ],
          ),
          onTap: _incrementCounter,
          onDoubleTap: _decrementCounter,
          onLongPress: () {
            AlanVoice.hideButton();
          },
        ),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
