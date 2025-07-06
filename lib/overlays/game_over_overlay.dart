import 'package:flutter/material.dart';
import 'package:space_shooter/my_game.dart';

class GameOverOverlay extends StatefulWidget {

  final MyGame game;

  const GameOverOverlay({super.key, required this.game});

  @override
  State<GameOverOverlay> createState() => _GameOverOverlayState();
}

class _GameOverOverlayState extends State<GameOverOverlay> {

  double _opacity = 0.0;

  @override
  void initState() {
    super.initState();

    Future.delayed(
      const Duration(milliseconds: 0),
      () {
        setState(() {
          _opacity = 1.0;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      onEnd: () {
        if (_opacity == 0.0){
          widget.game.overlays.remove('GameOver');
        }
      },
      opacity: _opacity,
      duration: const Duration(milliseconds: 500),
      child: Container(
        color: Colors.black.withAlpha(150),
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('GAME OVER',style: TextStyle(color: Colors.white,fontSize: 48,fontWeight: FontWeight.bold),),
            SizedBox(height: 30,),

          Text('Your score is : ${widget.game.scoreDisplay.text}',style: TextStyle(color: Colors.white,fontSize: 28),),

            SizedBox(height: 30,),

            TextButton(onPressed: () {
              widget.game.audioManager.playSound('click');
              widget.game.restartGame();
              setState(() {
                _opacity = 0.0;
              });
            },
                style: TextButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 25),
                    backgroundColor: Colors.blue,
                    shape:  RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50)
                    )
                ),
                child: Text('PLAY AGAIN',style: TextStyle(color: Colors.white,fontSize: 28),)),
            SizedBox(height: 15,),
            TextButton(onPressed: () {
              widget.game.audioManager.playSound('click');
              widget.game.quitGame();
              setState(() {
                _opacity = 0.0;
              });
            },
                style: TextButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 25),
                    backgroundColor: Colors.blue,
                    shape:  RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50)
                    )
                ),
                child: Text('GAME OVER',style: TextStyle(color: Colors.white,fontSize: 28),)),

          ],
        ),
      ),
    );
  }
}
