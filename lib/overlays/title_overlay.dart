import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:space_shooter/my_game.dart';

class TitleOverlay extends StatefulWidget {
  final MyGame game;

  const TitleOverlay({super.key, required this.game});

  @override
  State<TitleOverlay> createState() => _TitleOverlayState();
}

class _TitleOverlayState extends State<TitleOverlay> {
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
        if (_opacity == 0) {
          widget.game.overlays.remove('Title');
        }
      },
      opacity: _opacity,
      duration: const Duration(milliseconds: 500),
      child: Center(
        child: Container(
          height: double.infinity,
          width: double.infinity,
          decoration: BoxDecoration(image: DecorationImage(image: AssetImage('assets/images/splash.png'), fit: BoxFit.fill)),
          alignment: Alignment.center,
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.only(top: 650),
                child: Container(
                  height: 50,
                  width: 100,
                  child: TextButton(
                      onPressed: () {
                        widget.game.audioManager.playSound('click');
                        widget.game.startGame();
                        setState(() {
                          _opacity = 0.0;
                        });
                      },
                      style: TextButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 25),
                          backgroundColor: Colors.blue,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                      child: Text(
                        'Start',
                        style: TextStyle(color: Colors.white, fontSize: 19),
                      )),
                ),
              ),
              SizedBox(height: 15,),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: () {
                      widget.game.audioManager.playSound('click');
                      setState(() {
                        widget.game.audioManager.toggleMusic();
                      });
                    },
                    icon: Icon(
                      widget.game.audioManager.musicEnabled ? Icons.music_note_rounded : Icons.music_off_rounded,
                      color: widget.game.audioManager.musicEnabled ? Colors.white : Colors.grey,size: 30,
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      widget.game.audioManager.playSound('click');
                      setState(() {
                        widget.game.audioManager.toggleSound();
                      });
                    },
                    icon: Icon(
                      widget.game.audioManager.soundsEnabled ? Icons.volume_up_rounded : Icons.volume_off_rounded,
                      color: widget.game.audioManager.soundsEnabled ? Colors.white : Colors.grey,size: 30,
                    ),
                  ),

                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
