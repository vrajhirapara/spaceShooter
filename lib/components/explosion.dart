import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:space_shooter/my_game.dart';

enum ExplosionType { dust, smoke, fire }

class Explosion extends PositionComponent with HasGameReference<MyGame> {
  final ExplosionType explosionType;
  final double explosionSize;
  final Random _random = Random();

  Explosion({required super.position, required this.explosionSize, required this.explosionType});

@override
  FutureOr<void> onLoad() {
  _createFlash();  
  add(RemoveEffect(delay: 1.0));
  return super.onLoad();
  }

  void _createFlash(){
    final CircleComponent flash = CircleComponent(
      radius:  explosionSize * 0.6,
      paint: Paint()..color = const Color.fromRGBO(255, 255, 255, 1.0),
      anchor: Anchor.center
    );
  }
}
