import 'dart:async';
import 'dart:math';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:space_shooter/components/enemy.dart';
import 'package:space_shooter/my_game.dart';

class Bullet extends SpriteComponent with HasGameReference<MyGame> , CollisionCallbacks{
  Bullet({required super.position, super.angle = 0.0}) : super(anchor: Anchor.center, priority: -1);


  @override
  FutureOr<void> onLoad() async{
    sprite = await game.loadSprite('Bullet_2.png');

    size *= 0.25;
    add(RectangleHitbox());
    return super.onLoad();
  }

  @override
  void update(double dt) {
    // position.y -= 500 * dt;
    position -= Vector2(sin(angle), cos(angle)) * 500 * dt;
    if(position.y < -size.y / 2 ){
    removeFromParent();
    }

    super.update(dt);
  }


  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollision(intersectionPoints, other);
    if (other is Enemy) {
      removeFromParent();
      // other.removeFromParent();
      other.takeDamage();
    }
  }

}
