import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

void main() {
  runApp(BalloonPopGame());
}

class BalloonPopGame extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: BalloonPopScreen(),
    );
  }
}

class BalloonPopScreen extends StatefulWidget {
  @override
  _BalloonPopScreenState createState() => _BalloonPopScreenState();
}

class _BalloonPopScreenState extends State<BalloonPopScreen> {
  int score = 0;
  int missed = 0;
  late Timer _timer;
  Duration _duration = const Duration(minutes: 2);
  late List<Balloon> balloons;

  @override
  void initState() {
    super.initState();
    startTimer();
    balloons = [];
    generateBalloons();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (_duration.inSeconds == 0) {
          timer.cancel();
          showEndScreen();
        } else {
          _duration -= Duration(seconds: 1);
        }
      });
    });
  }

  void generateBalloons() {
    Timer.periodic(Duration(milliseconds: 1500), (timer) {
      if (_duration.inSeconds == 0) {
        timer.cancel();
      } else {
        setState(() {
          balloons.add(Balloon(Random().nextInt(300) + 50));
        });
      }
    });
  }

  void popBalloon(Balloon balloon) {
    setState(() {
      if (!balloon.popped) {
        if (balloon.position >= 200) {
          score += 2;
        } else {
          missed++;
        }
        balloon.pop();
      }
    });
  }

  void showEndScreen() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Game Over"),
          content: Text("Score: $score\nBalloons Missed: $missed"),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                resetGame();
              },
              child: Text('Play Again'),
            ),
          ],
        );
      },
    );
  }

  void resetGame() {
    setState(() {
      score = 0;
      missed = 0;
      _duration = Duration(minutes: 2);
      balloons.clear();
      startTimer();
      generateBalloons();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Balloon Pop Game'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'Time Left: ${_duration.inMinutes}:${(_duration.inSeconds % 60).toString().padLeft(2, '0')}',
            style: TextStyle(fontSize: 24),
          ),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Balloons Popped: $score',
                style: TextStyle(fontSize: 20, color: Colors.green),
              ),
              SizedBox(width: 20),
              Text(
                'Balloons Missed: $missed',
                style: TextStyle(fontSize: 20, color: Colors.red),
              ),
            ],
          ),
          Expanded(
            child: GestureDetector(
              onTapDown: (TapDownDetails details) {
                Offset position = details.localPosition;
                for (Balloon balloon in balloons) {
                  if (balloon.isTapped(position)) {
                    popBalloon(balloon);
                    break;
                  }
                }
              },
              child: Stack(
                children: [
                  Container(
                    color: Colors.lightBlueAccent,
                  ),
                  ...balloons.map((balloon) {
                    return Positioned(
                      left: balloon.position.toDouble(),
                      bottom: balloon.height.toDouble(),
                      child: balloon.widget,
                    );
                  }).toList(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class Balloon {
  final double position;
  final double height;
  bool popped;

  Balloon(this.position, {this.height = 0, this.popped = false});

  void pop() {
    popped = true;
  }

  Widget get widget {
    return popped
        ? SizedBox()
        : GestureDetector(
            onTap: () {},
            child: Image.asset(
              'D:\Downloads\Blue-Balloons-Transparent.png',
              width: 50,
            ),
          );
  }

  bool isTapped(Offset tapPosition) {
    double tapX = tapPosition.dx;
    double tapY = tapPosition.dy;
    double balloonX = position + 25;
    double balloonY = 600 - height - 50;
    return (tapX >= balloonX && tapX <= balloonX + 50 && tapY >= balloonY && tapY <= balloonY + 100);
  }
}
