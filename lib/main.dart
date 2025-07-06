

import 'package:flame/game.dart';
import 'package:flutter/cupertino.dart';
import 'package:space_shooter/overlays/game_over_overlay.dart';
import 'package:space_shooter/overlays/title_overlay.dart';

import 'my_game.dart';

void main() {
  final MyGame game = MyGame();
  runApp(GameWidget(game: game,
  overlayBuilderMap: {
    'GameOver' : (context, MyGame game) => GameOverOverlay(game: game),
    'Title' : (context, MyGame game) => TitleOverlay(game: game),
  },
    initialActiveOverlays: const ['Title'],
  ));
}