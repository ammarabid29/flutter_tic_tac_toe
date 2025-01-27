import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

class GameScreen extends StatefulWidget {
  final bool isSinglePlayer;
  const GameScreen({super.key, required this.isSinglePlayer});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen>
    with SingleTickerProviderStateMixin {
  late List<List<String>> board;
  late bool xTurn;
  late bool gameOver;
  late String winner;
  bool isComputerThinking = false;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    initializeGame();

    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void initializeGame() {
    board = List.generate(3, (_) => List.filled(3, ""));
    xTurn = true;
    gameOver = false;
    winner = "";
    isComputerThinking = false;
  }

  void showGameOverDialog() {
    _animationController.forward(from: 0.0);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return ScaleTransition(
          scale: _scaleAnimation,
          child: AlertDialog(
            backgroundColor: Colors.white70,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            content: Container(
              height: 250,
              padding: EdgeInsets.all(10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    height: 80,
                    width: 80,
                    decoration: BoxDecoration(
                      color: winner == "Draw"
                          ? Colors.orange.shade200
                          : winner == "X"
                              ? Colors.blue.shade200
                              : Colors.pink.shade200,
                    ),
                    child: Icon(
                      winner == "Draw"
                          ? Icons.balance
                          : winner == "X"
                              ? Icons.close
                              : Icons.circle_outlined,
                      size: 50,
                      color: winner == "Draw"
                          ? Colors.orange
                          : winner == "X"
                              ? Colors.blue
                              : Colors.pink,
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    winner == "Draw"
                        ? "Game Draw"
                        : winner == "X"
                            ? widget.isSinglePlayer
                                ? "You Won!"
                                : "Player X Wins! "
                            : widget.isSinglePlayer
                                ? "Computer Wins!"
                                : "Player O Wins! ",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: winner == "Draw"
                          ? Colors.orange
                          : winner == "X"
                              ? Colors.blue
                              : Colors.pink,
                    ),
                  ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          setState(() {
                            initializeGame();
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[200],
                          padding: EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        child: Text(
                          "Play Again!",
                          style: TextStyle(
                            color: Colors.grey[800],
                            fontSize: 14,
                          ),
                        ),
                      ),
                      SizedBox(width: 5),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          padding: EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        child: Text(
                          "Main Menu",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void makeMove(int row, int col) {
    if (board[row][col] != "" || gameOver || isComputerThinking) return;

    setState(() {
      board[row][col] = xTurn ? "X" : "O";
      checkWinner(row, col);
      xTurn = !xTurn;

      if (!gameOver && widget.isSinglePlayer && !xTurn) {
        isComputerThinking = true;
        Timer(Duration(seconds: 1), () {
          if (!mounted) return;
          computerMove();
        });
      }
    });
  }

  void computerMove() {
    for (int i = 0; i < 3; i++) {
      for (var j = 0; j < 3; j++) {
        if (board[i][j] == "") {
          board[i][j] = "O";
          if (checkWinningMove(i, j, "O")) {
            setState(() {
              checkWinner(i, j);
              xTurn = !xTurn;
              isComputerThinking = false;
            });
            return;
          }
          board[i][j] = "";
        }
      }
    }

    for (int i = 0; i < 3; i++) {
      for (var j = 0; j < 3; j++) {
        if (board[i][j] == "") {
          board[i][j] = "X";
          if (checkWinningMove(i, j, "X")) {
            setState(() {
              board[i][j] = "O";
              checkWinner(i, j);
              xTurn = !xTurn;
              isComputerThinking = false;
            });
            return;
          }
          board[i][j] = "";
        }
      }
    }

    List<List<int>> emptyCells = [];
    for (int i = 0; i < 3; i++) {
      for (var j = 0; j < 3; j++) {
        if (board[i][j] == "") {
          emptyCells.add([i, j]);
        }
      }
    }

    if (emptyCells.isNotEmpty) {
      final random = Random();
      final move = emptyCells[random.nextInt(emptyCells.length)];
      setState(() {
        board[move[0]][move[1]] = "O";
        checkWinner(move[0], move[1]);
        xTurn = !xTurn;
        isComputerThinking = false;
      });
    }
  }

  bool checkWinningMove(int row, int col, String player) {
    if (board[row].every((cell) => cell == player)) return true;

    if (board.every((row) => row[col] == player)) return true;

    if (row == col) {
      if (List.generate(3, (i) => board[i][i])
          .every((cell) => cell == player)) {
        return true;
      }
    }

    if (row + col == 2) {
      if (List.generate(3, (i) => board[i][2 - i])
          .every((cell) => cell == player)) {
        return true;
      }
    }

    return false;
  }

  void checkWinner(int row, int col) {
    final currentPlayer = board[row][col];

    if (checkWinningMove(row, col, currentPlayer)) {
      gameOver = true;
      winner = currentPlayer;
      showGameOverDialog();
      return;
    }

    if (board.every((row) => row.every((cell) => cell != ""))) {
      gameOver = true;
      winner = "Draw";
      showGameOverDialog();
    }
  }

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
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                gameOver
                    ? winner == "Draw"
                        ? "Game Draw!"
                        : "Player $winner Wins"
                    : isComputerThinking
                        ? "Computer is Thinking....."
                        : "Player ${xTurn ? "X" : "O"}'s Turn",
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 20),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white10,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: GridView.builder(
                    shrinkWrap: true,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    itemCount: 9,
                    itemBuilder: (ctx, index) {
                      final row = index ~/ 3;
                      final col = index % 3;
                      return GestureDetector(
                        onTap: () => makeMove(row, col),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white30,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(
                            child: Text(
                              board[row][col],
                              style: TextStyle(
                                fontSize: 64,
                                fontWeight: FontWeight.bold,
                                color: board[row][col] == "X"
                                    ? Colors.blue.shade300
                                    : Colors.pink.shade300,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
