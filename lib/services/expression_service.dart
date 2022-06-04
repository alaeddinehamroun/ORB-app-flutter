import 'dart:math';

import 'package:alan_voice/alan_voice.dart';
import 'package:flutter_video_chat/data/data.dart';

class ExpressionService {
  void changeExpression(String expression, bool canChangeFace, int i) {
    switch (expression) {
      case "another":
        canChangeFace = true;

        i = Random().nextInt(FACES.length);
        break;

      case "angry":
        canChangeFace = true;

        i = 3;
        break;
      default:
        bool find = false;
        for (int x = 0; x < FACES.length; x++) {
          if (FACES[x].contains(expression)) {
            canChangeFace = true;

            find = true;
            i = x;
            break;
          }
        }
        if (find == false) {
          AlanVoice.activate();
          AlanVoice.playText("Sorry i can not do this expression");
        }
        break;
    }
  }
}
