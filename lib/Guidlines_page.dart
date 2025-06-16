import 'package:flutter/material.dart';

class EventFlowScreen extends StatefulWidget {
  @override
  _EventFlowScreenState createState() => _EventFlowScreenState();
}

class _EventFlowScreenState extends State<EventFlowScreen>
    with TickerProviderStateMixin {
  int currentStep = 0;
  bool isLoading = false;
  List<String> selectedTags = [];
  List<String> selectedConditions = [];

  late AnimationController _rotationController;
  late AnimationController _pulseController;

  final List<String> steps = ['guidelines', 'conditions', 'pool', 'room'];
  final List<String> poolTags = [
    'Accident',
    'Sports',
    'College',
    'Film',
    'Dropout',
    'Designing',
    'Health issue',
    'Music',
    'Jobless',
  ];
  final List<String> conditionTags = [
    '#Single',
    '#Anonymous',
    '#Multiple',
    '#Open',
  ];

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    )..repeat();

    _pulseController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void handleNext() {
    if (currentStep < 3) {
      setState(() {
        currentStep++;
      });
    } else {
      // Start loading when clicking OK on room page
      setState(() {
        isLoading = true;
      });

      // Simulate loading for 3 seconds
      Future.delayed(Duration(seconds: 3), () {
        setState(() {
          isLoading = false;
        });
        // Navigate to call page here
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ready to navigate to call page!')),
        );
      });
    }
  }

  void toggleTag(String tag, {bool isCondition = false}) {
    setState(() {
      if (isCondition) {
        if (selectedConditions.contains(tag)) {
          selectedConditions.remove(tag);
        } else {
          selectedConditions.add(tag);
        }
      } else {
        if (selectedTags.contains(tag)) {
          selectedTags.remove(tag);
        } else {
          selectedTags.add(tag);
        }
      }
    });
  }

  Widget buildProgressIndicator() {
    return Column(
      children: [
        // Top row: Guidelines and Conditions
        Row(
          children: [
            buildStepChip('Guidelines', Icons.description, 0),
            Expanded(
              child: Container(
                height: 2,
                margin: EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      color: Colors.grey.shade600,
                      width: 2,
                      style: BorderStyle.solid,
                    ),
                  ),
                ),
                child: CustomPaint(painter: DottedLinePainter()),
              ),
            ),
            buildStepChip('Conditions', Icons.list_alt, 1),
          ],
        ),
        SizedBox(height: 16),
        // Bottom row: Pool and Room
        Row(
          children: [
            buildStepChip('Pool', Icons.waves, 2),
            Expanded(
              child: Container(
                height: 2,
                margin: EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      color: Colors.grey.shade600,
                      width: 2,
                      style: BorderStyle.solid,
                    ),
                  ),
                ),
                child: CustomPaint(painter: DottedLinePainter()),
              ),
            ),
            buildStepChip('Room', Icons.people, 3),
          ],
        ),
      ],
    );
  }

  Widget buildStepChip(String label, IconData icon, int stepIndex) {
    bool isActive = currentStep == stepIndex;
    bool isCompleted = currentStep > stepIndex;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(
          color: isActive ? Colors.blue : Colors.grey.shade600,
          width: 2,
        ),
        borderRadius: BorderRadius.circular(24),
        color: isActive ? Colors.blue.withOpacity(0.1) : Colors.transparent,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isActive ? Colors.blue : Colors.grey.shade400,
            size: 20,
          ),
          SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: isActive ? Colors.blue : Colors.grey.shade400,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (isCompleted) ...[
            SizedBox(width: 8),
            Icon(Icons.check, color: Colors.green, size: 16),
          ],
        ],
      ),
    );
  }

  Widget buildLoadingScreen() {
    return Scaffold(
      backgroundColor: Colors.grey.shade900,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Loading animation
            Container(
              width: 120,
              height: 120,
              child: Stack(
                children: [
                  // Outer ring
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.grey.shade700, width: 4),
                    ),
                  ),
                  // Spinning ring
                  RotationTransition(
                    turns: _rotationController,
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.transparent, width: 4),
                      ),
                      child: CircularProgressIndicator(
                        strokeWidth: 4,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                      ),
                    ),
                  ),
                  // Inner profile placeholder
                  Center(
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.grey.shade600,
                      ),
                      child: Icon(
                        Icons.people,
                        color: Colors.grey.shade400,
                        size: 32,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 32),
            // Pulsing dots
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(3, (index) {
                return AnimatedBuilder(
                  animation: _pulseController,
                  builder: (context, child) {
                    return Container(
                      margin: EdgeInsets.symmetric(horizontal: 4),
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.blue.withOpacity(
                          0.3 + (0.7 * _pulseController.value),
                        ),
                      ),
                    );
                  },
                );
              }),
            ),
            SizedBox(height: 16),
            Text(
              'Connecting to room...',
              style: TextStyle(color: Colors.grey.shade400, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildGuidelinesPage() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Guidelines',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: Colors.blue,
          ),
        ),
        SizedBox(height: 24),
        buildGuidelineItem(
          '✨',
          'Networking is crucial for expanding opportunities, accessing valuable information, and building supportive relationships for personal and professional growth!',
        ),
        SizedBox(height: 16),
        buildGuidelineItem(
          '🚀',
          'Here, we aim to enhance the potential of networking.',
        ),
        SizedBox(height: 16),
        buildGuidelineItem(
          '📍',
          'It is your secret weapon to unlock amazing opportunities, find cool jobs, and build a strong support system in this vibrant world.',
        ),
        SizedBox(height: 24),
        Text(
          'With your daily life AI companion, Assistrend, you can explore the world! Are you ready to begin? Click OK.',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey.shade300,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget buildGuidelineItem(String emoji, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(emoji, style: TextStyle(fontSize: 20)),
        SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade300,
              fontWeight: FontWeight.w600,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget buildConditionsPage() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Condition',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: Colors.blue,
          ),
        ),
        SizedBox(height: 32),
        Text(
          'Show my name/Anonymous',
          style: TextStyle(fontSize: 18, color: Colors.grey.shade300),
        ),
        SizedBox(height: 32),
        GridView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 3,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: conditionTags.length,
          itemBuilder: (context, index) {
            String tag = conditionTags[index];
            bool isSelected = selectedConditions.contains(tag);

            return GestureDetector(
              onTap: () => toggleTag(tag, isCondition: true),
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: isSelected ? Colors.blue : Colors.grey.shade600,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  color:
                      isSelected
                          ? Colors.blue.withOpacity(0.2)
                          : Colors.transparent,
                ),
                child: Center(
                  child: Text(
                    tag,
                    style: TextStyle(
                      color: isSelected ? Colors.blue : Colors.grey.shade400,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget buildPoolPage() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Pool',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: Colors.blue,
          ),
        ),
        SizedBox(height: 16),
        Text(
          'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Etiam eu turpis molestie, dictum est a, mattis tellus.',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey.shade300,
            height: 1.5,
          ),
        ),
        SizedBox(height: 24),
        Row(
          children: [
            buildCategoryButton('Experience'),
            SizedBox(width: 16),
            buildCategoryButton('Passion'),
          ],
        ),
        SizedBox(height: 24),
        ...poolTags.map((tag) => buildTagCheckbox(tag)).toList(),
        SizedBox(height: 24),
        OutlinedButton(
          onPressed: () {},
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: Colors.grey.shade600),
            foregroundColor: Colors.grey.shade400,
          ),
          child: Text('Pool Box'),
        ),
      ],
    );
  }

  Widget buildCategoryButton(String label) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.blue, width: 2),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Text(
        label,
        style: TextStyle(color: Colors.blue, fontWeight: FontWeight.w500),
      ),
    );
  }

  Widget buildTagCheckbox(String tag) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Checkbox(
            value: selectedTags.contains(tag),
            onChanged: (value) => toggleTag(tag),
            activeColor: Colors.blue,
            side: BorderSide(color: Colors.grey.shade600),
          ),
          SizedBox(width: 12),
          Text(tag, style: TextStyle(color: Colors.grey.shade300)),
        ],
      ),
    );
  }

  Widget buildRoomPage() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Room',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: Colors.blue,
          ),
        ),
        SizedBox(height: 48),
        Container(
          height: 400,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Top user profile
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [Colors.orange.shade300, Colors.pink.shade200],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    border: Border.all(color: Colors.white, width: 3),
                  ),
                  child: Icon(Icons.person, color: Colors.white, size: 40),
                ),

                SizedBox(height: 20),

                // Vertical connecting line
                Container(width: 3, height: 60, color: Colors.blue.shade400),

                SizedBox(height: 20),

                // Bottom row with AI and third user
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // AI Bot
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [
                            Colors.blue.shade600,
                            Colors.purple.shade400,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        border: Border.all(color: Colors.white, width: 3),
                      ),
                      child: Icon(
                        Icons.smart_toy,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),

                    // Horizontal connecting line
                    Container(
                      width: 60,
                      height: 3,
                      color: Colors.blue.shade400,
                      margin: EdgeInsets.symmetric(horizontal: 10),
                    ),

                    // Third user
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [Colors.teal.shade300, Colors.green.shade200],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        border: Border.all(color: Colors.white, width: 3),
                      ),
                      child: Icon(Icons.person, color: Colors.white, size: 40),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return buildLoadingScreen();
    }

    return Scaffold(
      backgroundColor: Colors.grey.shade900,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Event',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 32),
              buildProgressIndicator(),
              SizedBox(height: 32),
              Expanded(
                child: SingleChildScrollView(
                  child: Builder(
                    builder: (context) {
                      switch (currentStep) {
                        case 0:
                          return buildGuidelinesPage();
                        case 1:
                          return buildConditionsPage();
                        case 2:
                          return buildPoolPage();
                        case 3:
                          return buildRoomPage();
                        default:
                          return Container();
                      }
                    },
                  ),
                ),
              ),
              SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: handleNext,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  child: Text(
                    'Ok',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
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

class DottedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint =
        Paint()
          ..color = Colors.grey.shade600
          ..strokeWidth = 2;

    double dashWidth = 5;
    double dashSpace = 3;
    double startX = 0;

    while (startX < size.width) {
      canvas.drawLine(Offset(startX, 0), Offset(startX + dashWidth, 0), paint);
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
