import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme_provider.dart';
import 'dart:math';

class GameScreen extends StatefulWidget {
  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late List<String> board;
  late String currentPlayer;
  late bool isTwoPlayerMode;
  late bool isPlayerVsComputer;
  int playerXScore = 0;
  int playerOScore = 0;

  @override
  void initState() {
    super.initState();
    resetGame();
    isTwoPlayerMode = true;
    isPlayerVsComputer = false;
  }

  void resetGame() {
    setState(() {
      board = List.filled(9, '');
      currentPlayer = 'X';
    });
  }

  void resetScores() { // CHANGE: Added method to reset scores only
    setState(() {
      playerXScore = 0;
      playerOScore = 0;
    });
  }

  void onTap(int index) {
    if (board[index] == '' && !checkWinner()) {
      setState(() {
        board[index] = currentPlayer;
        if (!checkWinner()) {
          currentPlayer = currentPlayer == 'X' ? 'O' : 'X';
          if (isPlayerVsComputer && currentPlayer == 'O') {
            computerMove();
          }
        }
      });
    }
  }

  bool checkWinner() {
    const List<List<int>> winningCombinations = [
      [0, 1, 2],
      [3, 4, 5],
      [6, 7, 8],
      [0, 3, 6],
      [1, 4, 7],
      [2, 5, 8],
      [0, 4, 8],
      [2, 4, 6],
    ];

    for (var combination in winningCombinations) {
      if (board[combination[0]] != '' &&
          board[combination[0]] == board[combination[1]] &&
          board[combination[1]] == board[combination[2]]) {
        String winner = board[combination[0]];
        updateScore(winner);
        showWinnerDialog(winner);
        return true;
      }
    }

    if (!board.contains('')) {
      showWinnerDialog('Draw');
      return true;
    }

    return false;
  }

  void updateScore(String winner) {
    if (winner == 'X') {
      setState(() {
        playerXScore++;
      });
    } else if (winner == 'O') {
      setState(() {
        playerOScore++;
      });
    }
  }

  void showWinnerDialog(String winner) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(winner == 'Draw' ? 'It\'s a Draw!' : '$winner Wins!'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                resetGame(); // Keep resetting the game grid
              },
              child: Text('Play Again'),
            ),
          ],
        );
      },
    );
  }

  void computerMove() {
    Future.delayed(Duration(milliseconds: 500), () {
      List<int> availableMoves = [];
      for (int i = 0; i < board.length; i++) {
        if (board[i] == '') availableMoves.add(i);
      }
      if (availableMoves.isNotEmpty) {
        int move = availableMoves[Random().nextInt(availableMoves.length)];
        onTap(move);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    final isDarkMode = themeData.brightness == Brightness.dark;

    // Determine colors based on the theme
    final gridColor = isDarkMode ? Colors.grey[800] : Colors.grey[300];
    final textColor = isDarkMode ? Colors.white : Colors.black;

    return Scaffold(
      appBar: AppBar(
        title: Text('Tic Tac Toe'),
        actions: [
          IconButton(
            icon: Icon(Icons.brightness_6),
            onPressed: () {
              final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
              themeProvider.toggleTheme();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Game board
          Expanded(
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
              ),
              itemCount: 9,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () => onTap(index),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(),
                      color: board[index] == '' ? gridColor : Colors.grey,
                    ),
                    child: Center(
                      child: Text(
                        board[index],
                        style: TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          // Score display
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text(
                  'Player X: $playerXScore',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Text(
                  'Player O: $playerOScore',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          // Mode selection
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    isTwoPlayerMode = true;
                    isPlayerVsComputer = false;
                    resetGame();
                  });
                },
                child: Text('2 Player'),
              ),
              SizedBox(width: 10),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    isTwoPlayerMode = false;
                    isPlayerVsComputer = true;
                    resetGame();
                  });
                },
                child: Text('1 Player'),
              ),
            ],
          ),
          SizedBox(height: 20),
          // Reset Scores Button // CHANGE: Added button to reset scores
          ElevatedButton(
            onPressed: resetScores,
            child: Text('Reset Scores'),
          ),
        ],
      ),
    );
  }
}
