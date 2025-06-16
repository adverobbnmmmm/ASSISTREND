import 'package:connect/Guidlines_page.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;

class NetworkingArenaPage extends StatefulWidget {
  const NetworkingArenaPage({Key? key}) : super(key: key);

  @override
  State<NetworkingArenaPage> createState() => _NetworkingArenaPageState();
}

class _NetworkingArenaPageState extends State<NetworkingArenaPage>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _pulseController;
  late AnimationController _orbitController;

  @override
  void initState() {
    super.initState();

    // Rotation animation for orbital rings
    _rotationController = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    )..repeat();

    // Pulse animation for the globe
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    // Orbit animation for dots
    _orbitController = AnimationController(
      duration: const Duration(seconds: 6),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _pulseController.dispose();
    _orbitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2D2D2D),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              const Spacer(flex: 2),

              // Welcome text
              RichText(
                textAlign: TextAlign.center,
                text: const TextSpan(
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    height: 1.2,
                  ),
                  children: [
                    TextSpan(text: 'Welcome Anu, to the\nnetworking '),
                    TextSpan(
                      text: '"arena"',
                      style: TextStyle(color: Color(0xFF4A90E2)),
                    ),
                  ],
                ),
              ),

              const Spacer(flex: 1),

              // Animated 3D Globe illustration
              SizedBox(
                height: 400,
                child: AnimatedBuilder(
                  animation: Listenable.merge([
                    _rotationController,
                    _pulseController,
                    _orbitController,
                  ]),
                  builder: (context, child) {
                    return Stack(
                      alignment: Alignment.center,
                      children: [
                        // Phone base with 3D effect
                        Transform(
                          alignment: Alignment.center,
                          transform:
                              Matrix4.identity()
                                ..setEntry(3, 2, 0.001)
                                ..rotateX(-0.1)
                                ..rotateY(0.1),
                          child: Container(
                            width: 220,
                            height: 380,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [Color(0xFFE8E8F0), Color(0xFFC4C4E0)],
                              ),
                              borderRadius: BorderRadius.circular(25),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.3),
                                  blurRadius: 25,
                                  offset: const Offset(5, 15),
                                ),
                                BoxShadow(
                                  color: const Color(
                                    0xFF4A90E2,
                                  ).withOpacity(0.2),
                                  blurRadius: 30,
                                  offset: const Offset(-5, -10),
                                ),
                              ],
                            ),
                            child: Stack(
                              children: [
                                // Phone screen reflection
                                Positioned(
                                  top: 20,
                                  left: 20,
                                  right: 20,
                                  bottom: 80,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [
                                          Colors.white.withOpacity(0.1),
                                          Colors.transparent,
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                  ),
                                ),
                                // Home indicator
                                Positioned(
                                  bottom: 15,
                                  left: 80,
                                  right: 80,
                                  child: Container(
                                    height: 4,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF4A90E2),
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Animated Globe with pulse effect
                        Transform.scale(
                          scale: 1.0 + (_pulseController.value * 0.05),
                          child: Container(
                            width: 160,
                            height: 160,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 20,
                                  offset: const Offset(0, 8),
                                ),
                                BoxShadow(
                                  color: const Color(
                                    0xFF4FC3F7,
                                  ).withOpacity(0.3),
                                  blurRadius: 15,
                                  offset: const Offset(0, 0),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(80),
                              child: Stack(
                                children: [
                                  // Continents with more realistic shapes
                                  Positioned(
                                    top: 25,
                                    left: 20,
                                    child: Container(
                                      width: 70,
                                      height: 45,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF4FC3F7),
                                        borderRadius: BorderRadius.circular(25),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 35,
                                    right: 25,
                                    child: Container(
                                      width: 50,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF4FC3F7),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    top: 80,
                                    left: 45,
                                    child: Container(
                                      width: 35,
                                      height: 30,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF4FC3F7),
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                    ),
                                  ),
                                  // Additional small islands
                                  Positioned(
                                    top: 60,
                                    right: 40,
                                    child: Container(
                                      width: 12,
                                      height: 12,
                                      decoration: const BoxDecoration(
                                        color: Color(0xFF4FC3F7),
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        // Animated Orbital rings
                        ...List.generate(3, (index) {
                          return Transform.rotate(
                            angle:
                                _rotationController.value * 2 * 3.14159 +
                                (index * 1.2),
                            child: Container(
                              width: 200 + (index * 30),
                              height: 200 + (index * 30),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white.withOpacity(
                                    0.4 - (index * 0.1),
                                  ),
                                  width: 1.5,
                                ),
                              ),
                              child: Stack(
                                children: [
                                  // Animated orbital dots
                                  ...List.generate(4 + index, (dotIndex) {
                                    final angle =
                                        (dotIndex / (4 + index)) * 2 * 3.14159 +
                                        (_orbitController.value * 2 * 3.14159);
                                    final radius =
                                        (100 + (index * 15)).toDouble();
                                    return Positioned(
                                      left:
                                          radius +
                                          (radius *
                                                  0.8 *
                                                  (1 + (index * 0.15))) *
                                              (1 + 0.3 * math.cos(angle)) /
                                              2,
                                      top:
                                          radius +
                                          (radius *
                                                  0.8 *
                                                  (1 + (index * 0.15))) *
                                              (1 + 0.3 * math.sin(angle)) /
                                              2,
                                      child: Transform.scale(
                                        scale:
                                            1.0 +
                                            (0.3 *
                                                math.sin(
                                                  _orbitController.value *
                                                          2 *
                                                          3.14159 +
                                                      dotIndex,
                                                )),
                                        child: Container(
                                          width: 6,
                                          height: 6,
                                          decoration: BoxDecoration(
                                            color: Colors.white.withOpacity(
                                              0.8,
                                            ),
                                            shape: BoxShape.circle,
                                            boxShadow: [
                                              BoxShadow(
                                                color: const Color(
                                                  0xFF4A90E2,
                                                ).withOpacity(0.5),
                                                blurRadius: 4,
                                                offset: const Offset(0, 0),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  }),
                                ],
                              ),
                            ),
                          );
                        }),
                      ],
                    );
                  },
                ),
              ),

              const Spacer(flex: 2),

              // Get Started button with animation
              AnimatedBuilder(
                animation: _pulseController,
                builder: (context, child) {
                  return Transform.scale(
                    scale: 1.0 + (_pulseController.value * 0.02),
                    child: Container(
                      width: double.infinity,
                      height: 56,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF4A90E2), Color(0xFF357ABD)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF4A90E2).withOpacity(0.4),
                            blurRadius: 15,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EventFlowScreen(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(28),
                          ),
                        ),
                        child: const Text(
                          'Get Started',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

// Import math for trigonometric functions
