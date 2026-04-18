import 'dart:math';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:math_expressions/math_expressions.dart' hide Interval;
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'M002 Calculator',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.black,
        textTheme: GoogleFonts.jetBrainsMonoTextTheme(ThemeData.dark().textTheme),
      ),
      home: const SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _scaleAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.5, curve: Curves.easeIn)),
    );

    _controller.forward();

    Timer(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => const CalculatorScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
            transitionDuration: const Duration(milliseconds: 1000),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1C1C1E),
              Colors.black,
            ],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(flex: 3),
            ScaleTransition(
              scale: _scaleAnimation,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Container(
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF9500).withOpacity(0.05),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFF9500).withOpacity(0.15),
                        blurRadius: 50,
                        spreadRadius: 5,
                      ),
                    ],
                    border: Border.all(
                      color: const Color(0xFFFF9500).withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: const Icon(
                    Icons.calculate_rounded,
                    size: 80,
                    color: Color(0xFFFF9500),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
            FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                children: [
                  Text(
                    "PRECISION",
                    style: GoogleFonts.lexend(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 10,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFFFF9500).withOpacity(0.5)),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      "V 1.0",
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFFFF9500),
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(flex: 2),
            Padding(
              padding: const EdgeInsets.only(bottom: 50),
              child: SizedBox(
                width: 40,
                height: 40,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    const Color(0xFFFF9500).withOpacity(0.5),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  String equation = "0";
  String result = "0";

  void onButtonClick(String text) {
    setState(() {
      if (text == "C") {
        equation = "0";
        result = "0";
      } else if (text == "⌫") {
        if (equation != "0") {
          equation = equation.substring(0, equation.length - 1);
          if (equation.isEmpty) equation = "0";
        }
      } else if (text == "=") {
        String expression = equation;
        expression = expression.replaceAll('×', '*');
        expression = expression.replaceAll('÷', '/');

        try {
          Parser p = Parser();
          Expression exp = p.parse(expression);
          ContextModel cm = ContextModel();
          double eval = exp.evaluate(EvaluationType.REAL, cm);
          
          if (eval % 1 == 0) {
            result = eval.toInt().toString();
          } else {
            result = eval.toString();
          }
        } catch (e) {
          result = "Error";
        }
      } else {
        if (equation == "0") {
          equation = text;
        } else {
          equation = equation + text;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            double vHeight = constraints.maxHeight;
            double vWidth = constraints.maxWidth;
            
            // Calculate proportional sizes
            double displayAreaHeight = vHeight * 0.3;
            double buttonsAreaHeight = vHeight * 0.7;
            
            // Unbreakable button size calculation
            // We have 5 rows and 4 columns. We need to fit them + gaps.
            double buttonDiameter = min(vWidth / 4.8, buttonsAreaHeight / 6.2);

            return Column(
              children: [
                // 1. Display Area (Responsive)
                Container(
                  height: displayAreaHeight,
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Flexible(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            equation,
                            style: TextStyle(
                              fontSize: 32,
                              color: Colors.white.withOpacity(0.5),
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Flexible(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            result,
                            style: const TextStyle(
                              fontSize: 80, // Target size, will scale down if needed
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: -2,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // 2. Proportional Buttons Area
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildRow(["C", "÷", "×", "⌫"], buttonDiameter, accent: true),
                        _buildRow(["7", "8", "9", "-"], buttonDiameter),
                        _buildRow(["4", "5", "6", "+"], buttonDiameter),
                        _buildRow(["1", "2", "3", "="], buttonDiameter, equalIsAccent: true),
                        _buildRow(["0", ".", "History", "%"], buttonDiameter),
                      ],
                    ),
                  ),
                ),

                // 3. Bottom Aesthetic Line
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: FittedBox(
                    child: Text(
                      "PRECISION ENGINEERED V1.0",
                      style: TextStyle(
                        fontSize: 10,
                        color: const Color(0xFFFF9500).withOpacity(0.4),
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildRow(List<String> labels, double diameter, {bool accent = false, bool equalIsAccent = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: labels.map((label) {
        bool isOperator = ["÷", "×", "-", "+", "=", "C", "⌫"].contains(label);
        bool isPrimary = label == "=";
        
        return _CalculatorButton(
          text: label,
          onPressed: () => onButtonClick(label),
          diameter: diameter,
          color: isPrimary 
              ? const Color(0xFFFF9500) 
              : isOperator 
                  ? const Color(0xFF2C2C2E) 
                  : Colors.transparent,
          textColor: isPrimary ? Colors.black : (accent && isOperator ? const Color(0xFFFF9500) : Colors.white),
        );
      }).toList(),
    );
  }
}

class _CalculatorButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final double diameter;
  final Color color;
  final Color textColor;

  const _CalculatorButton({
    required this.text,
    required this.onPressed,
    required this.diameter,
    this.color = Colors.transparent,
    this.textColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      shape: const CircleBorder(),
      clipBehavior: Clip.hardEdge,
      child: InkWell(
        onTap: onPressed,
        child: Container(
          width: diameter,
          height: diameter,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: color == Colors.transparent 
                ? Border.all(color: Colors.white.withOpacity(0.05), width: 1)
                : null,
            shape: BoxShape.circle,
          ),
          child: Padding(
            padding: const EdgeInsets.all(4.0),
            child: FittedBox(
              child: Text(
                text,
                style: TextStyle(
                  color: textColor,
                  fontSize: 24,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}