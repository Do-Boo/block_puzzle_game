import 'package:flame_audio/flame_audio.dart';

class AudioManager {
  Future<void> init() async {
    await FlameAudio.audioCache.loadAll(['place.mp3', 'clear.mp3']);
  }

  void playPlaceSound() {
    FlameAudio.play('place.mp3');
  }

  void playClearLineSound() {
    FlameAudio.play('clear.mp3');
  }

  void dispose() {
    FlameAudio.bgm.dispose();
  }
}
