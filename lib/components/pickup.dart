
import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/animation.dart';
import 'package:space_shooter/my_game.dart';

enum PickupType { bomb, bullet, /*shield*/ }

class Pickup extends SpriteComponent with HasGameReference<MyGame> {
  final PickupType pickupType;

  Pickup({required super.position, required this.pickupType}) :
        super(
               size: Vector2.all(100), /// pickups Height
                anchor: Anchor.center
      );

  @override
  FutureOr<void> onLoad() async{

    sprite = await game.loadSprite('${pickupType.name}_pickup.png');

    add(CircleHitbox());

    final  ScaleEffect pulastingEffect = ScaleEffect.to(Vector2.all(0.9), EffectController(
      duration: 0.6,
      alternate: true,
      infinite: true,curve: Curves.easeInOut
    ));
    add(pulastingEffect);

    return super.onLoad();
  }

  @override
  void update(double dt) {
    super.update(dt);
    position.y += 300 * dt;

    if(position.y > game.size.y + size.y / 2){
      removeFromParent();
    }
  }
}

