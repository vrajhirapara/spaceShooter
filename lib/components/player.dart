import 'dart:async';
import 'dart:math';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/events.dart';
import 'package:flutter/animation.dart';
import 'package:flutter/foundation.dart';
import 'package:space_shooter/components/bullet.dart';
import 'package:space_shooter/components/enemy.dart';
import 'package:space_shooter/components/pickup.dart';
import 'package:space_shooter/components/shield.dart';
import 'package:space_shooter/my_game.dart';
import 'package:vibration/vibration.dart';

import 'explosion.dart';

class Player extends SpriteAnimationComponent with HasGameReference<MyGame>, CollisionCallbacks, TapCallbacks, DragCallbacks {
  bool _isShooting = false;
  final double _fireCooldown = 0.2;
  double _elapsedFireTime = 0.0;
  late double _health = 10;
  bool _isDistroyed = false;
  final Random _random = Random();
  late Timer _explosionTimer;
  late Timer _bulletPowerupTimer;
  Shield? activeShield;

  Player() {
    _explosionTimer = Timer(0.1, onTick: _createRandomExplosion, autoStart: false, repeat: true);

    _bulletPowerupTimer = Timer(5.00, autoStart: false);
  }

  @override
  Future<void> onLoad() async {
    // sprite = await game.loadSprite('Player_1.png');

    animation = await _loadAnimation();

    size *= 0.27;

    add(RectangleHitbox.relative(
        parentSize: size,
        Vector2(0.8, 0.9),
        anchor: Anchor.center
    ));

    return super.onLoad();
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (_isDistroyed) {
      _explosionTimer.update(dt);
      return;
    }

    if(_bulletPowerupTimer.isRunning()){
      _bulletPowerupTimer.update(dt);
    }
    //
    // /// for plan speed
    // position += game.joystick.relativeDelta.normalized() * 500 * dt;
    // _handleScreenBounds();
    //
    // _elapsedFireTime += dt;
    // if (_isShooting && _elapsedFireTime >= _fireCooldown) {
    //   _fireBullet();
    //   _elapsedFireTime = 0.0;
    // }
    //
    // print('plan joystick position == >>>> ${game.joystick.relativeDelta}');
    _elapsedFireTime += dt;
    if (_isShooting && _elapsedFireTime >= _fireCooldown) {
      _fireBullet();
      _elapsedFireTime = 0.0;
    }
  }

  @override
  void onDragStart(DragStartEvent event) {
    _isShooting = true;
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    position += event.localDelta;
  }

  @override
  void onDragEnd(DragEndEvent event) {
    _isShooting = false;
  }

  @override
  void onDragCancel(DragCancelEvent event) {
    _isShooting = false;
  }

  @override
  void onTapDown(TapDownEvent event) {
    _fire2Bullet();
  }
  //
  // @override
  // void onTapUp(TapUpEvent event) {
  //   stopShooting();
  // }



  Future<SpriteAnimation> _loadAnimation() async {
    return SpriteAnimation.spriteList([
      /// boost animation
      await game.loadSprite('img_1.png'),
      await game.loadSprite('img_2.png'),
    ], stepTime: 0.1, loop: true);
  }

  void _handleScreenBounds() {
    final double screenWidth = game.size.x;
    final double screenHeigth = game.size.y;

    /// stop to go plan out of top and bottom screen
    position.y = clampDouble(
      position.y, // x
      position.y / 5, // min
      screenHeigth - size.y / 2, // max
    );

    /// stop to go plan out of left and right screen
    position.x = clampDouble(
      position.x, // x
      position.x / 15, // min
      screenWidth - size.x / 15, // max
    );
  }

  void startShooting() {
    _isShooting = true;
  }

  void stopShooting() {
    _isShooting = false;
  }

  void _fireBullet() {
    game.audioManager.playSound('laser');
    game.add(Bullet(position: position.clone() + Vector2(0, -size.y / 2)));

    if(_bulletPowerupTimer.isRunning()){
      // game.audioManager.playSound('shoot_bullet');
    }
    if(_bulletPowerupTimer.isRunning()){
      game.add(Bullet(position: position.clone() + Vector2(0, -size.y / 2),angle: 15 * degrees2Radians));
      game.add(Bullet(position: position.clone() + Vector2(0, -size.y / 2),angle: -15 * degrees2Radians));
    }

  }

  void _fire2Bullet(){
    game.audioManager.playSound('shoot_bullet');
    game.add(Bullet(position: position.clone() + Vector2(0, -size.y / 2),angle: 7 * degrees2Radians));
    game.add(Bullet(position: position.clone() + Vector2(0, -size.y / 2),angle: -7 * degrees2Radians));
  }

  void _handleDestructoin() async {
    game.audioManager.playSound('player_destroy');
    animation = SpriteAnimation.spriteList([
      await game.loadSprite('game_over.png'),
    ], stepTime: double.infinity);
    add(ColorEffect(const Color.fromRGBO(255, 255, 255, 1.0), EffectController(duration: 1.0),onComplete: () => _explosionTimer.stop(),));
    add(OpacityEffect.fadeOut(EffectController(duration: 3.0)));
    add(RemoveEffect(delay: 1.0, onComplete: game.playerdied));
    _isDistroyed = true;
    _explosionTimer.start();
  }

  void _createRandomExplosion() {
    final Vector2 explosionPosition = Vector2(
      position.x - size.x / 2 + _random.nextDouble() * size.x,
      position.y - size.y / 2 + _random.nextDouble() * size.y,
    );

    final ExplosionType explosionType = _random.nextBool() ? ExplosionType.smoke : ExplosionType.fire;

    final Explosion explosion = Explosion(position: explosionPosition, explosionSize: size.x * 0.7, explosionType: explosionType);

    game.add(explosion);
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollision(intersectionPoints, other);

    if (other is Enemy) {
      // if(activeShield == null) _handleDestructoin();
      other.takeDamage();
    }
    else if(other is Pickup) {
      other.removeFromParent();
      game.incrementScore(1);

      switch(other.pickupType) {
        case PickupType.bullet :
        game.audioManager.playSound('collect');
          _bulletPowerupTimer.start();
          break;
        case PickupType.bomb :
          game.audioManager.playSound('collect_bomb');
        // game.add(Bomb(position: position.clone()));
          _health--;
          _health--;
          game.incrementHealth(-20);

          game.shakeCamera(intensity: 25, duration: 0.2);
          _vibrate();
          if (_health <= 0) {
            ///  blast rocket
            _createExplosion();
            _handleDestructoin();
          } else {
            _flashWhite();
          }
          break;
      /// if shield pickup have
      // case PickupType.shield :
      //   if(activeShield != null){
      //     remove(activeShield!);
      //   }
      //   activeShield = Shield();
      //   add(activeShield!);
      //   break;
      }
    }
  }

  void takeDamage() {
    _health--;
    // Clamp to zero
    if (_health < 0) _health = 0;

    game.shakeCamera(intensity: 10, duration: 0.3);


    _vibrate();

    game.incrementScore(-1);
    if(_health >= 0)
      game.incrementHealth(-10);
    if (_health <= 0) {
      ///  blast rocket
      _createExplosion();
      _handleDestructoin();
    } else {
      _flashWhite();
    }
  }

  void _vibrate() async {
    if (await Vibration.hasVibrator() ?? false) {
      Vibration.vibrate(duration: 100);
    }
  }

  void _flashWhite() {
    final ColorEffect flashEffect =
    ColorEffect(const Color.fromRGBO(255, 255, 255, 1.0), EffectController(duration: 0.1, alternate: true, curve: Curves.easeInOut));
    add(flashEffect);
  }

  void _createExplosion() {
    final Explosion explosion = Explosion(position: position.clone(), explosionSize: size.x, explosionType: ExplosionType.dust);
    game.add(explosion);
  }
}

