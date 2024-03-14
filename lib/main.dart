import 'dart:async';
import 'dart:math'; // Import the 'dart:math' library
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Balloon Popper',
      home: GameScreen(),
    );
  }
}

class GameScreen extends StatefulWidget {
  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  int score = 0;
  int missedBalloons = 0;
  Timer? timer;
  int timeRemaining = 120; // 2 minutes in seconds
  List<Balloon> balloons = [];
  final Random _random = Random(); // Create a single instance of Random

  @override
  void initState() {
    super.initState();
    startGame();
  }

  void startGame() {
    timer = Timer.periodic(Duration(seconds: 1), (Timer t) {
      setState(() {
        timeRemaining--;
        if (timeRemaining == 0) {
          t.cancel();
          showGameOverDialog();
        } else {
          addBalloon();
        }
      });
    });
  }

  void addBalloon() {
    balloons.add(Balloon(
      top: 1.0,
      left: _random.nextDouble(), // Use the instance variable _random
      size: 50.0,
    ));
  }

  void popBalloon(Balloon balloon) {
    setState(() {
      balloons.remove(balloon);
      score += 2;
    });
  }

  void missBalloon(Balloon balloon) {
    setState(() {
      balloons.remove(balloon);
      missedBalloons++;
      score--;
    });
  }

  void showGameOverDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Game Over'),
          content: Text('Your score is $score'),
          actions: [
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
      missedBalloons = 0;
      timeRemaining = 120;
      balloons.clear();
    });
    startGame();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Balloon Popper'),
      ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.blue, Colors.cyan],
              ),
            ),
          ),
          Positioned(
            top: 10,
            left: 10,
            child: Text(
              'Score: $score',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          Positioned(
            top: 10,
            right: 10,
            child: Text(
              'Missed: $missedBalloons',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          Positioned(
            top: 50,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                '${Duration(seconds: timeRemaining).inMinutes.remainder(60).toString().padLeft(2, '0')}:${Duration(seconds: timeRemaining).inSeconds.remainder(60).toString().padLeft(2, '0')}',
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          ...balloons.map((balloon) {
            return BalloonWidget(
              balloon: balloon,
              onTap: popBalloon,
              onMiss: missBalloon,
            );
          }).toList(),
        ],
      ),
    );
  }
}

class Balloon {
  double top;
  double left;
  double size;

  Balloon({
    required this.top,
    required this.left,
    required this.size,
  });
}

class BalloonWidget extends StatefulWidget {
  final Balloon balloon;
  final Function(Balloon) onTap;
  final Function(Balloon) onMiss;

  BalloonWidget({
    required this.balloon,
    required this.onTap,
    required this.onMiss,
  });

  @override
  _BalloonWidgetState createState() => _BalloonWidgetState();
}

class _BalloonWidgetState extends State<BalloonWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(seconds: 5),
      vsync: this,
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          widget.onMiss(widget.balloon);
        }
      });
    _animation = Tween<double>(begin: 1.0, end: -1.0).animate(_controller);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (BuildContext context, Widget? child) {
        return Positioned(
          top: _animation.value * MediaQuery.of(context).size.height,
          left: widget.balloon.left * MediaQuery.of(context).size.width,
          child: GestureDetector(
            onTap: () {
              widget.onTap(widget.balloon);
              _controller.stop();
            },
            child: Container(
              width: widget.balloon.size,
              height: widget.balloon.size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.red,
              ),
            ),
          ),
        );
      },
    );
  }
}
