import 'package:flutter/material.dart';
import 'package:tic_tac_toe/views/game_screen.dart';
import 'package:tic_tac_toe/widgets/button_widget.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade900, Colors.purple.shade900],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Tic Tac Toe",
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 50),
              ButtonWidget(
                onClicked: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => GameScreen(
                        isSinglePlayer: false,
                      ),
                    ),
                  );
                },
                text: "Two Players",
              ),
              SizedBox(height: 20),
              ButtonWidget(
                onClicked: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => GameScreen(
                        isSinglePlayer: true,
                      ),
                    ),
                  );
                },
                text: "Player vs Computer ",
              ),
            ],
          ),
        ),
      ),
    );
  }
}
