import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/services.dart';
import 'package:soundpool/soundpool.dart';

class AudioManager extends Component {
  bool musicEnabled = true;
  bool soundsEnabled = true;


  final List<String> _sounds =  [
    'alarm',
    'alertSound',
    'bgSound',
    'blast',
    'enemy_destroy',
    'shoot_bullet',
    'hit_somthing',
    'player_destroy',
    'click',
    'collect',
    'bomb',
    'collect_bomb',
    'single_bullet',
    'laser',


  ];

  Map<String, int> _soundIds = {};
  final Soundpool _soundpool = Soundpool.fromOptions(
    options: const SoundpoolOptions(maxStreams: 10),
  );

  @override
  FutureOr<void> onLoad() async{

    FlameAudio.bgm.initialize();

    for (String sound in _sounds)  {
      _soundIds[sound] = await rootBundle.load('assets/audio/$sound.mp3').then((ByteData data) {
        return _soundpool.load(data);
      },);
    }

    return super.onLoad();
  }

  void playMusic() {
    if (musicEnabled){
      FlameAudio.bgm.play('music.ogg');
    }
  }

  void playSound(String sound) {
    if(soundsEnabled) {
      _soundpool.play(_soundIds[sound]!);
    }
  }

  void toggleMusic(){
    musicEnabled = !musicEnabled;
    if(musicEnabled){
      playMusic();
    } else {
      FlameAudio.bgm.stop();
    }
  }

  void toggleSound(){
    soundsEnabled = !soundsEnabled;
  }
}