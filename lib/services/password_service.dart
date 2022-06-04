import 'package:alan_voice/alan_voice.dart';
import 'package:awesome_dialog/awesome_dialog.dart';

class PasswordService {
  void passwordCheck(String password, AwesomeDialog dialog) {
    dialog.dismiss();

    if (password == "open the door") {
      dialog.dismiss();
      AlanVoice.playText("it's correct congratulations");
    } else {
      AlanVoice.playText("but it's incorrect");
    }
  }
}
