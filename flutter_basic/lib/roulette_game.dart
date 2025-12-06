import 'dart:math';
import 'package:flutter/material.dart';

// Centralized roulette configuration
class RouletteConfig {
  static const List<int> numbers = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36];
  static const List<int> redNumbers = [1, 3, 5, 7, 9, 12, 14, 16, 18, 19, 21, 23, 25, 27, 30, 32, 34, 36];
  static const List<int> blackNumbers = [2, 4, 6, 8, 10, 11, 13, 15, 17, 20, 22, 24, 26, 28, 29, 31, 33, 35];
  
  static Color getNumberColor(int number) {
    if (number == 0) return Colors.green;
    if (redNumbers.contains(number)) return Colors.red;
    if (blackNumbers.contains(number)) return Colors.black;
    return Colors.grey;
  }
  
  static bool isRed(int number) => redNumbers.contains(number);
  static bool isBlack(int number) => blackNumbers.contains(number);
}

enum BetType { number, red, black }

class RouletteGame extends StatefulWidget {
  const RouletteGame({super.key});

  @override
  State<RouletteGame> createState() => _RouletteGameState();
}

class _RouletteGameState extends State<RouletteGame>
    with SingleTickerProviderStateMixin {
  double balance = 1000.0;
  double betAmount = 10.0;
  int? selectedNumber;
  BetType betType = BetType.number;
  bool isSpinning = false;
  int? result;
  
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void spinRoulette() {
    if (betType == BetType.number && selectedNumber == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a number first!')),
      );
      return;
    }

    if (betAmount > balance) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Insufficient balance!')),
      );
      return;
    }

    setState(() {
      isSpinning = true;
      balance -= betAmount;
    });

    _controller.forward(from: 0).then((_) {
      final random = Random();
      final spinResult = RouletteConfig.numbers[random.nextInt(RouletteConfig.numbers.length)];

      setState(() {
        result = spinResult;
        isSpinning = false;

        bool won = false;
        double winnings = 0;

        switch (betType) {
          case BetType.number:
            if (spinResult == selectedNumber) {
              won = true;
              winnings = betAmount * 35; // 35:1 payout
              balance += betAmount * 36;
            }
            break;
          case BetType.red:
            if (RouletteConfig.isRed(spinResult)) {
              won = true;
              winnings = betAmount; // 1:1 payout
              balance += betAmount * 2;
            }
            break;
          case BetType.black:
            if (RouletteConfig.isBlack(spinResult)) {
              won = true;
              winnings = betAmount; // 1:1 payout
              balance += betAmount * 2;
            }
            break;
        }

        _showResultDialog(won, winnings);
      });
    });
  }

  void _showResultDialog(bool won, double winnings) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(won ? '🎉 Winner!' : '😔 Try Again'),
        content: Text(
          won
              ? 'Number $result! You won \$${winnings.toStringAsFixed(2)}!'
              : 'Number $result. Better luck next time!',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Roulette Game'),
        backgroundColor: Colors.red[900],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.red[900]!, Colors.black],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Balance Display
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Card(
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Balance: \$${balance.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (result != null)
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: RouletteConfig.getNumberColor(result!),
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              '$result',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),

              // Spinning Animation
              Expanded(
                child: Center(
                  child: AnimatedBuilder(
                    animation: _animation,
                    builder: (context, child) {
                      return Transform.rotate(
                        angle: _animation.value * 4 * pi,
                        child: Container(
                          width: 200,
                          height: 200,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [Colors.red[700]!, Colors.black],
                            ),
                            border: Border.all(color: Colors.amber, width: 4),
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.casino,
                              size: 80,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),

              // Bet Type Selection
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: isSpinning ? null : () {
                              setState(() {
                                betType = BetType.number;
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: betType == BetType.number ? Colors.amber : Colors.grey[300],
                            ),
                            child: const Text('Number', style: TextStyle(color: Colors.black)),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: isSpinning ? null : () {
                              setState(() {
                                betType = BetType.red;
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: betType == BetType.red ? Colors.red : Colors.grey[300],
                            ),
                            child: const Text('Red', style: TextStyle(color: Colors.white)),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: isSpinning ? null : () {
                              setState(() {
                                betType = BetType.black;
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: betType == BetType.black ? Colors.black : Colors.grey[300],
                            ),
                            child: const Text('Black', style: TextStyle(color: Colors.white)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Number Selection Grid (only show when betting on numbers)
              if (betType == BetType.number)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Card(
                    child: Container(
                      height: 200,
                      padding: const EdgeInsets.all(8),
                      child: GridView.builder(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 7,
                          crossAxisSpacing: 4,
                          mainAxisSpacing: 4,
                        ),
                        itemCount: RouletteConfig.numbers.length,
                        itemBuilder: (context, index) {
                          final number = RouletteConfig.numbers[index];
                          return GestureDetector(
                            onTap: isSpinning
                                ? null
                                : () {
                                    setState(() {
                                      selectedNumber = number;
                                    });
                                  },
                            child: Container(
                              decoration: BoxDecoration(
                                color: selectedNumber == number
                                    ? Colors.amber
                                    : RouletteConfig.getNumberColor(number),
                                border: Border.all(color: Colors.white, width: 2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Center(
                                child: Text(
                                  '$number',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),

              // Bet Controls
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Bet Amount:',
                              style: TextStyle(fontSize: 18),
                            ),
                            Text(
                              '\$${betAmount.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Slider(
                          value: betAmount,
                          min: 10,
                          max: 500,
                          divisions: 49,
                          label: '\$${betAmount.toStringAsFixed(0)}',
                          onChanged: isSpinning
                              ? null
                              : (value) {
                                  setState(() {
                                    betAmount = value;
                                  });
                                },
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: isSpinning ? null : spinRoulette,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red[900],
                            minimumSize: const Size(double.infinity, 50),
                          ),
                          child: Text(
                            isSpinning ? 'Spinning...' : 'SPIN',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
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
