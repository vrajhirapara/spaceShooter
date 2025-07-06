import 'dart:async';
import 'dart:math';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:space_shooter/components/explosion.dart';
import 'package:space_shooter/components/player.dart';
import 'package:space_shooter/my_game.dart';

class Enemy extends SpriteComponent with HasGameReference<MyGame>, CollisionCallbacks {
  final Random _random = Random();
  static const double _maxSize = 120;
  late Vector2 _velocity;
  final double _maxHealth = 1;
  late double _health;


  Enemy({required super.position, double size = 80}) : super(size: Vector2.all(size), anchor: Anchor.center, priority: -1) {
    _velocity = _generateVelocity();
    _health = size / _maxSize * _maxHealth;

    add(CircleHitbox());
  }

  @override
  FutureOr<void> onLoad() async {
    final int imageNum = _random.nextInt(3) + 1;
    sprite = await game.loadSprite('enemy.png');
    return super.onLoad();
  }

  @override
  void update(double dt) {
    ///enemy speed
    final cappedSpeedMultiplier = game.enemySpeedMultiplier.clamp(1.0, 3.0);

    position.y += 150 * cappedSpeedMultiplier * dt;



    /// for strength down enemy
    // position += _velocity * dt; /// for random down enemy

    if (position.y > game.size.y + size.y / 2) {

      removeFromParent();

      // _createExplosion();

    }

    super.update(dt);
  }

  Vector2 _generateVelocity() {

    final double forceFactor = _maxSize / size.x;

    return Vector2(_random.nextDouble() * 120 - 60, 100 + _random.nextDouble() * 50) * forceFactor;

  }

  // void _createExplosion() {
  //   final Explosion explosion = Explosion(position: position.clone(), explosionSize: size.x, explosionType: ExplosionType.dust);
  //   game.add(explosion);
  // }

  void takeDamage(){
    game.audioManager.playSound('enemy_destroy');
    _health--;

    if(_health <= 0){
      game.incrementScore(1);
      removeFromParent();
      _createExplosion();
    }
  }

  void _createExplosion() {
    final Explosion explosion = Explosion(position: position.clone(), explosionSize: size.x, explosionType: ExplosionType.dust);
    game.add(explosion);
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollision(intersectionPoints, other);
    if (other is Player) {
      removeFromParent();
      // other.removeFromParent();
      other.takeDamage();
    }
  }

}
