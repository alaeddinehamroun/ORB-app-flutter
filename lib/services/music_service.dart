import 'package:just_audio/just_audio.dart';

class MusicService {
  var player = AudioPlayer();

  void playUrl(url) async {
    await player.play();
  }

  void playLocal(String localPath) async {
    await player.play();
  }

  void pausePlayer() async {
    await player.pause();
  }
}
